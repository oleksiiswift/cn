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
    
    /// default alert
	static func showAlert(_ title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], withCancel: Bool = true, style: UIAlertController.Style, completion: (() -> Void)? = nil) {
	
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
		let cancelAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.cancel.title, style: .cancel) { action in
            completion?()
        }
        
        if actions.isEmpty {
			let alertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.ok.title, style: .default) { _ in
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
    
    private static func showPermissionAlert(alerttype: AlertType, actions: [UIAlertAction], cancelAction: @escaping (_ isDennyAccess: Bool) -> Void) {
        
        let alertController = UIAlertController(title: alerttype.alertTitle, message: alerttype.alertMessage, preferredStyle: alerttype.alertStyle)
        
		let cancelAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.cancel.title, style: .default) { (_) in
            
            cancelAction(false)
        }
        alertController.addAction(cancelAction)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        
        U.UI {
            topController()?.present(alertController, animated: true)
        }
    }
}

//	MARK: - ACCESS ARTS, PERMISSION, SETTINGS, RESTRICTED -
extension AlertManager {
	
	static func showResrictedAlert(by type: AlertType, completionHandler: @escaping () -> Void) {
		
		let settingsAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.settings.title, style: .default) { _ in
			U.openSettings()
		}
		
		self.showAlert(type: type, actions: [settingsAction]) {
			completionHandler()
		}
	}
	
    
    static func showOpenSettingsAlert(_ alertType: AlertType) {
        
		let settingsAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.settings.title, style: .default, handler: openSetting(action:))
        
        showPermissionAlert(alerttype: alertType, actions: [settingsAction]) { isCancel in
            debugPrint(isCancel)
        }
    }
    
    private static func openSetting(action: UIAlertAction) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension AlertManager {
	
	public static func showAtLeastOneMediaPermissionAlert(at viewController: UIViewController) {
		let alertText = TempText.getAtLeastOnePermissionText()
		self.showAlert(with: alertText, at: viewController) {}
	}
	
	public static func showDeniedAlert(_ permission: Permission, at viewController: UIViewController) {
		let alertText = TempText.getDeniedPermissionText()
		self.showAlert(with: alertText, at: viewController) {
			UIPresenter.openSettingPage()
		}
	}
	
	public static func showDeniedDeepClean(at viewController: UIViewController) {
		let alertText = TempText.getDeniedDeepCleanPermission()
		self.showAlert(with: alertText, at: viewController) {
			UIPresenter.openSettingPage()
		}
	}
	
	public static func showApptrackerPerformAlert(at viewController: UIViewController, completion: @escaping () -> Void) {
		let alertText = TempText.getApptrackerPermissionText()
		self.showAlert(with: alertText, at: viewController) {
			completion()
		}
	}
	
	private static func showAlert(with text: AlertTextStrings, at viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		let alertController = UIAlertController(title: text.title, message: text.description, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: text.cancel, style: .cancel)
		let action = UIAlertAction(title: text.action, style: .default) { _ in
			completionHandler()
		}
		alertController.addAction(action)
		text.cancel != "" ?  alertController.addAction(cancelAction) : ()
		viewController.present(alertController, animated: true, completion: nil)
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
    
    static func showEmptyContactsToPresent(of type: AlertType, completion: @escaping () -> Void) {
        
		ErrorHandler.shared.showEmptySearchResultsFor(type) {
			completion()
		}
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
	
	public static func showSelectAllStarterAlert(for type: PhotoMediaType, completionHandler: @escaping () -> Void) {
		
		let alertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.selectAll.title, style: .default) { _ in
			completionHandler()
		}
		
		let alertMessage = AlertHandler.getSelectableAutimaticAletMessage(for: type)
		
		
		showAlert("Select Items?", message: alertMessage, actions: [alertAction], withCancel: true, style: .alert, completion: nil)
	}
}

extension AlertManager {
	
	public static func showCompressionVideoFileComplete(fileSize: String, shareCompletionHandler: @escaping () -> Void, savedInPhotoLibraryCompletionHandler: @escaping () -> Void) {
		
		let shareAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.share.title,
										style: .default) { _ in
			shareCompletionHandler()
		}
		let saveAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.save.title,
									   style: .default) { _ in
			savedInPhotoLibraryCompletionHandler()
		}
	
		let type: AlertType = .compressionvideoFileComplete
		let message = type.alertMessage! + fileSize
		
		showAlert(type.alertTitle, message: message, actions: [shareAction, saveAction], withCancel: type.withCancel, style: type.alertStyle) {}
	}
}
