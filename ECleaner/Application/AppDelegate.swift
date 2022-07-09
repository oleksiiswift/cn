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
        
		self.initializeSubscriptions()
		ECFileManager().deleteAllFiles(at: AppDirectories.temp) {
			debugPrint("deleted all files from temp")
		}
		PermissionManager.shared.checkForStartingPemissions()
		UserNotificationService.sharedInstance.registerRemoteNotification()
    }
}

extension AppDelegate {
	
	private func initializeSubscriptions() {
		Network.start()
		Network.theyLive { isAlive in
			guard isAlive else { return }
			SubscriptionManager.instance.initialize()
		}
	}

    private func setDefaults() {
		
		U.delay(10) {
			SettingsManager.application.lastApplicationUsage = Date()
		}
	
		Utils.setUpperDefaultValue()
		Utils.setLowerDafaultValue()
		
		SettingsManager.phassetVideoFilesSizes = nil
		SettingsManager.phassetPhotoFilesSizes = nil
		SettingsManager.lastSavedLocalIdenifier = nil
		
		if !CompressionSettingsConfiguretion.isDefaultConfigurationIsSet {
			CompressionSettingsConfiguretion.setDefaultConfiguration()
		}
    }
	
	private func developmentSettings() {
		
		S.inAppPurchase.allowAdvertisementBanner = false
	}
	
	private func setupObserver() {
		
		NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(networkingStatusDidChange), name: .ReachabilityDidChange, object: nil)
		
	}
	
	@objc func checkPermissionStatus() {
		
		guard Utils.sceneDelegate.coordinator?.currentState == .application else { return }

		SettingsManager.permissions.photoPermissionSavedValue = PhotoLibraryPermissions().authorized
		SettingsManager.permissions.contactsPermissionSavedValue = ContactsPermissions().authorized
	}
	
//	@objc func networkingStatusDidChange() {
//		self.initializeSubscriptions()
//	}
}


