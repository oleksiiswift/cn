//
//  AlertManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import UIKit

enum ElementhCount {
    case one
    case many
    case other
}

typealias A = AlertManager
class AlertManager: NSObject {
    
    private static func showAlert(type: AlertType, actions: [UIAlertAction], withCancel: Bool = true, cancelCompletion: (() -> Void)? = nil) {
        
        showAlert(type.alertTitle, message: type.alertMessage, actions: actions, withCancel: withCancel) {
            cancelCompletion?()
        }
    }
    
    /// default alert
    static func showAlert(_ title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], withCancel: Bool = true, completion: (() -> Void)? = nil) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { action in
            completion?()
        }
        
        if actions.isEmpty {
            let alertAction = UIAlertAction(title: "ok", style: .default) { _ in
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
        
        let cancelAction = UIAlertAction(title: "loco cancel", style: .default) { (_) in
            
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
		
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
			U.openSettings()
		}
		
		self.showAlert(type: type, actions: [settingsAction], withCancel: true) {
			completionHandler()
		}
	}
	
    
    static func showOpenSettingsAlert(_ alertType: AlertType) {
        
        let settingsAction = UIAlertAction(title: "loco open settings title", style: .default, handler: openSetting(action:))
        
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

//    MARK: - PHASSET ALERTS -
extension AlertManager {
    
    static func showDeletePhotoAssetsAlert(completion: @escaping () -> Void) {
      
        let allowDeleteAction = UIAlertAction(title: "loco delete?", style: .default) { _ in
            completion()
        }
        
        showAlert(type: .allowDeleteSelectedPhotos, actions: [allowDeleteAction], withCancel: true) {}
    }
}

//      MARK: - CONTACTS ALERT -
extension AlertManager {
 
    /// `delete section`
    static func showSuxxessfullDeleted(for contacts: ElementhCount, completion: (() -> Void)? = nil) {
        
        let alertType: AlertType = contacts == .many ? .suxxessDeleteContacts : .suxxessDeleteContact
        showAlert(type: alertType, actions: [], withCancel: alertType.withCancel) {
            completion?()
        }
    }
    
    static func showDeleteContactsAlerts(for contacts: ElementhCount, completion: @escaping () -> Void) {
    
        let alertType: AlertType = contacts == .one ? .deleteContact : .deleteContacts
        
        let allowDeleteAction = UIAlertAction(title: "ok", style: .default) { _ in
            completion()
        }
        
        showAlert(type: alertType, actions: [allowDeleteAction], withCancel: alertType.withCancel)
    }
    
    /// `merge section`
    static func showSuxxessFullMerged(for section: ElementhCount, completion: (() -> Void)? = nil) {
        let alertType: AlertType = section == .many ? .suxxessMergedContacts : .suxxessMergedContact
        showAlert(type: alertType, actions: [], withCancel: alertType.withCancel) {
            completion?()
        }
    }
    
    static func showMergeContactsAlert(for sections: ElementhCount, comletion: @escaping () -> Void) {
        
        let alertType: AlertType = sections == .one ? .mergeContact : .mergeContacts
        
        let allowMergeContacts = UIAlertAction(title: "ok", style: .default) { _ in
            comletion()
        }
        
        showAlert(type: alertType, actions: [allowMergeContacts], withCancel: alertType.withCancel)
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
		
		let stopDeepCleanAlertAction = UIAlertAction(title: "stop", style: .default) { _ in
			completion()
		}
		
		showAlert(type: .setBreakDeepCleanSearch, actions: [stopDeepCleanAlertAction], withCancel: true, cancelCompletion: nil)
	}
	
	static func showStopSingleSearchProcess(_ completion: @escaping () -> Void) {
		
		let stopSingleCleanAlertAction = UIAlertAction(title: "stop", style: .default) { _ in
			completion()
		}
		showAlert(type: .setBreakSingleCleanSearch, actions: [stopSingleCleanAlertAction], withCancel: true, cancelCompletion: nil)
	}
	
	static func showStopDeepCleanProcessing(_ completion: @escaping () -> Void) {
		
		let stopDeepCleanAlertAction = UIAlertAction(title: "stop", style: .default) { _ in
			completion()
		}
		showAlert(type: .setBreakDeepCleanDelete, actions: [stopDeepCleanAlertAction], withCancel: true, cancelCompletion: nil)
	}
	
	static func showQuiteDeepCleanResults(_ completion: @escaping () -> Void) {
	
		let quiteDeepCleanAlertAction = UIAlertAction(title: "exit", style: .default) { _ in
			completion()
		}
		
		showAlert(type: .resetDeepCleanResults, actions: [quiteDeepCleanAlertAction], withCancel: true, cancelCompletion: nil)
	}
}


extension AlertManager {
	
	public static func showSelectAllStarterAlert(for type: PhotoMediaType, completionHandler: @escaping () -> Void) {
		
		let alertAction = UIAlertAction(title: "Select all", style: .default) { _ in
			completionHandler()
		}
		
		let alertMessage = AlertHandler.getSelectableAutimaticAletMessage(for: type)
		
		
		showAlert("Select Items?", message: alertMessage, actions: [alertAction], withCancel: true, completion: nil)
	}
}
