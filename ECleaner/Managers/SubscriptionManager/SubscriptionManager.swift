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
			return U.userDefaults.bool(forKey: C.key.inApPurchse.purchasePremium)
		} set {
			if purchasedPremium != newValue {
				debugPrint("****")
				debugPrint("premium status did change -> \(newValue)")
				debugPrint("*****")
				let userInfo = [C.key.inApPurchse.purchasePremium: newValue]
				U.userDefaults.set(newValue, forKey: C.key.inApPurchse.purchasePremium)
				do {
					U.notificationCenter.post(name: .premiumDidChange, object: nil, userInfo: userInfo)
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
	
	public func purchasePremiumHandler() -> Bool {
		return self.purchasedPremium
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
			#warning("TODO")
			debugPrint("for lower ios version")
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
					#warning("TODO ALERt")
//					ErrorHandler.shared.showSubsritionAlertError(for: .productsError)
				}
			}
		} else {
			self.iapSubscription.purchaseProduct(productType: type) { purchased in
				#warning("TODO!!!!!")
				debugPrint(purchased)
			}
		}
	}
}

//	MARK: restore purchase
extension SubscriptionManager {

	public func restorePurchase(completionHandler: @escaping (_ restored: Bool,_ requested: Bool) -> Void) {
		if #available(iOS 15.0, *) {
			Task {
				let requested = try await subscription.restorePurchase()
				if requested {
					let purchasePremium = try await subscription.purchaseProductsStatus()
					completionHandler(purchasePremium, requested)
				} else {
					completionHandler(false, requested)
				}
			}
		} else {
			self.iapSubscription.restoreSubscription { restored in
				#warning("TODO!!!")
				debugPrint(restored)
			}
		}
	}
	
}


//		MARK: product model helper
extension SubscriptionManager {
	
	public func descriptionModel() -> [ProductStoreDesriptionModel] {
		
		if #available(iOS 15.0, *) {
			return subscription.getProductDescription()
		} else {
			#warning("TODO")
			return []
		}
	}
}






