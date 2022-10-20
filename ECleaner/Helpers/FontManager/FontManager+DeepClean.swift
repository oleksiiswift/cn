//
//  FontManager+DeepClean.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.05.2022.
//

import Foundation

enum DeepCleanFontType {
	case progress
	case title
	case subtitle
	case headerTitle
}

extension FontManager {

	struct DeepClean {
		
		static var deepCleanCircleProgressPercentLabelFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 11, weight: .bold)
				case .plus:
					return .systemFont(ofSize: 12, weight: .bold)
				case .large:
					return .systemFont(ofSize: 13, weight: .bold)
				case .modern:
					return .systemFont(ofSize: 14, weight: .bold)
				case .pro:
					return .systemFont(ofSize: 14, weight: .bold)
				case .max:
					return .systemFont(ofSize: 15, weight: .bold)
				case .madMax:
					return .systemFont(ofSize: 15, weight: .bold)
				case .proMax:
					return .systemFont(ofSize: 15, weight: .bold)
			}
		}
		
		static var deepCleanInfoHelperTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 14, weight: .bold)
				case .plus:
					return .systemFont(ofSize: 16, weight: .bold)
				case .large:
					return .systemFont(ofSize: 15, weight: .bold)
				case .modern:
					return .systemFont(ofSize: 16, weight: .bold)
				case .pro:
					return .systemFont(ofSize: 16, weight: .bold)
				case .max:
					return .systemFont(ofSize: 17, weight: .bold)
				case .madMax:
					return .systemFont(ofSize: 18, weight: .bold)
				case .proMax:
					return .systemFont(ofSize: 19, weight: .bold)
			}
		}
		
		static var deepCleanInfoHelperSubtitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 11, weight: .medium)
				case .medium:
					return .systemFont(ofSize: 12, weight: .medium)
				case .plus:
					return .systemFont(ofSize: 12, weight: .medium)
				case .large:
					return .systemFont(ofSize: 14, weight: .medium)
				case .modern:
					return .systemFont(ofSize: 14, weight: .medium)
				case .pro:
					return .systemFont(ofSize: 14, weight: .medium)
				case .max:
					return .systemFont(ofSize: 14, weight: .medium)
				case .madMax:
					return .systemFont(ofSize: 15, weight: .medium)
				case .proMax:
					return .systemFont(ofSize: 15, weight: .medium)
			}
		}
		
		static var deepClentSectionHeaderTitleFont: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 14, weight: .bold)
				case .plus:
					return .systemFont(ofSize: 15, weight: .bold)
				case .large, .modern, .pro, .max, .madMax, .proMax:
					return .systemFont(ofSize: 16, weight: .bold)
			}
		}
	}
}
