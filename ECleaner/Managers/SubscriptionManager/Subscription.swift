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
		
		for product in products {
			debugPrint(product)
		}
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
	
	public func getProductDesctiption(for type: Subscriptions) -> ProductStoreDesriptionModel? {
		
		
		guard let product = self.getProduct(by: type) else { return nil}
		
		let model = ProductStoreDesriptionModel(name: product.displayName,
												price: product.displayPrice,
												description: product.description)
		return model
	}
}
