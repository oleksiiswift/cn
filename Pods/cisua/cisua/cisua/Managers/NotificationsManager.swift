//
//  NotificationsManager.swift
//  cisua
//
//  Created by Anton Litvinov on 31.01.2020.
//

import Foundation
import UserNotifications
import AudioToolbox

class NotificationsManager {
    
    static let shared = NotificationsManager()
    
    init() {
        AppSwizzle.shared().applicationDidFinishLaunching { (application, launchOptions) in
             if let notificationPayload = launchOptions?[.remoteNotification] as? [AnyHashable : Any] {
                self.processRemoteNotificationPlayload(notificationPayload, fromBackground: true)
            }
        }
        AppSwizzle.shared().applicationDidReceiveRemoteNotificationHandler { (application, userInfo) in
            self.processRemoteNotificationPlayload(userInfo)
        }
        AppSwizzle.shared().applicationDidRegisterForRemoteNotifications { (application, deviceToken) in
            self.registerDeviceTokenForPushNotifications(deviceToken)
        }
    }
    
    
    internal func tryToRegisterAppForRemoteNotifications(alertShowed: Cisua.BoolResultCompletion? = nil) {
        if let backgroundModes = Bundle.mainBundle.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] {
            if backgroundModes.contains("remote-notification") {
                UIApplication.shared.delegate?.registerRemoteNotifications(alertShowed: alertShowed)
                return()
            }
        }
        alertShowed?(false)
    }
    
    
    private func registerDeviceTokenForPushNotifications(_ data: Data) {
        Push.register(token: data.hexString())
    }
    
    private func processRemoteNotificationPlayload(_ playload: [AnyHashable: Any], fromBackground: Bool = false) {
        
        guard let playload = playload["aps"] as? [AnyHashable: Any] else { return }
        
        if let company  = playload["c"] as? String {
            
            let title   = playload["t"] as? String
            let message = playload["m"] as? String
            let action  = playload["a"] as? String
            let id      = playload["i"] as? String
            let url     = playload["u"] as? String
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if UIApplication.shared.applicationState == .active {
                    Push.opened(companyId: company) {
                        if (title ?? "").count > 0 || (message ?? "").count > 0 {
                            
                            if fromBackground == true {
                                
                                AlertsManager.show(title: title, message: message, action: action) { (cancelled) in
                                    if cancelled == false, (id ?? "").count > 0 {
                                        let url = "itms-apps://itunes.apple.com/app/id\(id!)"
                                        Push.redirected(companyId: company) {
                                            UserDefaults.standard.set(true, forKey: "opened_boost_\(url)")
                                            UserDefaults.standard.synchronize()
                                            Cisua.openUrl(url: url)
                                        }
                                    } else if cancelled == false, (url ?? "").count > 0, let url = URL(string: url!) {
                                        Push.redirected(companyId: company) {
                                            UserDefaults.standard.set(true, forKey: "opened_boost_\(url.absoluteString)")
                                            UserDefaults.standard.synchronize()
                                            Cisua.openUrl(url: url.absoluteString)
                                        }
                                    }
                                }
                                
                            } else {
                                
                                AudioServicesPlaySystemSound(1315)
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                
                                let notificationView = NotificationView.default
                                notificationView.title = title
                                notificationView.subtitle = ""
                                notificationView.body = ""
                                notificationView.image = nil
                                
                                notificationView.show {
                                    if $0 == .tap {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            AlertsManager.show(title: title, message: message, action: action) { (cancelled) in
                                                if cancelled == false, (id ?? "").count > 0 {
                                                    let url = "itms-apps://itunes.apple.com/app/id\(id!)"
                                                    Push.redirected(companyId: company) {
                                                        UserDefaults.standard.set(true, forKey: "opened_boost_\(url)")
                                                        UserDefaults.standard.synchronize()
                                                        Cisua.openUrl(url: url)
                                                    }
                                                } else if cancelled == false, (url ?? "").count > 0, let url = URL(string: url!) {
                                                    Push.redirected(companyId: company) {
                                                        UserDefaults.standard.set(true, forKey: "opened_boost_\(url.absoluteString)")
                                                        UserDefaults.standard.synchronize()
                                                        Cisua.openUrl(url: url.absoluteString)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
}
