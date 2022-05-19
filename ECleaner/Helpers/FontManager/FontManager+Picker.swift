//
//  FontManager+Picker.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.05.2022.
//

import Foundation

enum PickerTypeFont {
	case title
	case subtitle
}

extension FontManager {
	
	struct PickerController {
		
		static var pickerFontSize: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 20, weight: .black)
				case .medium:
					return .systemFont(ofSize: 24, weight: .black)
				case .plus:
					return .systemFont(ofSize: 26, weight: .black)
				case .large:
					return .systemFont(ofSize: 26, weight: .black)
				case .modern:
					return .systemFont(ofSize: 26, weight: .black)
				case .max:
					return .systemFont(ofSize: 26, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 26, weight: .black)
			}
		}
		
		static var buttonSubTitleFontSize: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 14, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 15.8, weight: .bold)
				default:
					return .systemFont(ofSize: 16.8, weight: .bold)
			}
		}
	}
}
