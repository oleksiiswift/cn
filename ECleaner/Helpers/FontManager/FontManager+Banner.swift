//
//  FontManager+Banner.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.05.2022.
//

import Foundation

enum ContentBannerFontType {
	case title
	case subititle
	case descriptionTitle
	case descriptionFirstTitle
	case descriptionSecontTitle
}

extension FontManager {
	
	struct ContentBunnerFontSize {
		
		static var titleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 14, weight: .bold)
				case .plus, .large, .modern, .max, .madMax:
					return .systemFont(ofSize: 16, weight: .bold)
			}
		}
		
		static var titleSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .medium)
				case .medium:
					return .systemFont(ofSize: 12, weight: .medium)
				case .plus, .large, .modern, .max, .madMax:
					return .systemFont(ofSize: 14, weight: .medium)
			}
		}
		
		static var descriptionTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .medium)
				case .medium:
					return .systemFont(ofSize: 14, weight: .medium)
				case .plus, .large, .modern, .max, .madMax:
					return .systemFont(ofSize: 16, weight: .medium)
			}
		}
		
		static var descriptionFirstSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 20, weight: .heavy)
				case .medium:
					return .systemFont(ofSize: 22, weight: .heavy)
				case .plus, .large, .modern, .max, .madMax:
					return .systemFont(ofSize: 24, weight: .heavy)
			}
		}
		
		static var descriptionSecondSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 24, weight: .heavy)
				case .medium:
					return .systemFont(ofSize: 26, weight: .heavy)
				case .plus, .large, .modern, .max, .madMax:
					return .systemFont(ofSize: 29, weight: .heavy)
			}
		}
	}
}
