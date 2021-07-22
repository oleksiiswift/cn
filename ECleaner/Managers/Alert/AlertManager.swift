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
    case allowDeleteSelectedPhotos
    case withCancel
    
    case noSimiliarPhoto
    case noDuplicatesPhoto
    case noScreenShots
    case noSelfie
    case noLivePhoto
    case noLargeVideo
    case noDuplicatesVideo
    case noSimilarVideo
    case noScreenRecording
    
    case noRecentlyDeletedPhotos
    case noRecentlyDeletedVideos
    
    
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
            case .allowDeleteSelectedPhotos:
                return "locomark delete assets?"
            case .noSimiliarPhoto:
                return "locomark no similar photos"
            case .noDuplicatesPhoto:
                return "locomark no duplicates photo"
            case .noScreenShots:
                return "locomark no screen shots"
            case .noSelfie:
                return "locomark no selfie"
            case .noLivePhoto:
                return "locomark no live photo"
            case .none:
                return ""
            case .noLargeVideo:
                return "locomark no large video files"
            case .noDuplicatesVideo:
                return "locomark no duplicated video"
            case .noSimilarVideo:
                return "locomark no similiar video"
            case .noScreenRecording:
                return "locomark no screen recordings"
            case .noRecentlyDeletedPhotos:
                return "locomark no recently deleted photos"
            case .noRecentlyDeletedVideos:
                return "locomark no recently deleted vides"
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
            case .allowDeleteSelectedPhotos:
                return "delete selecteds assets are you shure????"
            
            case .noSimiliarPhoto, .noDuplicatesPhoto, .noScreenShots, .noSelfie, .noLivePhoto, .noLargeVideo, .noDuplicatesVideo, .noSimilarVideo, .noScreenRecording:
                return "locomark no content"
            case .noRecentlyDeletedPhotos:
                return "recently deleted photos empty"
            case .noRecentlyDeletedVideos:
                return "recently deleted videos empty"
        }
    }
    
//    /// alert or action sheet
    var alertStyle: UIAlertController.Style {
        if U.isIpad {
            return .alert
        } else {
            return .alert
        }
    }
}

class AlertManager: NSObject {
    
    private static func showAlert(type: AlertType, actions: [UIAlertAction], withCance: Bool = true, cancelCompletion: (() -> Void)? = nil) {
        
        showAlert(type.alertTitle, message: type.alertMessage, actions: actions, withCancel: withCance) {
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
    
    static func showCantFindMediaContent(by type: AlertType) {
        
        let alertAction = UIAlertAction(title: "ok", style: .default) { _ in }
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

extension AlertManager {
    
    static func showDeletePhotoAssetsAlert(completion: @escaping () -> Void) {
      
        let allowDeleteAction = UIAlertAction(title: "loco delete?", style: .default) { _ in
            completion()
        }
        
        showAlert(type: .allowDeleteSelectedPhotos, actions: [allowDeleteAction], withCance: true) {}
    }
}
