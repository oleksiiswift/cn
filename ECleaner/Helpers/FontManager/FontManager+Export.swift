//
//  FontManager+Export.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.05.2022.
//

import Foundation

enum ExportScreenFontType {
	case title
	case buttons
}

extension FontManager {
	
	struct ExportModal {
		
		static var navigationTitleFont: UIFont {
			return FontManager.navigationBarFont(of: .title)
		}
		
		static var buttonTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 35, weight: .heavy)
				case .medium, .plus, .large:
					return .systemFont(ofSize: 38, weight: .heavy)
				case .modern, .pro, .max, .madMax, .proMax:
					return .systemFont(ofSize: 40, weight: .heavy)
			}
		}
	}
}
