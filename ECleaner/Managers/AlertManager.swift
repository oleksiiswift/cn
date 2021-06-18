//
//  AlertManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import UIKit

enum AlertType {
    
    case allowNotification
    case allowConstacStore
    case allowPhotoLibrary
    case withCancel
    case none
    
    /// alert title
    var alertTitle: String? {
        switch self {

            case .allowNotification:
                return "locomark set title for allow notification"
            case .allowConstacStore:
                return "locomark set title for contacts"
            case .allowPhotoLibrary:
                return "locomark set title for photo library"
            case .withCancel:
                return ""
            case .none:
                return ""
        }
    }
    
    /// alert message
    var alertMessage: String? {
        
        switch self {
            case .allowNotification:
                return "locomark notification message"
            case .allowConstacStore:
                return "locomark contacts message"
            case .allowPhotoLibrary:
                return "locomark library photo"
            case .withCancel:
                return "cancel"
            case .none:
                return "none"
        }
    }
    
//    /// alert or action sheet
    var alertStyle: UIAlertController.Style {
        if U.isIpad {
            return .alert
        } else {
            return .alert
        }

//        TODO:
//        switch self {
//            case .selectNumber, .support:
//                return .actionSheet
//            default:
//                return .alert
//        }
    }
    
//    var alertWithTextField: Bool {
//        switch self {
//            case .createFolder, .renameFolder, .renameRecord:
//                return true
//            default:
//                return false
//        }
//    }
//
//    var alertTextFieldPlaceHolder: String {
//        switch self {
//            case .createFolder:
//                return L.message.alertMessage.folderPlaceHolder
//            case .renameRecord, .renameFolder:
//                return L.message.alertMessage.setNewNamePlaceholder
//            default:
//                return ""
//        }
//    }
}





class AlertManager: NSObject {
    
    /// default alert
    static func showAlert(_ title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], completion: (() -> Void)? = nil) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "loco cancel", style: .cancel) { action in
            completion?()
        }
        
        actions.forEach { (action) in
            alert.addAction(action)
        }
        
        alert.addAction(cancelAction)
        topController()?.present(alert, animated: true, completion: nil)
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
