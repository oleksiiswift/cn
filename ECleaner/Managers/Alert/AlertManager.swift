//
//  AlertManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import UIKit
import cisua

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
        
        let cancelAction = UIAlertAction(title: "loco cancel", style: .cancel) { action in
            completion?()
        }
        
        actions.forEach { (action) in
            alert.addAction(action)
        }
        
        if withCancel {
            alert.addAction(cancelAction)
        }
        topController()?.present(alert, animated: true, completion: nil)
    }
    
    static func showCantFindMediaContent(by type: AlertType, completion: @escaping () -> Void)  {
        
        let alertAction = UIAlertAction(title: "ok", style: .default) { _ in
            completion()
        }
        showAlert(type.alertTitle, message: type.alertMessage, actions: [alertAction], withCancel: false, completion: nil)
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

extension AlertManager {
    
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
    
    static func showDeleteContactsAlerts(completion: @escaping () -> Void) {
        
        let allowDeleteAction = UIAlertAction(title: "delete", style: .default) { _ in
            completion()
        }
        
        showAlert(type: .deleteContacts, actions: [allowDeleteAction])
    }
    
    static func showMergeContactsAlert(comletion: @escaping () -> Void) {
        
        let allowMergeContactsAction = UIAlertAction(title: "merge", style: .default) { _ in
            comletion()
        }
        
        showAlert(type: .mergeContacts, actions: [allowMergeContactsAction])
    }
    
    static func showEmptyContactsToPresent(of type: AlertType, completion: @escaping () -> Void) {
        
        self.showCantFindMediaContent(by: type) {
            completion()
        }
    }
}
