//
//  Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import Foundation
import StoreKit

@available(iOS 15.0, *)
typealias UpdateTransActionBlock = ((Transaction) async -> ())
@available(iOS 15.0, *)
typealias RenewalState = Product.SubscriptionInfo.RenewalState

@available(iOS 15.0, *)
class Subscription {
	
	public static var shared = Subscription()
	
	public var products: [Product] = []
	
	public var service = SubscriptionService()
	private var manager = SubscriptionManager.instance
	private var updateListener: Task <(), Never>? = nil
	
	public func initialize() {
		Task {
			do {
				let products = try await self.loadProducts()
				if !products.isEmpty {
					let isPurchased = try await self.purchaseProductsStatus()
					debugPrint("****")
					debugPrint("products is purchased -> \(isPurchased)")
					debugPrint("****")
				}
			} catch {
				debugPrint("error load keys and subcription")
			}
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
		
	public func purchase(product: Product) async throws -> Purchase {
		let purchase = try await self.service.purchase(product: product)
		return purchase
	}
	
	public func handleStatus(with product: Product) async throws -> Bool{
			let isPurchased = try await self.service.handleStatus(with: product)
			return isPurchased
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
					if let topController = getTheMostTopController() {
						ErrorHandler.shared.showSubsriptionAlertError(for: .verificationError, at: topController)
					}
				}
			}
		}
		self.updateListener = task
	}

	public func restorePurchase() async throws -> Bool {
		return ((try? await AppStore.sync()) != nil)
	}
	
	public func isLifeTimeSubscription() async throws -> Bool {
		let productID = try await self.getCurrentSubscription()
		let subscription = Subscriptions.allCases.first(where: {$0.rawValue == productID.first})
		return subscription == Subscriptions.lifeTime
	}
	
	private func getCurrentSubscription(renewable: Bool = true) async throws -> [String] {
		return try await self.service.getCurrentSubsctiption(renewable: renewable).map({$0.productID})
	}
	
	public func getCurrentSubscriptionModel() async throws -> CurrentSubscriptionModel? {
		
		var id: String = SettingsManager.subscripton.currentSubscriptionID
		var date: String = SettingsManager.subscripton.currentExprireSubscriptionDate
	
		do {
			let productID = try await self.getCurrentSubscription()
			let subscription = Subscriptions.allCases.first(where: {$0.rawValue == productID.first})
			
			if let currentSubscription = subscription, let productDescription = self.getProductDesctiption(for: currentSubscription) {
				SettingsManager.subscripton.currentSubscriptionID = productDescription.id
				id = productDescription.productName
			}
			
			let currentTransaction = try await self.service.getCurrentSubsctiption()
			
			if let expireDate = currentTransaction.first?.expirationDate {
				let stringdate = Utils.getString(from: expireDate, format: Constants.dateFormat.expiredDateFormat)
				SettingsManager.subscripton.currentExprireSubscriptionDate = stringdate
				date = stringdate
			}
			if let currebtSubscription = subscription {
				return CurrentSubscriptionModel(expireDate: date, id: id, subscription: currebtSubscription)
			}
		} catch {
			debugPrint(error)
		}
		return nil
	}
	
	public func purchaseProductsStatus() async throws -> Bool {
		
		do {
			let ids = try await self.getCurrentSubscription()
			
			let products = try await self.loadProducts()
			
			if !ids.isEmpty, let purchasedProductID = ids.first, try await service.isProductPurchased(productId: purchasedProductID) {
				
				if let product = products.first(where: {$0.id == purchasedProductID}) {
					let subscription = Subscriptions.allCases.first(where: {$0.rawValue == product.id})
					manager.saveSubscription(subscription)
					self.manager.setPurchasePremium(true)
					return true
				}
			}
			 
			self.manager.setPurchasePremium(false)
			manager.saveSubscription(nil)
			return false
		} catch {
			debugPrint("error for cant load")
		}
		return false
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
	
	public func getProductDescription(completionHandler: @escaping (_ model: [ProductStoreDesriptionModel]) -> Void) {
		
		var descriptionsModel: [ProductStoreDesriptionModel] = []
		
		if !self.products.isEmpty {
			for product in products {
				if product.id != Subscriptions.lifeTime.rawValue {
					let model = getDescription(for: product)
					descriptionsModel.append(model)
				}
			}
		}
		completionHandler(descriptionsModel)
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
