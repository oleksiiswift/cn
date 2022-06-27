//
//  Onboarding.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2022.
//

import Foundation

enum Onboarding: CaseIterable {
	case welcome
	case photo
	case video
	case contacts
	
	var rawValue: String {
		switch self {
			case .welcome:
				return "welcome"
			case .photo:
				return "photo"
			case .video:
				return "vide0"
			case .contacts:
				return "contacts"
		}
	}
	
	var title: String {
		switch self {
			case .welcome:
				return "main title wellcome app"
			case .photo:
				return "title for clean photo"
			case .video:
				return "title for clean video"
			case .contacts:
				return "title for clean contacts"
		}
	}
	
	var description: String {
		switch self {
			case .welcome:
				return "hello cleaner app"
			case .photo:
				return "very long descriptopn for clean photo and some extra feat blah blah blag"
			case .video:
				return "another very long descriptopn for clean vide and some extra feat blah blah "
			case .contacts:
				return "very long descriptopn for clean contacts and some extra featblah contacts contacts"
		}
	}
	
	var animationName: String {
		switch self {
			case .welcome:
				return "welcome"
			case .photo:
				return "photo"
			case .video:
				return "video"
			case .contacts:
				return "contacts"
		}
	}
}
