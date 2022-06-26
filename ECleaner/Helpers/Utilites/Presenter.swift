//
//  Presenter.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

typealias P = UIPresenter
class UIPresenter {
    
	public static func showViewController(of presentedType: PresentedControllerType, scenePresenter: Bool = true, completionHandler: ((_ navigationController: UINavigationController?) -> Void)? = nil) {
		
		guard let scene = currentScene as? UIWindowScene else { return }
		
		let navigationController = presentedType.navigationController
		U.sceneDelegate.presentedWindow = UIWindow(windowScene: scene)
		U.sceneDelegate.presentedWindow?.windowLevel = .statusBar - 1
		U.sceneDelegate.presentedWindow?.rootViewController = navigationController
		U.sceneDelegate.presentedWindow?.makeKeyAndVisible()
		completionHandler?(navigationController)
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

