//
//  ProductStoreDesriptionModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.07.2022.
//

import Foundation

class ProductStoreDesriptionModel {

	var productName: String
	var productPrice: String
	var productPeriod: String
	var description: String
	var id: String

	init(name: String, price: String, period: String, description: String, id: String) {
		self.productName = name
		self.productPrice = price
		self.productPeriod = period
		self.description = description
		self.id = id
	}
}
