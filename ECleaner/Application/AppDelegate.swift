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
		setupObserver()
		runDevelopmentElmtn()

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
		ECFileManager().deleteAllFiles(at: AppDirectories.temp) {
			debugPrint("deleted all files from temp")
		}
		PermissionManager.shared.checkForStartingPemissions()
		UserNotificationService.sharedInstance.registerRemoteNotification()
    }
}

extension AppDelegate {

    private func setDefaults() {
		
		U.delay(10) {
			SettingsManager.application.lastApplicationUsage = Date()
		}
	
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
	
	private func setupObserver() {
		
		NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	@objc func checkPermissionStatus() {
		#warning("TODO")
//		guard SettingsManager.permissions.permisssionDidShow else { return }
		
		SettingsManager.permissions.photoPermissionSavedValue = PhotoLibraryPermissions().authorized
		SettingsManager.permissions.contactsPermissionSavedValue = ContactsPermissions().authorized
	}
}

extension AppDelegate {
	
	private func printAllNotifications() {
		
		NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { notification in
			debugPrint(notification)
		}
	}
		
	private func runDevelopmentElmtn() {
		
			//		printAllNotifications()
	}
}

