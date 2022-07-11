//
//  InAppSubscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.05.2022.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class InAppSubscription: NSObject {
	
	static var shared = InAppSubscription()
	
	private var settings = SettingsManager.sharedInstance
	private var accountSecretKey = C.project.storeSecretKey
	public var products: [SKProduct] = []
	private var restoreExpire = false
	private var purchseProduct = false
	
	public func initialize() {
		
		self.loadProducts()
		self.updateSubscriptionStatus(startApp: true)
		self.completePurchaseTransAction()
	}
}

extension InAppSubscription {
	
	private func loadProducts() {
		
		let products: Set<String> = Set(Subscriptions.allCases.map({$0.rawValue}))
		
		SwiftyStoreKit.retrieveProductsInfo(products) { result in
			self.products = Array(result.retrievedProducts)
			debugPrint(self.products)
		}
	}
	
	public func updateSubscriptionStatus(startApp: Bool = false) {
		self.checkSubscriptionAvailability { purchasePremium in
			SubscriptionManager.instance.setPurchasePremium(purchasePremium)
		}
	}
	
	public func checkForCurrentSubscription(completionHandler: @escaping (_ isPurchasePremium: Bool) -> Void) {
		self.checkSubscriptionAvailability { purchasePremium in
			SubscriptionManager.instance.setPurchasePremium(purchasePremium)
			completionHandler(purchasePremium)
		}
	}
	
	public func getProductDescription(completionHandler: @escaping (_ models: [ProductStoreDesriptionModel]) -> Void) {
		
		if !self.products.isEmpty {
			let models = self.getDescriptionFrom(products: self.products)
			completionHandler(models)
		} else {
			let products: Set<String> = Set(Subscriptions.allCases.map({$0.rawValue}))
			
			SwiftyStoreKit.retrieveProductsInfo(products) { result in
				self.products = []
				self.products.append(contentsOf: Array(result.retrievedProducts))
				let models = self.getDescriptionFrom(products: self.products)
				completionHandler(models)
			}
		}
	}
	
	public func getDescriptionForProduct(_ subscription: Subscriptions, completionHandler: @escaping (_ model: ProductStoreDesriptionModel?) -> Void) {
		
		let product = Subscriptions.lifeTime.rawValue
		SwiftyStoreKit.retrieveProductsInfo(Set([product])) { results in
			if let lifeTime = results.retrievedProducts.first(where: {$0.productIdentifier == Subscriptions.lifeTime.rawValue}) {
				let model = self.getDescriptionFrom(product: lifeTime)
				completionHandler(model)
			} else {
				completionHandler(nil)
			}
		}
	}
	
	
	private func getDescriptionFrom(products: [SKProduct]) -> [ProductStoreDesriptionModel] {
		var descriptionsModel: [ProductStoreDesriptionModel] = []
		
		if !products.isEmpty {
			for product in products {
				if product.productIdentifier != Subscriptions.lifeTime.rawValue {
					let model = getDescriptionFrom(product: product)
					descriptionsModel.append(model)
				}
			}
		}
		return descriptionsModel
	}
	
	private func getDescriptionFrom(product: SKProduct) ->  ProductStoreDesriptionModel {
		
		var description = product.localizedDescription
		var period = ""
		var localizedPrice: String {
			if let price = product.localizedPrice {
				return price
				
			} else {
				return ""
			}
		}
		
		if let subscriptionPeriod = product.subscriptionPeriod {
			if let unitName = getUnitName(unit: subscriptionPeriod.unit, value: subscriptionPeriod.numberOfUnits) {
				period = unitName
			}
		}
		
		if let introductionPeriod = product.introductoryPrice?.subscriptionPeriod.numberOfUnits {
			if let unit = product.introductoryPrice?.subscriptionPeriod.unit {
				let name = getUnitName(unit: unit, isMultiply: introductionPeriod != 1)
					description = "\(introductionPeriod) \(name) \nFree Trial"
			}
		}
		
		let model = ProductStoreDesriptionModel(name: product.localizedTitle,
												price: localizedPrice,
												period: period,
												description: description,
												id: product.productIdentifier
		)
		return model
	}
	
	
	public func getCurrentSubscriptionModel(completionHandler: @escaping (_  model: CurrentSubscriptionModel?) -> Void) {
		
		let name: String = SettingsManager.subscripton.currentSubscriptionName
		let date: String = SettingsManager.subscripton.currentExprireSubscriptionDate
		
		if !date.isEmpty {
			let model = CurrentSubscriptionModel(expireDate: date, name: name)
			completionHandler(model)
		} else {
			let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.accountSecretKey)
			
			SwiftyStoreKit.verifyReceipt(using: appleValidator) { [unowned self] result in
				
				switch result {
					case .success(receipt: let receipt):
						
						let productIDs = Set(Subscriptions.allCases.map({$0.rawValue}))
						let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
						
						switch purchaseResult {
							case .purchased(let expireDate,_):
								self.restoreExpire = false
								SettingsManager.subscripton.expiredSubscription = true
								let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
								SettingsManager.subscripton.currentExprireSubscriptionDate = date
								let model = CurrentSubscriptionModel(expireDate: date, name: "")
								completionHandler(model)
							case .expired(expiryDate: let expireDate, items: _):
								SettingsManager.subscripton.expiredSubscription = false
								let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
								SettingsManager.subscripton.currentExprireSubscriptionDate = date
								SubscriptionManager.instance.setPurchasePremium(false)
								completionHandler(nil)
							default:
								completionHandler(nil)
						}
					case .error(let error):
						debugPrint(error.localizedDescription)
						completionHandler(nil)
				}
			}
		}
	}

	
	private func getUnitName(unit: SKProduct.PeriodUnit, value: Int) -> String? {
		
		switch unit {
			case .day:
				if value == 7 {
					return Localization.Subscription.Description.week
				}
				return Localization.Subscription.Description.day
			case .week:
				return Localization.Subscription.Description.week
			case .month:
				return Localization.Subscription.Description.month
			case .year:
				return Localization.Subscription.Description.year
			default:
				return nil
		}
	}
}

