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
		developmentSettings()
		
//		NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { notification in
//			debugPrint(notification)
//		}
	
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		debugPrint(connectingSceneSession)
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		debugPrint(sceneSessions)
    }
}

extension AppDelegate {
    
    private func configureApplication(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
		SubscriptionManager.instance.initialize()
		PhotoManager.shared.checkPhotoLibraryAccess()
        ContactsManager.shared.checkStatus { _ in }
		ECFileManager().deleteAllFiles(at: AppDirectories.temp) {
			debugPrint("deleted all files from temp")
		}
    }
}

extension AppDelegate {

    private func setDefaults() {
	
		U.setUpperDefaultValue()
		U.setLowerDafaultValue()
		
		S.phassetVideoFilesSizes = nil
		S.phassetPhotoFilesSizes = nil
		S.lastSavedLocalIdenifier = nil
		
		if !CompressionSettingsConfiguretion.isDefaultConfigurationIsSet {
			CompressionSettingsConfiguretion.setDefaultConfiguration()
		}
    }
	
	private func developmentSettings() {
		
		S.inAppPurchase.allowAdvertisementBanner = false
	}
}
