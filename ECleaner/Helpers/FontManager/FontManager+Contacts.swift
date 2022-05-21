//
//  FontManager+Contacts.swift
//  ECleaner
//
//  Created by alexey sorochan on 21.05.2022.
//

import Foundation

enum ContactsCleanFontType {
	case cellTitle
	case missingTitle
	case cellSubtitle
	case missongSubtitle
	case cellGroupCellHeaderTitle
	case headetTitle
	case headerButonFont
}

extension FontManager {

	struct Contacts {
		
		static var cellTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 13, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 15, weight: .bold).monospacedDigitFont
			}
		}
		
		static var missingTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .italicSystemFont(ofSize: 12, weight: .regular).monospacedDigitFont
				case .medium, .plus, .large:
					return .italicSystemFont(ofSize: 13, weight: .regular).monospacedDigitFont
				case .modern, .max, .madMax:
					return .italicSystemFont(ofSize: 14, weight: .regular).monospacedDigitFont
			}
		}
				
		static var cellSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 13, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
			}
		}
		
		static var missingSubTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .italicSystemFont(ofSize: 11, weight: .regular).monospacedDigitFont
				case .medium, .plus, .large:
					return .italicSystemFont(ofSize: 12, weight: .regular).monospacedDigitFont
				case .modern, .max, .madMax:
					return .italicSystemFont(ofSize: 13, weight: .regular).monospacedDigitFont
			}
		}
		
		static var cellGroupCellHeaderTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 13, weight: .bold).monospacedDigitFont
				case .medium, .plus, .large:
					return .systemFont(ofSize: 14, weight: .bold).monospacedDigitFont
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 15, weight: .bold).monospacedDigitFont
			}
		}
		
		static var headerTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .bold)
				case .medium, .plus, .large:
					return .systemFont(ofSize: 14, weight: .bold)
				case .modern, .max, .madMax:
					return .systemFont(ofSize: 16, weight: .bold)
			}
		}
		
		static var headerButtonFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .bold)
				default:
					return .systemFont(ofSize: 12, weight: .bold)
			}
		}
	}
}
