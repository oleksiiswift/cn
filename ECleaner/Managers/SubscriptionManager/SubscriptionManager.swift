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
	
	private var productValidator: ProductValidator = .sandbox
	
	@available(iOS 15.0, *)
	private lazy var subscription = Subscription.shared
	private var iapSubscription = InAppSubscription.shared
	
	private var purchasedPremium: Bool {
		get {
			return U.userDefaults.bool(forKey: C.key.inApPurchse.purchasePremium)
		} set {
			if purchasedPremium != newValue {
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
	
	public func setPurchasePrmium(_ purchased: Bool) {
		self.purchasedPremium = purchased
	}
	
	public func purchasePremium() -> Bool {
		return self.purchasedPremium
	}
	
	public func purchasePremium(of type: Subscriptions, with validator: ProductValidator) {
		if #available(iOS 15.0, *) {
			Task {
				let products = try await subscription.loadProducts()
				let product = products.first(where: {$0.id == type.rawValue})
				if let product = product {
					let purchase =  try await subscription.purchase(product: product, validator: self.productValidator)
					debugPrint(purchase)
				} else {
					ErrorHandler.shared.showSubsritionAlertError(for: .productsError)
				}
			}
		} else {
			self.iapSubscription.purchaseProduct(productType: type) { purchased in
				debugPrint(purchased)
			}
		}
	}
	
	public func restorePurchase() {
		if #available(iOS 15.0, *) {
			Task {
				let _ = try await subscription.restorePurchase()
				/// tofdo smth handle transactions s
			}
		} else {
			self.iapSubscription.restoreSubscription { restored in
				debugPrint(restored)
			}
		}
	}
}






