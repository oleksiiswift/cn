//
//  LocalizationTypeStrings.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

struct AlertDescription {
	var title: String
	var description: String
	var action: String
	var cancel: String
	
	init(title: String, description: String, action: String, cancel: String) {
		self.title = title
		self.description = description
		self.action = action
		self.cancel = cancel
	}
}

struct NotificationBodyDescription {
	var title: String
	var subtitle: String
	var body: String
	
	init(title: String, subtitle: String, body: String) {
		self.title = title
		self.subtitle = subtitle
		self.body = body
	}
}

struct ErrorDescription {
	var title: String
	var message: String
	var buttonTitle: String
	
	init(title: String, message: String, buttonTitle: String) {
		self.title = title
		self.message = message
		self.buttonTitle = buttonTitle
	}
}

enum ButtonType {
	case allowed
	case `continue`
	case denied
	case ok
	case cancel
	case settings
	case delete
	case stop
	case exit
	case share
	case save
	case selectAll
	case deselectAll
	case select
	case deselect
	case merge
	case layout
	case edit
	case export
	case fullPreview
	case deleteSelected
	case setAsBest
	case mergeSelected
	case compres
	case submit
	case resetDefault
	case removeAudio
	case origin
	case manual
	case skip
	case next
	case restore
	case activate
	case changePlan
	case startBackup
	case view
		
	var rawValue: String {
		switch self {
			case .allowed:
				return L.Standart.Buttons.allowed
			case .continue:
				return L.Standart.Buttons.continue
			case .denied:
				return L.Standart.Buttons.denied
			case .ok:
				return L.Standart.Buttons.ok
			case .cancel:
				return L.Standart.Buttons.cancel
			case .settings:
				return L.Standart.Buttons.settings
			case .delete:
				return L.Standart.Buttons.delete
			case .stop:
				return L.Standart.Buttons.stop
			case .exit:
				return L.Standart.Buttons.exit
			case .share:
				return L.Standart.Buttons.share
			case .save:
				return L.Standart.Buttons.save
			case .selectAll:
				return L.Standart.Buttons.selectAll
			case .deselectAll:
				return L.Standart.Buttons.deselectAll
			case .select:
				return L.Standart.Buttons.select
			case .deselect:
				return L.Standart.Buttons.deselect
			case .merge:
				return L.Standart.Buttons.merge
			case .layout:
				return L.Standart.Buttons.changeLauout
			case .edit:
				return L.Standart.Buttons.edit
			case .export:
				return L.Standart.Buttons.export
			case .fullPreview:
				return L.Standart.Buttons.fullScreenPreview
			case .deleteSelected:
				return L.Standart.Buttons.deleteSelected
			case .setAsBest:
				return L.Standart.Buttons.setAsBest
			case .mergeSelected:
				return L.Standart.Buttons.mergeSelected
			case .compres:
				return L.Standart.Buttons.compress
			case .submit:
				return L.Standart.Buttons.submit
			case .resetDefault:
				return L.Standart.Buttons.resetDefault
			case .removeAudio:
				return L.Standart.Buttons.removeAudio
			case .origin:
				return L.Standart.Buttons.origin
			case .manual:
				return L.Standart.Buttons.manual
			case .skip:
				return L.Standart.Buttons.skip
			case .next:
				return L.Standart.Buttons.next
			case .restore:
				return L.Standart.Buttons.restore
			case .activate:
				return L.Standart.Buttons.activate
			case .changePlan:
				return L.Standart.Buttons.changePlan
			case .startBackup:
				return L.Standart.Buttons.startBackup
			case .view:
				return L.Standart.Buttons.view
		}
	}
}

enum ControllerType {
	case deepClean
	case subscription
	case onboarding
	case main
	case photoClean
	case videoClean
	case contactClean
	case settings
	case permission
	case videoCompression
	
	var navigationTitle: String {
		switch self {
			case .deepClean:
				return Localization.Main.Title.deepClean
			case .subscription:
				return Localization.Main.Title.subscription
			case .onboarding:
				return Localization.Main.Title.onboarding
			case .main:
				return Localization.Main.Title.main
			case .photoClean:
				return Localization.Main.Title.photoTitle
			case .videoClean:
				return Localization.Main.Title.videoTitle
			case .contactClean:
				return Localization.Main.Title.contactsTitle
			case .settings:
				return Localization.Main.Title.settings
			case .permission:
				return Localization.Main.Title.permission
			case .videoCompression:
				return Localization.Main.Title.videoCompresion
		}
	}
}
