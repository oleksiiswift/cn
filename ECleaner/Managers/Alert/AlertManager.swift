//
//  AlertManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import UIKit
import Photos

enum ElementhCount {
    case one
    case many
    case other
	
	static func getRaw(from int: Int) -> ElementhCount {
		return int == 1 ? .one : .many
	}
}

typealias A = AlertManager
class AlertManager: NSObject {}

//		MARK: handle delete alert
extension AlertManager {
	
	public static func showDeleteAlert(with media: MediaContentType, of elementsCount: ElementhCount, completionHandler: @escaping () -> Void) {
		
		switch media {
			case .userPhoto:
				switch elementsCount {
					case .one:
						self.presentDeleteAlert(of: .deletePhoto) {
							completionHandler()
						}
					case .many:
						self.presentDeleteAlert(of: .deletePhotos) {
							completionHandler()
						}
					case .other:
						return
				}
			case .userVideo:
				switch elementsCount {
					case .one:
						self.presentDeleteAlert(of: .deleteVideo) {
							completionHandler()
						}
					case .many:
						self.presentDeleteAlert(of: .deleteVideos) {
							completionHandler()
						}
					case .other:
						return
				}
			case .userContacts:
				switch elementsCount {
					case .one:
						self.presentDeleteAlert(of: .deleteContact) {
							completionHandler()
						}
					case .many:
						self.presentDeleteAlert(of: .deleteContacts) {
							completionHandler()
						}
					case .other:
						return
				}
			default:
				return
		}
	}
	
	public static func showDeleteLocationsAlert(_ completionHandler: @escaping () -> Void) {
		self.presentDeleteAlert(of: .deleteLocations) {
			completionHandler()
		}
	}
	
	private static func presentDeleteAlert(of alertType: AlertType, completionHandler: @escaping () -> Void) {
		
		let description = alertType.deleteAlertDesctiprtion
		let confirmAction = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler()
		}
		self.presentDefaultAlert(title: description.title, message: description.description, actions: [confirmAction], style: alertType.alertStyle, withCancel: alertType.withCancel)
	}
}

extension AlertManager {
	
	public static func showDeepCleanProcessing(with state: DeepCleanCompleteStateHandler, completionHandler: (() -> Void)? = nil) {
		let description = state.description
		let action = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler?()
		}
		self.presentDefaultAlert(title: description.title, message: description.description, actions: [action], style: .alert, withCancel: true)
	}
}

extension AlertManager {
	
	public static func showOperationProcessing(with state: SearchOperationStateHandler, completionHandler: @escaping () -> Void) {
		let description = state.description
		
		let action = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler()
		}
		
		self.presentDefaultAlert(title: description.title, message: description.description, actions: [action], style: .alert, withCancel: true)
	}
}


extension AlertManager {
	
	public static func showAlert(for alertType: AlertType, completionHandler: @escaping () -> Void) {
		let description = alertType.alertDescription
		let confirmAction = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler()
		}
		self.presentDefaultAlert(title: description.title, message: description.description, actions: [confirmAction], style: alertType.alertStyle, withCancel: alertType.withCancel)
	}
}


	//		MARK: handle error results, error for data
extension AlertManager {
	
	public static func presentErrorAlert(with description: ErrorDescription, completionHandler: (() -> Void)? = nil) {
		
		let alertController = UIAlertController(title: description.title, message: description.message, preferredStyle: .alert)
		let alertAction = UIAlertAction(title: description.buttonTitle, style: .default) { _ in
			completionHandler?()
		}
		alertController.addAction(alertAction)
		
		DispatchQueue.main.async {
			if let topController = getTheMostTopController() {
				topController.present(alertController, animated: true)
			}
		}
	}
}

//		MARK: compression action sheet
extension AlertManager {
	
	public static func showCompressionVideoFileComplete(fileSize: String, shareCompletionHandler: @escaping () -> Void, savedInPhotoLibraryCompletionHandler: @escaping () -> Void) {
		let alertType: AlertType = .compressionvideoFileComplete
		let title = alertType.alertTitle
		let message = alertType.alertMessage + fileSize
		let shareAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .share), style: .default) { _ in
			shareCompletionHandler()
		}
		let saveAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .save), style: .default) { _ in
			savedInPhotoLibraryCompletionHandler()
		}
		self.presentDefaultAlert(title: title, message: message, actions: [shareAction, saveAction], style: alertType.alertStyle, withCancel: true)
	}
}

extension AlertManager {
	
	private static func presentDefaultAlert(title: String, message: String, actions: [UIAlertAction], style: UIAlertController.Style, withCancel: Bool) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
		actions.forEach { action in
			alertController.addAction(action)
		}
		let cancelAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .cancel), style: .cancel)
		withCancel ? alertController.addAction(cancelAction) : ()
		U.UI {
			if let topController = getTheMostTopController() {
				topController.present(alertController, animated: true, completion: nil)
			}
		}
	}
}


extension AlertManager {
	
	public static func showPurchaseAlert(of errorType: ErrorHandler.SubscriptionError, at viewController: UIViewController, expireDate: String? = nil) {
		
		let alertDescription = errorType.alertDescription
		let confirmAction = UIAlertAction(title: alertDescription.action, style: .default) { _ in }
		
		var message: String {
			if let expireDate = expireDate {
				return Localization.Subscription.Premium.expireSubscription + " " + expireDate
			} else {
				return alertDescription.description
			}
		}
		
		let alertController = UIAlertController(title: alertDescription.title, message: message, preferredStyle: .alert)
		alertController.addAction(confirmAction)
		DispatchQueue.main.async {
			viewController.present(alertController, animated: true)
		}
	}
}

extension AlertManager {
	
	public static func showNetworkError(with description: AlertDescription, at viewController: UIViewController) {
		let alertController = UIAlertController(title: description.title, message: description.description, preferredStyle: .alert)
		let action = UIAlertAction(title: description.action, style: .default) { _ in }
		alertController.addAction(action)
		DispatchQueue.main.async {
			viewController.present(alertController, animated: true)
		}
	}
}

extension AlertManager {
	
	public static func showLimitAccessAlert(with description: AlertDescription, at viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		let title = !description.title.isEmpty ? description.title : nil
		
		let alertController = UIAlertController(title: title,
												message: description.description,
												preferredStyle: .alert)
		let action = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler()
		}
		alertController.addAction(action)
		
		if !description.cancel.isEmpty {
			let cancel = UIAlertAction(title: description.cancel, style: .cancel) { _ in }
			alertController.addAction(cancel)
		}
		
		DispatchQueue.main.async {
			viewController.present(alertController, animated: true)
		}
	}
}
