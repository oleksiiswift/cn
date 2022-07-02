//
//  FontManager+Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import Foundation

enum SubscriptionFontType {
	case premiumFeature
	case title
	case helperText
}

extension FontManager {
	
	struct SubscriptionFontSize {
		
		static var premiumFeature: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 14, weight: .semibold)
				case .medium:
					return .systemFont(ofSize: 16, weight: .semibold)
				default:
					return .systemFont(ofSize: 18, weight: .semibold)
			}
		}
		
		static var title: UIFont {
			return .systemFont(ofSize: 38, weight: .black)
		}
		static var helperText: UIFont {
			return .systemFont(ofSize: 12, weight: .regular)
		}
	}
}


