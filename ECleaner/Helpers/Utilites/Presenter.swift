//
//  Presenter.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

typealias P = UIPresenter
class UIPresenter {
    
	 public static func showViewController(of presentedType: PresentedControllerType, scenePresenter: Bool = true) {
		
		 guard let scene = currentScene as? UIWindowScene else { return }
		 
		 let viewController = presentedType.presentController
		 let navigationController = UINavigationController.init(rootViewController: viewController)
		 
		 switch presentedType {
			 case .permission:
				 debugPrint("viewcontroler")
				 debugPrint("if scene preenter hide navigation settings -> ")
		 }
		 
		 self.present(type: presentedType,
					  viewController: viewController,
					  rootViewController: navigationController,
					  scene: scene,
					  scenePresenter: scenePresenter)
	}
	
	private static func present(type: PresentedControllerType, viewController: UIViewController, rootViewController: UINavigationController, scene: UIWindowScene, scenePresenter: Bool = true) {
		DispatchQueue.main.async {
			
			if let window = UIWindowScene.focused.map(UIWindow.init(windowScene:)) {
				window.rootViewController = viewController
				window.makeKeyAndVisible()
			}
			
//			var window = type.presentationWindow
//			window = UIWindow(windowScene: scene)
//			window!.windowLevel = .statusBar + 1
//			window!.rootViewController = rootViewController
//			window!.makeKeyAndVisible()
//			U.delay(1) {
//				debugPrint(window!.frame)
//				debugPrint(scene)
//			}
			
		}
	}
}


extension UIWindowScene {
	static var focused: UIWindowScene? {
		return UIApplication.shared.connectedScenes
			.first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
	}
}


extension UIPresenter {
	
	@available(iOSApplicationExtension, unavailable)
	static func openSettingPage() {
		DispatchQueue.main.async {
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: nil)
			}
		}
	}
}

extension UIPresenter {
	
	public static func showIndicator(in viewController: UIViewController?) {
		
		CustomActivityIndicator.showActivityIndicator(ifNeedPresentCoontroller: viewController)
	}
	
	public static func showIndicator() {
		
		CustomActivityIndicator.showActivityIndicator()
	}
	
	public static func hideIndicator() {
		
		CustomActivityIndicator.hideActivityIndicator()
	}
}

