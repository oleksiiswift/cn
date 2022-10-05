//
//  AlertManager+Permission.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

	//		MARK: - PERMISSION ALERTS HANDLER -
extension AlertManager {
	
	public static func showPermissionAlert(of alertType: AlertPermissionType, at viewController: UIViewController, for permission: Permission? = nil, completionHandler: (() -> Void)? = nil) {
		
		switch alertType {
			case .appTracker:
				self.showApptrackerPerformAlert(at: viewController) {
					completionHandler?()
				}
			case .deniedDeepClean:
				self.showDeniedDeepClean(at: viewController)
			case .openSettings:
				guard let _ = permission else { return }
				self.showDeniedAlert(permission!, at: viewController)
			case .onePermissionRule:
				self.showAtLeastOneMediaPermissionAlert(at: viewController)
			case .restrictedContacts:
				self.showRestrictedErrorAlert(.contactsRestrictedError, at: viewController)
			case .restrictedPhotoLibrary:
				self.showRestrictedErrorAlert(.photoLibraryRestrictedError, at: viewController)
		}
	}
}

	/// `private methods for internal use ->`
extension AlertManager {
	
			///  `restricted alerts`
	private static func showRestrictedErrorAlert(_ errorHandler: ErrorHandler.AccessRestrictedError, at viewController: UIViewController) {
		let errorHandlerDescription = errorHandler.alertDescription
		self.presentAlert(with: errorHandlerDescription, at: viewController) {
			UIPresenter.openSettingPage()
		}
	}
			///  `all media are denied access`
	private static func showAtLeastOneMediaPermissionAlert(at viewController: UIViewController) {
		let description = LocalizationService.Alert.Permissions.getAtLeastOnePermissionDescription()
		self.presentAlert(with: description, at: viewController) {}
	}
	
			/// `denies permission from permission screen`
	private static func showDeniedAlert(_ permission: Permission, at viewController: UIViewController) {
		let description = LocalizationService.Alert.Permissions.getOpenSettingsPermissionDescription(for: permission.authorized)
		self.presentAlert(with: description, at: viewController) {
			UIPresenter.openSettingPage()
		}
	}
	
			/// `deep clean restricted alert`
	private static func showDeniedDeepClean(at viewController: UIViewController) {
		let description = LocalizationService.Alert.Permissions.getDeniedDeepCleanPermissionDescription()
		self.presentAlert(with: description, at: viewController) {
			UIPresenter.openSettingPage()
		}
	}
			/// `àpp tracker alert `
	private static func showApptrackerPerformAlert(at viewController: UIViewController, completion: @escaping () -> Void) {
		let description = LocalizationService.Alert.Permissions.getApptrackerPermissionDescription()
		self.presentAlert(with: description, at: viewController) {
			completion()
		}
	}
}

extension AlertManager {
	
	/// `èxecution alert `
	private static func presentAlert(with description: AlertDescription, at viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		let alertController = UIAlertController(title: description.title, message: description.description, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: description.cancel, style: .cancel)
		let action = UIAlertAction(title: description.action, style: .default) { _ in
			completionHandler()
		}
		alertController.addAction(action)
		description.cancel.isEmpty ? () : alertController.addAction(cancelAction)
		DispatchQueue.main.async {
			viewController.present(alertController, animated: true, completion: nil)			
		}
	}
}
