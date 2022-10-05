//
//  FontManager+Permission.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.05.2022.
//

import Foundation

enum PermissionFontType {
	case mainTitle
	case mainSubtitle
	case title
	case subtitle
	case permissionButton
	case desctiption
}

extension FontManager {
	
	struct PermissionFont {
		
		static var mainTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 22, weight: .black).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 26, weight: .black).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 28, weight: .black).monospacedDigitFont
			}
		}
		
		static var mainSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 15, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 16, weight: .bold).monospacedDigitFont
			}
		}
		
		static var titleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 16, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 18, weight: .bold).monospacedDigitFont
			}
		}
		
		static var subtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .medium).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 11, weight: .medium).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 12, weight: .medium).monospacedDigitFont
			}
		}

		static var permissionButton: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 13, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
			}
		}
		
		static var descriptioFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 13, weight: .bold)
				case .medium, .plus, .large:
					return .systemFont(ofSize: 13, weight: .bold)
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 13, weight: .bold)
			}
		}
	}
}
