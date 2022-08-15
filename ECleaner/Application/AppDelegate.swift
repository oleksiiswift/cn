//
//  AppDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit
import Contacts
import GoogleMobileAds
import SwiftRater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	
        configureApplication(with: launchOptions)
        setDefaults()
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
        
		Network.start()
		self.initializeSubscriptions()
		self.cleanTempCache()
		self.firtTimeApplicationStart()
		PermissionManager.shared.checkForStartingPemissions()
		UserNotificationService.sharedInstance.registerRemoteNotification()
		RateManager.instance.initialize(rate: .objc)
    }
}

extension AppDelegate {
	
	private func initializeSubscriptions() {
		
		Network.theyLive { status in
			guard status == .connedcted else { return }
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
	
	private func firtTimeApplicationStart() {
		
		if !SettingsManager.application.firstTimeApplicationStart {
			SettingsManager.promt.promtRateDelay = Date.getCurrentDate()
			SettingsManager.promt.sixHoursDelay = Date.getCurrentDate()
		} else if SettingsManager.application.firstTimeApplicationStart {
			if SettingsManager.promt.sixHoursDelay == nil {
				SettingsManager.promt.promtRateDelay = Date.getCurrentDate()
				SettingsManager.promt.sixHoursDelay = Date.getCurrentDate()
			}
		}
	}
		
	private func cleanTempCache() {
		
		let fileManager = ECFileManager()
		fileManager.deleteAllFiles(at: .temp) {}
		fileManager.deleteAllFiles(at: .contactsArcive) {}
		fileManager.deleteAllFiles(at: .systemTemp) {}
	}
	
	private func setupObserver() {
		
		NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(networkingStatusDidChange), name: .ConnectivityDidChange, object: nil)
	}
	
	@objc func checkPermissionStatus() {
		
		guard Utils.sceneDelegate.coordinator?.currentState == .application else { return }

		SettingsManager.permissions.photoPermissionSavedValue = PhotoLibraryPermissions().authorized
		SettingsManager.permissions.contactsPermissionSavedValue = ContactsPermissions().authorized
	}
	
	@objc func networkingStatusDidChange() {
		self.initializeSubscriptions()
	}
}


