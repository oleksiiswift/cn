//
//  SubscriptionManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import Foundation
import StoreKit

class SubscriptionManager: NSObject {
	
	static var instance: SubscriptionManager {
		struct Static {
			static let instance: SubscriptionManager = SubscriptionManager()
		}
		return Static.instance
	}
		
	@available(iOS 15.0, *)
	private lazy var subscription = Subscription.shared
	private var iapSubscription = InAppSubscription.shared
	
	private var purchasedPremium: Bool {
		get {
			return U.userDefaults.bool(forKey: C.key.subscription.purchasePremium)
		} set {
			if purchasedPremium != newValue {
				debugPrint("****")
				debugPrint("premium status did change -> \(newValue)")
				debugPrint("*****")
				let userInfo = [C.key.subscription.purchasePremium: newValue]
				U.userDefaults.set(newValue, forKey: C.key.subscription.purchasePremium)
				do {
					U.notificationCenter.post(name: .premiumDidChange, object: nil, userInfo: userInfo)
				}
			}
		}
	}
	
	private var currentSubscription: Subscriptions? {
		get {
			let subscriptionID = U.userDefaults.string(forKey: C.key.subscription.subscriptionID)
			if let subcription = Subscriptions.allCases.first(where: {$0.rawValue == subscriptionID}) {
				return subcription
			} else {
				return nil
			}
		} set {
			if currentSubscription != newValue {
				if let value = newValue {
					U.userDefaults.set(value.rawValue, forKey: C.key.subscription.subscriptionID)
				}
			}
		}
	}
	
	public func initialize() {
		
		if #available(iOS 15.0, *) {
			self.subscription.initialize()
		} else {
			self.iapSubscription.initialize()
		}
	}
	
	public func setPurchasePremium(_ purchased: Bool) {
		self.purchasedPremium = purchased
	}
	
	public func purchasePremiumHandler(_ completionHandler: (_ status: StatusSubscription) -> Void) {
		completionHandler(.lifetime)
//		completionHandler(self.isLifeTimeSubscription() ? .lifetime : self.purchasedPremium ? .purchasedPremium : .nonPurchased)
	}
	
	public func purchasePremiumStatus() -> StatusSubscription {
		return self.isLifeTimeSubscription() ? .lifetime : self.purchasedPremium ? .purchasedPremium : .nonPurchased
	}

	public func saveSubscription(_ currentSubscription: Subscriptions?) {
		self.currentSubscription = currentSubscription
	}
								 
	public func getCurrentSubscription() -> Subscriptions? {
		return self.currentSubscription
	}

	public func isLifeTimeSubscription() -> Bool {
		if let currentSubscription = currentSubscription {
			return currentSubscription.rawValue == Subscriptions.lifeTime.rawValue
		} else {
			return false
		}
	}
}

//	MARK: purchase prmium check
extension SubscriptionManager {
	
	public func checkForCurrentSubscription(completionHandler: @escaping (_ isSubscribe: Bool) -> Void) {
		if #available(iOS 15.0, *) {
			Task {
				do {
					let isPurchasedPremium = try await subscription.purchaseProductsStatus()
					completionHandler(isPurchasedPremium)
				} catch {
					completionHandler(false)
				}
			}
		} else {
			self.iapSubscription.checkForCurrentSubscription { isPurchasePremium in
				completionHandler(isPurchasePremium)
			}
		}
	}
	
	public func getCurrentSubscriptionModel(completionHandler: @escaping (_ subsctiptionModel: CurrentSubscriptionModel?) -> Void) {
		
		if #available(iOS 15.0, *) {
			Task {
				do {
					let model = try await subscription.getCurrentSubscriptionModel()
					completionHandler(model)
				} catch {
					completionHandler(nil)
					debugPrint(error)
				}
			}
		} else {
			iapSubscription.getCurrentSubscriptionModel { model in
				completionHandler(model)
			}
		}
	}
}

//	MARK: pruchase premium {
extension SubscriptionManager {
	
	public func purchasePremium(of type: Subscriptions, completionHadnler: @escaping (_ purchased: Bool) -> Void) {
		if #available(iOS 15.0, *) {
			Task {
				let products = try await subscription.loadProducts()
				let product = products.first(where: {$0.id == type.rawValue})
				if let product = product {
					do {
						let purchase = try await subscription.purchase(product: product)
						if purchase.finishTransaction {
							self.saveSubscription(type)
							completionHadnler(true)
						} else {
							let isPurchasePremium = try await subscription.purchaseProductsStatus()
							completionHadnler(isPurchasePremium)
						}
					} catch {
						completionHadnler(false)
					}
				} else {
					completionHadnler(false)
				}
			}
		} else {
			self.iapSubscription.purchaseProduct(productType: type) { purchased in
				if purchased {
					self.saveSubscription(type)
				}
				completionHadnler(purchased)
				self.iapSubscription.updateSubscriptionStatus()
			}
		}
	}
}

//	MARK: restore purchase
extension SubscriptionManager {

	public func restorePurchase(completionHandler: @escaping (_ restored: Bool,_ requested: Bool,_ date: Date?) -> Void) {
		if #available(iOS 15.0, *) {
			Task {
				let requested = try await subscription.restorePurchase()
				if requested {
					let purchasePremium = try await subscription.purchaseProductsStatus()
					completionHandler(purchasePremium, requested, nil)
				} else {
					completionHandler(false, requested, nil)
				}
			}
		} else {
			self.iapSubscription.restoreSubscription { restored, expireDate in
				if !restored, let date = expireDate {
					self.iapSubscription.updateSubscriptionStatus()
					completionHandler(restored, true, date)
				} else {
					self.iapSubscription.updateSubscriptionStatus()
					completionHandler(restored, true, nil)
				}
			}
		}
	}
}

extension SubscriptionManager {
	
	public func changeCurrentSubscription() {
		
		if #available(iOS 15.0, *) {
			Task {
				do {
					if let scene = currentScene as? UIWindowScene {
						try await Subscription.manageSubscription(in: scene)
					}
				} catch {
					debugPrint(error)
				}
			}
		}
	}
}


//		MARK: product model helper
extension SubscriptionManager {
	
	public func descriptionModel(completionHandler: @escaping (_ model: [ProductStoreDesriptionModel]) -> Void) {
		
		if #available(iOS 15.0, *) {
			subscription.getProductDescription { model in
				completionHandler(model)
			}
		} else {
			iapSubscription.getProductDescription { models in
				completionHandler(models)
			}
		}
	}
	
	public func getLifeTimeDescription(completionHandler: @escaping (_ model: ProductStoreDesriptionModel?) -> Void) {
		if #available(iOS 15.0, *) {
			let model = subscription.getProductDesctiption(for: .lifeTime)
			completionHandler(model)
		} else {
			iapSubscription.getDescriptionForProduct(.lifeTime) { model in
				completionHandler(model)
			}
		}
	}
}
