//
//  SettingsController.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import Foundation

class SettingsController {
	
	public func setAction(at cell: SettingsModel) {
		switch cell {
			case .premium:
				self.showPremiumController()
			case .largeVideos:
				self.showLargeVideoSettings()
			case .dataStorage:
				self.showDataStorageInfo()
			case .permissions:
				self.showPermissionController()
			case .restore:
				self.showRestorePurchaseAction()
			case .support:
				self.showSupportAction()
			case .share:
				self.showShareAppAction()
			case .rate:
				self.showRateUSAction()
			case .privacypolicy:
				self.showPrivacyPolicyAction()
			case .termsOfUse:
				self.showTermsOfUseAction()
		}
	}
	
	private func showPremiumController() {
		debugPrint("showPremiumController")
	}
	
	private func showLargeVideoSettings() {
		debugPrint("showLargeVideoSettings")
	}
	
	private func showDataStorageInfo() {
		debugPrint("showDataStorageInfo")
	}
	
	private func showPermissionController() {
		debugPrint("showPermissionController")
	}
	
	private func showRestorePurchaseAction() {
		debugPrint("showRestorePurchaseAction")
	}
	
	private func showSupportAction() {
		debugPrint("showSupportAction")
	}
	
	private func showShareAppAction() {
		debugPrint("showShareAppAction")
	}
	
	private func showRateUSAction() {
		debugPrint("showRateUSAction")
	}
	
	private func showPrivacyPolicyAction() {
		debugPrint("showPrivacyPolicyAction")
	}
	
	private func showTermsOfUseAction() {
		debugPrint("showTermsOfUseAction")
	}
}

extension SettingsController {
	
	private func showWebView(with url: URL) {
		
	}
}

