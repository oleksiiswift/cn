//
//  Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import Foundation
import StoreKit

enum ProductValidator {
	case production
	case sandbox
}

@available(iOS 15.0, *)
typealias UpdateTransActionBlock = ((Transaction) async -> ())
@available(iOS 15.0, *)
typealias RenewalState = Product.SubscriptionInfo.RenewalState

@available(iOS 15.0, *)
class Subscription {
	
	public static var shared = Subscription()
	
	public var products: [Product] = []
	
	private var service = SubscriptionService()
	private var updateListener: Task <(), Never>? = nil
	
	public func initialize() {
		Task {
			try await self.loadProducts()
		}
		self.setListener(finishTransaction: false) { transaction in
			await transaction.finish()
		}
	}
	
	public func loadProducts() async throws -> [Product] {
		let productsIDs: Set<String> = Set(Subscriptions.allCases.map({$0.rawValue}))
		let products = try await self.getPurchaseProducts(from: productsIDs)
		return products
	}
		
	public func purchase(product: Product, validator: ProductValidator) async throws -> Purchase {
		try await self.service.purchase(product: product, service: validator)
	}
	
	public func getPurchaseProducts(from ids: Set<String>) async throws -> [Product] {
		try await self.service.loadProducts(from: ids)
	}
	
	public func setListener(finishTransaction: Bool = true, updateBlock: UpdateTransActionBlock?) {
		
		let task = Task.detached {
			
			for await result in Transaction.updates {
				do {
					let transaction = try self.service.checkVerificationResult(result)
					finishTransaction ? await transaction.finish() : ()
					await updateBlock?(transaction)
				} catch {
					ErrorHandler.shared.showSubsritionAlertError(for: .verificationError)
				}
			}
		}
		self.updateListener = task
	}

	public func restorePurchase() async throws -> Bool {
		return ((try? await AppStore.sync()) != nil)
	}
	
	public func getCurrentSubscription(renewable: Bool = true) async throws -> [String] {
		return try await self.service.getCurrentSubsctiption(renewable: renewable).map({$0.productID})
	}
	
	public static func manageSubscription(in scene: UIWindowScene) async throws {
		try await AppStore.showManageSubscriptions(in: scene)
	}
}

@available(iOS 15.0, *)
extension Subscription {
	
	private func getProduct(by type: Subscriptions) -> Product? {
		
		if let product = self.products.first(where: {$0.id == type.rawValue}) {
			return product
		}
		return nil
	}
	
	public func getProductDescription() -> [ProductStoreDesriptionModel] {
		
		var descriptionsModel: [ProductStoreDesriptionModel] = []
		
		if !self.products.isEmpty {
			for product in products {
				if product.id != Subscriptions.lifeTime.rawValue {
					let model = getDescription(for: product)
					descriptionsModel.append(model)
				}
			}
		}
		return descriptionsModel
	}
	
	public func getProductDesctiption(for type: Subscriptions) -> ProductStoreDesriptionModel? {
		
		guard let product = self.getProduct(by: type) else { return nil}

		var description = product.description
		var period = ""
		
		if let subscriptionPeriod = product.subscription?.subscriptionPeriod {
			if let unitName = getUnitName(unit: subscriptionPeriod.unit, value: subscriptionPeriod.value) {
				period = unitName
			}
		}
		
		if let introductoryPeriod = product.subscription?.introductoryOffer {
			description = introductoryPeriod.period.debugDescription + "\n" + introductoryPeriod.paymentMode.rawValue
		}
		
		let model = ProductStoreDesriptionModel(name: product.displayName,
												price: product.displayPrice,
												period: period,
												description: description, id: product.id)
		return model
	}
	
	
	public func getDescription(for product: Product) -> ProductStoreDesriptionModel {

		var description = product.description
		var period = ""

		if let subscriptionPeriod = product.subscription?.subscriptionPeriod {
			if let unitName = getUnitName(unit: subscriptionPeriod.unit, value: subscriptionPeriod.value) {
				period = unitName
			}
		}
		
		if let introductoryPeriod = product.subscription?.introductoryOffer {
			description = introductoryPeriod.period.debugDescription + "\n" + introductoryPeriod.paymentMode.rawValue
		}
		
		let model = ProductStoreDesriptionModel(name: product.displayName,
												price: product.displayPrice,
												period: period,
												description: description, id: product.id)
		return model
	}
}



@available(iOS 15.0, *)
extension Subscription {
	
	private func getUnitName(unit: Product.SubscriptionPeriod.Unit, value: Int) -> String? {
		
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
