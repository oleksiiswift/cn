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
	case support
	case share
	case rate
	case privacypolicy
	case termsOfUse
	case videoCompress
	
	var settingsTitle: String {
		switch self {
			case .premium:
				return "premium"
			case .largeVideos:
				return "large video"
			case .dataStorage:
				return "storage"
			case .permissions:
				return "permission"
			case .restore:
				return "restore purchase"
			case .support:
				return "support"
			case .share:
				return "share app"
			case .rate:
				return "rate us"
			case .privacypolicy:
				return "privacy policy"
			case .termsOfUse:
				return "terms of use"
			case .videoCompress:
				return "compress video"
		}
	}
	
	var settingsImages: UIImage {
		switch self {
			case .premium:
				return I.setting.premiumBanner
			case .largeVideos:
				return I.setting.largeVideo
			case .dataStorage:
				return I.setting.storage
			case .permissions:
				return I.setting.permission
			case .restore:
				return I.setting.restore
			case .support:
				return I.setting.support
			case .share:
				return I.setting.share
			case .rate:
				return I.setting.rate
			case .privacypolicy:
				return I.setting.privacy
			case .termsOfUse:
				return I.setting.terms
			default:
				return UIImage()
		}
	}
	
	var optionalBannerImage: UIImage {
		switch self {
			case .premium:
				return I.setting.premiumBanner
			case .videoCompress:
				return I.setting.premiumBanner
			default:
				return UIImage()
		}
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
