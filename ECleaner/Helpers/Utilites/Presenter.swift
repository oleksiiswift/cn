//
//  Presenter.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit
import SwiftMessages

typealias P = UIPresenter
class UIPresenter {
    
	public static func showViewController(of presentedType: PresentedControllerType, scenePresenter: Bool = true,  completionHandler: ((_ navigationController: UINavigationController?) -> Void)? = nil) {
		
		guard let scene = currentScene as? UIWindowScene else { return }
		
		let navigationController = presentedType.navigationController
		Utils.sceneDelegate.presentedWindow = UIWindow(windowScene: scene)
		Utils.sceneDelegate.presentedWindow?.windowLevel = .statusBar - 1
		Utils.sceneDelegate.presentedWindow?.rootViewController = navigationController
		Utils.sceneDelegate.presentedWindow?.makeKeyAndVisible()
		completionHandler?(navigationController)
	}
	
	public static func showWebController(of type: PresentedControllerType, web: WebLink) {

		
	}
	
	public static func closePresentedWindow() {
		guard let _ = currentScene as? UIWindowScene else { return }
		Utils.sceneDelegate.presentedWindow?.frame = .zero
		Utils.sceneDelegate.presentedWindow = nil
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


enum ToastType {
	case waitBackup
	
	var toastTitle: String {
		switch self {
			case .waitBackup:
				return "Wait, until backup end"
		}
	}
}

extension UIPresenter {
	
	public static func showToast(_ type: ToastType, duration: Double = 3.0) {
		
		let style = ToastStyle()
		
		U.UI {
			if let topViewController = getTheMostTopController() {
				topViewController.view.hideAllToasts()
				topViewController.view.clearToastQueue()
				topViewController.view.makeToast(type.toastTitle, duration: duration, position: .top, style: style)
			}
		}
	}

	public static func showToastIn(customPoint: CGPoint, type: ToastType) {
	
		U.UI {
			if let presentController = getTheMostTopController() {
				presentController.view.hideAllToasts()
				presentController.view.clearToastQueue()
				presentController.view.makeToastInPoint(type.toastTitle, duration: 3.0, position: customPoint)
			}
		}
	}
}

extension UIPresenter {
		
	public static func showMessage(with description: MessageDescription, type: LimitAccessType) {
		
		let view = MessageView.viewFromNib(layout: .cardView)

		view.configureContent(title: description.title,
							  body: description.message,
							  iconImage: description.image,
							  iconText: nil,
							  buttonImage: nil,
							  buttonTitle: nil,
							  buttonTapHandler: { _ in
			
			SwiftMessages.hide()
			UIPresenter.showViewController(of: .subscription)
		})
	
		var config = SwiftMessages.defaultConfig
		config.duration = .forever
		config.dimMode = .gray(interactive: true)
		config.interactiveHide = true
		
		view.configureDropShadow()
		view.backgroundView.backgroundColor = ThemeManager.theme.backgroundColor
		view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		
		view.button?.setImage(I.systemItems.navigationBarItems.premium, for: .normal)
		view.button?.setTitleColor(ThemeManager.theme.titleTextColor, for: .normal)
		
		let extraButton = UIButton()
		extraButton.addTarget(self, action: #selector(handleTapAction(_:)), for: .touchUpInside)
		
		view.addSubview(extraButton)
		extraButton.translatesAutoresizingMaskIntoConstraints = false
		extraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		
		extraButton.trailingAnchor.constraint(equalTo: view.button!.leadingAnchor).isActive = true
		extraButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		extraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	
		SwiftMessages.show(config: config, view: view)
	}
	
	@objc static func handleTapAction(_ sender: UIButton) {
		SwiftMessages.hide()
		UIPresenter.showViewController(of: .subscription)
	}
	
	public static func showAlertLine(with message: String, of color: UIColor) {
			
		let statusLine = MessageView.viewFromNib(layout: .statusLine)
		var statusLineConfig = SwiftMessages.defaultConfig
		statusLine.backgroundColor = color
		statusLine.bodyLabel?.textColor = .white
		statusLine.configureContent(body: message)
		statusLineConfig.presentationContext = .window(windowLevel: U.topLevel + 2)
		
		SwiftMessages.show(config: statusLineConfig, view: statusLine)
	}
}
