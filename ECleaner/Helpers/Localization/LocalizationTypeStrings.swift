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
		self.buttonTitle = title
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
		}
	}
}
