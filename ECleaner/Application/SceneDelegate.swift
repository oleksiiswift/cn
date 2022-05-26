//
//  SceneDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit

var currentScene: UIScene?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	var permissionWindow: UIWindow?
	
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		currentScene = scene
		
		handleStartupRouting()
		
    }

    func sceneDidDisconnect(_ scene: UIScene) {
  
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
//		U.delay(1) {
//			UIPresenter.showViewController(of: .permission, scenePresenter: true)			
//		}

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

extension SceneDelegate {
	
	
	private func handleStartupRouting() {
		
		if !SettingsManager.permissions.permisssionDidShow {
			UIPresenter.showViewController(of: .permission)
		}
	}
}
