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
}

typealias A = AlertManager
class AlertManager: NSObject {
    
    private static func showAlert(type: AlertType, actions: [UIAlertAction], cancelCompletion: (() -> Void)? = nil) {
        
		showAlert(type.alertTitle, message: type.alertMessage, actions: actions, withCancel: type.withCancel, style: type.alertStyle) {
            cancelCompletion?()
        }
    }
}


//    MARK: - PHASSET ALERTS -
extension AlertManager {
	
	static func deletePHAssets(of type: MediaContentType, of elementsCount: ElementhCount, completionHandler: @escaping () -> Void) {
		
		switch type {
			case .userPhoto:
				if elementsCount == .many {
					self.showDeletePHAssetAlert(of: .allowDeleteSelectedPhotos) {
						completionHandler()
					}
				} else {
					self.showDeletePHAssetAlert(of: .allowDeleteSelectedPhoto) {
						completionHandler()
					}
				}
			case .userVideo:
				if elementsCount == .many {
					self.showDeletePHAssetAlert(of: .allowDeleteSelectedVideos) {
						completionHandler()
					}
				} else {
					self.showDeletePHAssetAlert(of: .allowDeleteSelectedVideo) {
						completionHandler()
					}
				}
			default:
				return
		}
	}
	
	private static func showDeletePHAssetAlert(of alertType: AlertType, completionHandler: @escaping () -> Void) {
		
		let confirmDeleteAction = UIAlertAction(title: alertType.alertConfrimButtonTitle, style: .default) { _ in
			completionHandler()
		}
		
		showAlert(type: alertType, actions: [confirmDeleteAction])
	}
}

//      MARK: - CONTACTS ALERT -
extension AlertManager {
 
    /// `delete section`
    static func showSuxxessfullDeleted(for contacts: ElementhCount, completion: (() -> Void)? = nil) {
        
        let alertType: AlertType = contacts == .many ? .suxxessDeleteContacts : .suxxessDeleteContact
        showAlert(type: alertType, actions: []) {
            completion?()
        }
    }
    
    static func showDeleteContactsAlerts(for contacts: ElementhCount, completion: @escaping () -> Void) {
    
        let alertType: AlertType = contacts == .one ? .deleteContact : .deleteContacts
        
		let allowDeleteAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.delete.title, style: .default) { _ in
            completion()
        }
        
        showAlert(type: alertType, actions: [allowDeleteAction])
    }
    
    /// `merge section`
    static func showSuxxessFullMerged(for section: ElementhCount, completion: (() -> Void)? = nil) {
        let alertType: AlertType = section == .many ? .suxxessMergedContacts : .suxxessMergedContact
        showAlert(type: alertType, actions: []) {
            completion?()
        }
    }
    
    static func showMergeContactsAlert(for sections: ElementhCount, comletion: @escaping () -> Void) {
        
        let alertType: AlertType = sections == .one ? .mergeContact : .mergeContacts
        
		let allowMergeContacts = UIAlertAction(title: AlertHandler.AlertActionsButtons.merge.title, style: .default) { _ in
            comletion()
        }
        
        showAlert(type: alertType, actions: [allowMergeContacts])
    }
}

//		MARK: - stop search alerts -
extension AlertManager {
	
	static func showStopDeepCleanSearchProcess(_ completion: @escaping () -> Void) {
		
		let stopDeepCleanAlertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.stop.title, style: .default) { _ in
			completion()
		}
		
		showAlert(type: .setBreakDeepCleanSearch, actions: [stopDeepCleanAlertAction], cancelCompletion: nil)
	}
	
	static func showStopSingleSearchProcess(_ completion: @escaping () -> Void) {
		
		let stopSingleCleanAlertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.stop.title, style: .default) { _ in
			completion()
		}
		showAlert(type: .setBreakSingleCleanSearch, actions: [stopSingleCleanAlertAction], cancelCompletion: nil)
	}
	
	static func showStopSmartSingleSearchProcess(_ completion: @escaping () -> Void) {
		let stopSmartSingleCleanAlertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.stop.title, style: .default) { _ in
			completion()
		}
		
		showAlert(type: .setBreakSmartSingleCleanSearch, actions: [stopSmartSingleCleanAlertAction], cancelCompletion: nil)
	}
	
	static func showStopDeepCleanProcessing(_ completion: @escaping () -> Void) {
		
		let stopDeepCleanAlertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.stop.title, style: .default) { _ in
			completion()
		}
		showAlert(type: .setBreakDeepCleanDelete, actions: [stopDeepCleanAlertAction], cancelCompletion: nil)
	}
	
	static func showQuiteDeepCleanResults(_ completion: @escaping () -> Void) {
	
		let quiteDeepCleanAlertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.exit.title, style: .default) { _ in
			completion()
		}
		
		showAlert(type: .resetDeepCleanResults, actions: [quiteDeepCleanAlertAction], cancelCompletion: nil)
	}
}





extension AlertManager {

		/// default alert
		private static func showAlert(_ title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], withCancel: Bool = true, style: UIAlertController.Style, completion: (() -> Void)? = nil) {
		
			let alert = UIAlertController(title: title, message: message, preferredStyle: style)
			
			let cancelAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .cancel), style: .cancel) { action in
				completion?()
			}
			
			if actions.isEmpty {
				let alertAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .ok), style: .default) { _ in
					completion?()
				}
				alert.addAction(alertAction)
			} else {
				actions.forEach { (action) in
					alert.addAction(action)
				}
			}
			
			if withCancel {
				alert.addAction(cancelAction)
			}
			U.UI {
				topController()?.present(alert, animated: true, completion: nil)
			}
		}
}

#warning("REFACTORING -> > > > > ")

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
