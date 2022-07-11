//
//  Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import Foundation
import StoreKit

enum Subscriptions: String, CaseIterable {

	case month = 	"month_cleaner"
	case year = 	"year_cleaner"
	case week = 	"week_cleaner"
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


struct CurrentSubscriptionModel {
	
	var expireDate: String
	var name: String
	
	init(expireDate: String, name: String) {
		self.expireDate = expireDate
		self.name = name
	}
}
