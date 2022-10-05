//
//  FontManager+NavigationSettings.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.05.2022.
//

import Foundation

enum NavigationBarFontType {
	case title
	case barButtonTitle
}

extension FontManager {
	
	struct NavigationSettings {
		
		static var navigationTitleFont: UIFont {
			return DefaultFonts.navigationTitleFont
		}
		
		static var navigationBarButtonTitle: UIFont {
			return DefaultFonts.navigationBarButtonItemFont
		}
	}
}
