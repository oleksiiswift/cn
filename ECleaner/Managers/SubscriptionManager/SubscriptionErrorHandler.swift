//
//  SubscriptionErrorHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.05.2022.
//

import StoreKit

extension ErrorHandler {
	
	enum SubscriptionError: Error {
		case purchaseCanceled
		case refundsCanceled
		case purchasePending
		case verificationError
		case error
		case productsError
	}
	
	@available(iOS 15, *)
	enum StoreError: Error {
		case storeKit(error: StoreKitError)
		case purchase(error: Product.PurchaseError)
		case verification(error: VerificationResult<Any>.VerificationError)
	}
	
	private func loadError(for key: SubscriptionError) -> String {
		switch key {
			case .purchaseCanceled:
				return "Purchase is canceled"
			case .refundsCanceled:
				return "refun is canceled"
			case .purchasePending:
				return "purchase is pending"
			case .verificationError:
				return "verification error"
			case .error:
				return "error"
			case .productsError:
				return "cant load products"
		}
	}
	
	@available(iOS 15.0, *)
	private func loadStoreError(for key: StoreError) -> String {
		switch key {
			case .storeKit(let error):
				return error.localizedDescription
			case .purchase(let error):
				return error.localizedDescription
			case .verification(let error):
				return error.localizedDescription
		}
	}
		
	public func showSubsritionAlertError(for key: SubscriptionError) {
		debugPrint("show error alert with key \(self.loadError(for: key))")
		let errorAction = UIAlertAction(title: "Ok", style: .default) { _ in }
		
		A.showAlert("store error", message: self.loadError(for: key), actions: [errorAction], withCancel: false, style: .alert) {}
	}
	
	@available(iOS 15.0, *)
	public func showSubscriptionStoreError(for key: StoreError) {
		debugPrint("show error alert with key \(self.loadStoreError(for: key))")

	}
}
