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
				return Localization.ErrorsHandler.PurchaseError.purchaseIsCanceled
			case .refundsCanceled:
				return Localization.ErrorsHandler.PurchaseError.refundsCanceled
			case .purchasePending:
				return Localization.ErrorsHandler.PurchaseError.purchaseIsPending
			case .verificationError:
				return Localization.ErrorsHandler.PurchaseError.verificationError
			case .error:
				return Localization.ErrorsHandler.PurchaseError.error
			case .productsError:
				return Localization.ErrorsHandler.PurchaseError.productsError
		}
	}
	
	@available(iOS 15.0, *)
	private func loadStoreError(for key: StoreError) -> String {
		switch key {
			case .storeKit(let storeKitError):
				switch storeKitError {
					case .networkError(_):
						return Localization.ErrorsHandler.PurchaseError.networkError
					case .systemError(_):
						return Localization.ErrorsHandler.PurchaseError.systemError
					case .userCancelled:
						return Localization.ErrorsHandler.PurchaseError.userCancelled
					case .notAvailableInStorefront:
						return Localization.ErrorsHandler.PurchaseError.notAvailableInStorefront
					default:
						return Localization.ErrorsHandler.PurchaseError.unknown
				}
			case .purchase(_):
				return Localization.ErrorsHandler.PurchaseError.productsError
			case .verification(_):
				return Localization.ErrorsHandler.PurchaseError.verificationError
		}
	}
	
	public func showSubsritionAlertError(for key: SubscriptionError) {
		debugPrint("show error alert with key \(self.loadError(for: key))")
		let errorAction = UIAlertAction(title: "Ok", style: .default) { _ in }
		
		#warning("TODO ALERT Subscript")
//
//		A.showAlert("store error", message: self.loadError(for: key), actions: [errorAction], withCancel: false, style: .alert) {}
	}
	
	@available(iOS 15.0, *)
	public func showSubscriptionStoreError(for key: StoreError) {
		debugPrint("show error alert with key \(self.loadStoreError(for: key))")

	}
}
