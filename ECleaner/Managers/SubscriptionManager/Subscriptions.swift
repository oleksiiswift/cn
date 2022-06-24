//
//  Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import Foundation
import StoreKit

struct SubscribeType {
	#warning("TODO")
	var id: String
	var price: String
	var trial: String
	var title: String
	var subtitle: String
}

class ProductStoreDesriptionModel {

	var productName: String
	var productPrice: String
	var description: String

	init(name: String, price: String, description: String) {
		self.productName = name
		self.productPrice = price
		self.description = description
	}
}

enum Subscriptions: String, CaseIterable {

	case week = 	"week_cleaner"
	case month = 	"month_cleaner"
	case year = 	"year_cleaner"
	case lifeTime = "lifetime_cleaner"
}

@available(iOS 15.0, *)
struct Purchase {
	
	public let product: Product
	public let transaction: Transaction
	public let finishTransaction: Bool
	
	public var productID: String {
		transaction.productID
	}
	
	public var quantity: Int {
		transaction.purchasedQuantity
	}
	
	public func didFinishTransaction() async {
		await transaction.finish()
	}
}