extension InAppSubscription {
	
	public func purchaseProduct(productType: Subscriptions, _ completion: @escaping (_ purchased: Bool) -> Void) {
		
		SwiftyStoreKit.purchaseProduct(productType.rawValue) { [unowned self] (result) in
			
			if case .success(let purchase) = result {
				let downloads = purchase.transaction.downloads
				if !downloads.isEmpty { SwiftyStoreKit.start(downloads) }
				if purchase.needsFinishTransaction { SwiftyStoreKit.finishTransaction(purchase.transaction) }
			}
			
			switch result {
				case .success(_):
					updateExpireSubscription()
					SettingsManager.subscripton.expiredSubscription = true
					completion(true)
				case .error(error: let error):
					completion(false)
					debugPrint(error.localizedDescription)
			}
		}
	}
	
	public func restoreSubscription(_ completionHandler: @escaping (_ restored: Bool, _ expireDate: Date?) -> Void) {
		
		SwiftyStoreKit.restorePurchases { [unowned self] result in
			for purchase in result.restoredPurchases {
				let downloads = purchase.transaction.downloads
				if !downloads.isEmpty {
					SwiftyStoreKit.start(downloads)
				} else {
					SwiftyStoreKit.finishTransaction(purchase.transaction)
				}
			}
			
			if result.restoreFailedPurchases.isEmpty {
				completionHandler(false, nil)
			} else if !result.restoredPurchases.isEmpty {
				
				let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: self.accountSecretKey)
				
				SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
					switch result {
						case .success(receipt: let receipt):
							let productIDs = Set(Subscriptions.allCases.map({$0.rawValue}))
							let purchaseResultSubscription = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
							switch purchaseResultSubscription {
								case .purchased(expiryDate: let exprireDate, items: let items):
									SettingsManager.subscripton.expiredSubscription = true
									let date = Utils.getString(from: exprireDate, format: Constants.dateFormat.expiredDateFormat)
									SettingsManager.subscripton.currentExprireSubscriptionDate = date
									SubscriptionManager.instance.setPurchasePremium(true)
									let subscription = Subscriptions.allCases.first(where: {$0.rawValue == items.first?.productId})
									SubscriptionManager.instance.saveSubscription(subscription)
									completionHandler(true, nil)
								case .expired(expiryDate: let expireDate, items: _):
									let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
									SettingsManager.subscripton.currentExprireSubscriptionDate = date
									SubscriptionManager.instance.setPurchasePremium(false)
									SubscriptionManager.instance.saveSubscription(nil)
									completionHandler(false, expireDate)
								default:
									completionHandler(false, nil)
							}
						case .error(error: let error):
							completionHandler(false, nil)
							debugPrint(error)
					}
				}
			} else {
				completionHandler(false, nil)
			}
		}
	}
}

extension InAppSubscription {
	
