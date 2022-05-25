//
//  temotext.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation
typealias L = TempText
struct  TempText {
//	Localisation
	
	static func getTitle(for permission: Permission.PermissionType) -> String {
		switch permission {
			case .notification:
				return "Notification"
			case .photolibrary:
				return "Photo Library"
			case .contacts:
				return "Contacts"
			case .tracking:
				return "Tracking"
			default:
				return ""
		}
	}
	
	
	static func getDescription(for permission: Permission.PermissionType) -> String {
		switch permission {
				
			case .notification:
				return "description for use notification"
			case .photolibrary:
				return "description for use photolibrarary"
			case .contacts:
				return "description for use contacts"
			case .tracking:
				return "description for app track"
			default:
				return ""
		}
	}
}
