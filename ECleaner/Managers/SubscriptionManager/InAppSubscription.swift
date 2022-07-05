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
	public var priducts: [SKProduct] = []
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
			self.priducts.append(contentsOf: Array(result.retrievedProducts))
			debugPrint(self.priducts)
		}
	}
	
	private func updateSubscriptionStatus(startApp: Bool = false) {
		self.checkSubscriptionAvailability { purchasePremium in
			SubscriptionManager.instance.setPurchasePremium(purchasePremium)
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
					SubscriptionManager.instance.setPurchasePremium(true)
					SettingsManager.inAppPurchase.expiredSubscription = true
					completion(true)
				case .error(error: let error):
					completion(false)
					debugPrint(error.localizedDescription)
			}
		}
	}
	
	public func restoreSubscription(_ completionHandler: @escaping (_ restored: Bool) -> Void) {
		
		SwiftyStoreKit.restorePurchases { [unowned self] result in
			for purchase in result.restoredPurchases {
				let downloads = purchase.transaction.downloads
				if !downloads.isEmpty {
					SwiftyStoreKit.start(downloads)
				} else {
					SwiftyStoreKit.finishTransaction(purchase.transaction)
				}
			}
			
			if !result.restoreFailedPurchases.isEmpty {
#warning(" TODO")
				/// create alert restore purchse failed
			} else if !result.restoredPurchases.isEmpty {
				
				let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: self.accountSecretKey)
				
				SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
					switch result {
						case .success(receipt: let receipt):
							let productIDs = Set(Subscriptions.allCases.map({$0.rawValue}))
							let purchaseResultSubscription = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
							
							switch purchaseResultSubscription {
								case .purchased(expiryDate: let exprireDate, items: _):
									
									SettingsManager.inAppPurchase.expiredSubscription = true
									SettingsManager.inAppPurchase.expireDateSubscription = exprireDate
									SubscriptionManager.instance.setPurchasePremium(true)
									completionHandler(true)
								case .expired(expiryDate: let expireDate, items: _):
									SettingsManager.inAppPurchase.expiredSubscription = false
									SettingsManager.inAppPurchase.expireDateSubscription = expireDate
									SubscriptionManager.instance.setPurchasePremium(false)
									completionHandler(false)
									U.delay(0.2) {
#warning("TODO")
										/// show alert
//										let message = "\(L.iap.alertMessages.expire): \(self.dateLocale.string(from: expireDate))"
//										A.showDefaultAler(message: message)
									}
								default:
#warning("showAlert")
//									A.showDefaultAler(L.iap.alertTitles.restoreFail, message: L.iap.alertMessages.restoreFailed)
									completionHandler(false)
							}
						case .error(error: let error):
							completionHandler(false)
							debugPrint(error)
					}
				}
			} else {
				completionHandler(false)
#warning("showAlert")
//				A.showDefaultAler(L.iap.alertTitles.nothingRestore, message: L.iap.alertMessages.noPrevious)
			}
		}
	}
}

extension InAppSubscription {
	
	func checkState() {
		if let _ = SwiftyStoreKit.localReceiptData {
#warning("TODO")
				//					Network.theyLive { (isAlive) in
				//						if isAlive {
				//							self.updateSubscriptionStatus()
				//						}
				//					}
		}
	}
	
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
			
			if SettingsManager.inAppPurchase.isVerificationPassed, let _ = SwiftyStoreKit.localReceiptData {
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
							SettingsManager.inAppPurchase.expiredSubscription = true
							SettingsManager.inAppPurchase.expireDateSubscription = expireDate
							completionHandler(true)
							
						case .expired(expiryDate: let expireDate, items: _):
							SettingsManager.inAppPurchase.expiredSubscription = false
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
							SettingsManager.inAppPurchase.expireDateSubscription = expireDate
						case .expired(expiryDate: let expireDate, _):
							SettingsManager.inAppPurchase.expireDateSubscription = expireDate
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
	
#warning("TODO")
//	public func getProductInfo(by type: Subscriptions) -> ProductStoreDesriptionModel? {
//
//		guard let product = self.getProduct(by: type) else { return nil }
//
//		let price = getProductPrice(for: type)
//
//	}
	
	private func getProduct(by type: Subscriptions) -> SKProduct? {
		
		if let product = self.priducts.first(where: {$0.productIdentifier == type.rawValue}) {
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
		var name = String()
		
		switch unit {
			case .day:
				name = "day"
			case .week:
				name = "week"
			case .month:
				name = "month"
			case .year:
				name = "year"
			default:
				return ""
		}
		
		if isMultiply {
			if Locale.current.languageCode == "en" {
				name.append("s")
			}
		}
		return name
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

extension InAppSubscription {
	
	func lifeCicleIAPExpireChecker() {
		
		if let date = SettingsManager.inAppPurchase.expireDateSubscription, date.timeIntervalSince1970 < Date.getCurrentDate() {
			if SubscriptionManager.instance.purchasePremium() {
				self.checkSubscriptionAvailability { (isSubscriptionAvail) in
					if !isSubscriptionAvail {
						debugPrint("subsctiption expired")
						debugPrint(SettingsManager.inAppPurchase.expiredSubscription)
					}
				}
			}
		}
	}
}