	private func completePurchaseTransAction() {
		
		SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
			
			for purchase in purchases {
				
				switch purchase.transaction.transactionState {
					case .purchased, .restored:
						let dowbloads = purchase.transaction.downloads
						if !dowbloads.isEmpty {
							SwiftyStoreKit.start(dowbloads)
						} else if purchase.needsFinishTransaction {
							SwiftyStoreKit.finishTransaction(purchase.transaction)
						}
					case .failed, .purchasing, .deferred:
						break
					@unknown default:
						break
				}
			}
			
			SwiftyStoreKit.updatedDownloadsHandler = { downloads in
				let contentURLs = downloads.compactMap({$0.contentURL})
				if contentURLs.count == downloads.count {
					SwiftyStoreKit.finishTransaction(downloads[0].transaction)
				}
			}
			
			SwiftyStoreKit.shouldAddStorePaymentHandler = { _, product in
				guard let addingProduct = Subscriptions(rawValue: product.productIdentifier) else { return false }
				return Subscriptions.allCases.contains(addingProduct)
			}
			
			if SettingsManager.subscripton.isVerificationPassed, let _ = SwiftyStoreKit.localReceiptData {
				self.updateSubscriptionStatus(startApp: true)
			}
		}
	}
	
	private func checkSubscriptionAvailability(_ completionHandler: @escaping (_ purchasePremium: Bool) -> Void) {
		
		let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.accountSecretKey)
		
		SwiftyStoreKit.verifyReceipt(using: appleValidator) { [unowned self] result in
			
			switch result {
				case .success(receipt: let receipt):
					
					let productIDs = Set(Subscriptions.allCases.map({$0.rawValue}))
					let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
					
					switch purchaseResult {
						case .purchased(let expireDate,_):
							self.restoreExpire = false
							SettingsManager.subscripton.expiredSubscription = true
							let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
							SettingsManager.subscripton.currentExprireSubscriptionDate = date
							completionHandler(true)
							
						case .expired(expiryDate: let expireDate, items: _):
							SettingsManager.subscripton.expiredSubscription = false
							SubscriptionManager.instance.setPurchasePremium(false)
							debugPrint(expireDate)
							completionHandler(false)
						default:
							completionHandler(false)
					}
				case .error(let error):
					debugPrint(error.localizedDescription)
					completionHandler(false)
			}
		}
	}
	
	private func updateExpireSubscription() {
		
		let appValidator = AppleReceiptValidator(service: .production, sharedSecret: accountSecretKey)
		
		SwiftyStoreKit.verifyReceipt(using: appValidator) { (result) in
			switch result {
				case .success(receipt: let receipt):
					
					let productIDs = Set(Subscriptions.allCases.map({$0.rawValue}))
					let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
					
					switch purchaseResult {
						case .purchased(let expireDate, _):
							let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
							SettingsManager.subscripton.currentExprireSubscriptionDate = date
						case .expired(expiryDate: let expireDate, _):
							let date = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
							SettingsManager.subscripton.currentExprireSubscriptionDate = date
						default:
							debugPrint("hello chao)")
					}
				case .error(error: let error):
					debugPrint(error.localizedDescription)
			}
		}
	}
}

extension InAppSubscription {
		
	private func getProduct(by type: Subscriptions) -> SKProduct? {
		
		if let product = self.products.first(where: {$0.productIdentifier == type.rawValue}) {
			return product
		}
		return nil
	}
	
	private func getProductPrice(for type: Subscriptions) -> String {
		
		guard let product = self.getProduct(by: type) else { return "" }
		
		let locale = product.priceLocale
		return "\(product.price)\(locale.currencySymbol ?? "$")"
	}
	
	private func getPriceValue(for type: Subscriptions) -> Float {
		guard let product = self.getProduct(by: type) else { return 0 }
		return Float(truncating: product.price)
	}
	
	private func getTrialPeriod(for type: Subscriptions) -> String {
		guard let product = self.getProduct(by: type) else {return "" }
		if let numberOfUnits = product.introductoryPrice?.subscriptionPeriod.numberOfUnits {
			let unit = product.introductoryPrice?.subscriptionPeriod.unit
			let name = self.getUnitName(unit: unit, isMultiply: numberOfUnits != 1)
			return "\(numberOfUnits) \(name) free trial"
		}
		return ""
	}
	
	private func getUnitName(unit: SKProduct.PeriodUnit?, isMultiply: Bool) -> String {
		
		guard let unit = unit else { return "" }
		
		switch unit {
			case .day:
				if unit.hashValue == 7 {
					return Localization.Subscription.DescriptionSK.week
				}
				return Localization.Subscription.DescriptionSK.day
			case .week:
				return Localization.Subscription.DescriptionSK.week
			case .month:
				return Localization.Subscription.DescriptionSK.month
			case .year:
				return Localization.Subscription.DescriptionSK.year
			default:
				return ""
		}
	}
}

extension InAppSubscription {
	
	private func set(product: String, purchased: Bool) -> Bool {
		do {
			let data = try NSKeyedArchiver.archivedData(withRootObject: purchased, requiringSecureCoding: false)
			U.userDefaults.set(data, forKey: product)
		} catch {
			debugPrint("error")
		}
		return U.userDefaults.synchronize()
	}
	
	private func isPurchase(product: String) -> Bool {
		
		do {
			guard let data = UserDefaults.standard.data(forKey: product) else { return false}
			let isPurchase = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! Bool
			return isPurchase
		} catch {
			debugPrint("error")
			return false
		}
	}
}
