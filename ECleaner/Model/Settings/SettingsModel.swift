//
//  SettingsModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import Foundation
import UIKit

enum SettingsModel {
	
	case premium
	case largeVideos
	case dataStorage
	case permissions
	case restore
	case lifetime
	case support
	case share
	case rate
	case privacypolicy
	case termsOfUse
	case videoCompress
	
	var settingsTitle: String {
		switch self {
			case .premium:
				return L.Settings.Title.premium
			case .largeVideos:
				return L.Settings.Title.largeVideo
			case .dataStorage:
				return L.Settings.Title.storage
			case .permissions:
				return L.Settings.Title.permission
			case .restore:
				return L.Settings.Title.restore
			case .lifetime:
				return L.Settings.Title.lifeTime
			case .support:
				return L.Settings.Title.support
			case .share:
				return L.Settings.Title.share
			case .rate:
				return L.Settings.Title.rateUS
			case .privacypolicy:
				return L.Settings.Title.privacy
			case .termsOfUse:
				return L.Settings.Title.terms
			case .videoCompress:
				return L.Settings.Title.videoCompression
		}
	}
	
	var settingsImages: UIImage {
		return Images().getSettingsImages(for: self)
	}
	
	var gradientColorsForSettings: [UIColor] {
		return ThemeManager.theme.getColorsGradient(for: self)
	}
		
	var heightForRow: CGFloat {
		switch self {
			case .premium:
				return 187
			case .videoCompress:
				return 187
			default:
				return 80
		}
	}
}
