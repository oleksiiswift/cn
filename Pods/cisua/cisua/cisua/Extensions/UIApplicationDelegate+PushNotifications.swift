//
//  AppDelegateExtensions.swift
//  cisua
//
//  Created by admin on 01/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation
import UserNotifications

internal extension UIApplicationDelegate {
    
    fileprivate func enabled(completion: @escaping (Bool)->()) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    func registerRemoteNotifications(alertShowed: Cisua.BoolResultCompletion? = nil) {
        self.enabled { (enabled) in
            alertShowed?(!enabled)
            if enabled == false {
                let center  = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, _) in
                    if granted == true {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
}
