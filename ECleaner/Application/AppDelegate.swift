//
//  AppDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit
import Contacts

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureApplication(with: launchOptions)
        setDefaults()
    
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
 
    }
}

extension AppDelegate {
    
    private func configureApplication(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
		PhotoManager.shared.checkPhotoLibraryAccess()
        ContactsManager.shared.checkStatus { _ in }
    }

    private func setDefaults() {
	
		U.setUpperDefaultValue()
		U.setLowerDafaultValue()
    }
}
