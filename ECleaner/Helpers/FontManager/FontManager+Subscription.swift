//
//  FontManager+Subscription.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import Foundation
import UIKit

enum SubscriptionFontType {
	case premiumFeature
	case title
	case helperText
	case helperTextBold
	case links
	case buttonTitle
	case buttonPrice
	case lifeTimeTitle
	case buttonDescription
	case premimBannerTitle
	case permiumBannerSubtitle
	case premiumBannerDateSubtitle
	case premiumFeatureBannerTitle
	case premiumFeatureBannerSubtitle
	case premiumFeatureBannerSubtitleTitle
}

extension FontManager {
	
	struct SubscriptionFontSize {
		
		static var premiumFeature: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .semibold)
				case .medium:
					return .systemFont(ofSize: 13, weight: .semibold)
				case .plus:
					return .systemFont(ofSize: 15, weight: .semibold)
				case .large:
					return .systemFont(ofSize: 16, weight: .semibold)
				case .modern:
					return .systemFont(ofSize: 17, weight: .semibold)
				case .pro:
					return .systemFont(ofSize: 17, weight: .semibold)
				case .max:
					return .systemFont(ofSize: 18, weight: .semibold)
				case .madMax:
					return .systemFont(ofSize: 18, weight: .semibold)
				case .proMax:
					return .systemFont(ofSize: 18, weight: .semibold)
			}
		}
		
		static var title: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 32, weight: .black)
				case .medium:
					return .systemFont(ofSize: 42, weight: .black)
				case .plus:
					return .systemFont(ofSize: 42, weight: .black)
				case .large:
					return .systemFont(ofSize: 42, weight: .black)
				case .modern:
					return .systemFont(ofSize: 44, weight: .black)
				case .pro:
					return .systemFont(ofSize: 44, weight: .black)
				case .max:
					return .systemFont(ofSize: 44, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 44, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 44, weight: .black)
					
			}
		}
		
		
		static var lifeTimeTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 18, weight: .black)
				case .medium:
					return .systemFont(ofSize: 20, weight: .black)
				case .plus:
					return .systemFont(ofSize: 24, weight: .black)
				case .large:
					return .systemFont(ofSize: 26, weight: .black)
				case .modern:
					return .systemFont(ofSize: 26, weight: .black)
				case .pro:
					return .systemFont(ofSize: 27, weight: .black)
				case .max:
					return .systemFont(ofSize: 28, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 30, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 32, weight: .black)
			}
		}
		
		static var helperText: UIFont {
			return .systemFont(ofSize: 12, weight: .regular)
		}
		
		static var helperTextBold: UIFont {
			return .systemFont(ofSize: 12, weight: .bold)
		}
		
		static var links: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .medium)
				case .medium:
					return .systemFont(ofSize: 10, weight: .medium)
				case .plus:
					return .systemFont(ofSize: 11, weight: .medium)
				case .large:
					return .systemFont(ofSize: 11, weight: .medium)
				case .modern:
					return .systemFont(ofSize: 12, weight: .medium)
				case .pro:
					return .systemFont(ofSize: 12, weight: .medium)
				case .max:
					return .systemFont(ofSize: 12, weight: .medium)
				case .madMax:
					return .systemFont(ofSize: 13, weight: .medium)
				case .proMax:
					return .systemFont(ofSize: 13, weight: .medium)
			}
		}
		
		static var buttonTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 11, weight: .black)
				case .medium:
					return .systemFont(ofSize: 12, weight: .black)
				case .plus:
					return .systemFont(ofSize: 13, weight: .black)
				case .large:
					return .systemFont(ofSize: 13, weight: .black)
				case .modern:
					return .systemFont(ofSize: 14, weight: .black)
				case .pro:
					return .systemFont(ofSize: 14, weight: .black)
				case .max:
					return .systemFont(ofSize: 14, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 14, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 14, weight: .black)
			}
		}
		
		static var buttonPrice: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 11, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 12, weight: .bold)
				case .plus:
					return .systemFont(ofSize: 12, weight: .bold)
				case .large:
					return .systemFont(ofSize: 13, weight: .bold)
				case .modern:
					return .systemFont(ofSize: 13, weight: .bold)
				case .pro:
					return .systemFont(ofSize: 13, weight: .bold)
				case .max:
					return .systemFont(ofSize: 13, weight: .bold)
				case .madMax:
					return .systemFont(ofSize: 13, weight: .bold)
				case .proMax:
					return .systemFont(ofSize: 13, weight: .bold)
			}
		}
		
		static var buttonDescription: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 9, weight: .bold)
				case .medium:
					return .systemFont(ofSize: 10, weight: .bold)
				case .plus:
					return .systemFont(ofSize: 11, weight: .bold)
				case .large:
					return .systemFont(ofSize: 11, weight: .bold)
				case .modern:
					return .systemFont(ofSize: 12, weight: .bold)
				case .pro:
					return .systemFont(ofSize: 12, weight: .bold)
				case .max:
					return .systemFont(ofSize: 12, weight: .bold)
				case .madMax:
					return .systemFont(ofSize: 12, weight: .bold)
				case .proMax:
					return .systemFont(ofSize: 12, weight: .bold)
			}
		}
		
		static var premiumBannerTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 20, weight: .black)
				case .medium:
					return .systemFont(ofSize: 24, weight: .black)
				case .plus:
					return .systemFont(ofSize: 26, weight: .black)
				case .large:
					return .systemFont(ofSize: 28, weight: .black)
				case .modern:
					return .systemFont(ofSize: 30, weight: .black)
				case .pro:
					return .systemFont(ofSize: 30, weight: .black)
				case .max:
					return .systemFont(ofSize: 32, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 33, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 33, weight: .black)
			}
		}
		
		static var permiumBannerSubtitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .regular)
				case .medium:
					return .systemFont(ofSize: 11, weight: .regular)
				case .plus:
					return .systemFont(ofSize: 12, weight: .regular)
				case .large:
					return .systemFont(ofSize: 13, weight: .regular)
				case .modern:
					return .systemFont(ofSize: 13, weight: .regular)
				case .pro:
					return .systemFont(ofSize: 13, weight: .regular)
				case .max:
					return .systemFont(ofSize: 14, weight: .regular)
				case .madMax:
					return .systemFont(ofSize: 14, weight: .regular)
				case .proMax:
					return .systemFont(ofSize: 14, weight: .regular)
			}
		}
		
		static var premiumBannerDateSubtitle: UIFont {
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
					return .systemFont(ofSize: 13, weight: .bold)
				case .pro:
					return .systemFont(ofSize: 13, weight: .bold)
				case .max:
					return .systemFont(ofSize: 14, weight: .bold)
				case .madMax:
					return .systemFont(ofSize: 14, weight: .bold)
				case .proMax:
					return .systemFont(ofSize: 14, weight: .bold)
			}
		}
		
		static var premiumFeatureBannerTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 14, weight: .black)
				case .medium:
					return .systemFont(ofSize: 16, weight: .black)
				case .plus:
					return .systemFont(ofSize: 18, weight: .black)
				case .large:
					return .systemFont(ofSize: 20, weight: .black)
				case .modern:
					return .systemFont(ofSize: 20, weight: .black)
				case .pro:
					return .systemFont(ofSize: 20, weight: .black)
				case .max:
					return .systemFont(ofSize: 22, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 22, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 22, weight: .black)
			}
		}
		
		static var premiumFeatureBannerSubtitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 12, weight: .black)
				case .medium:
					return .systemFont(ofSize: 14, weight: .black)
				case .plus:
					return .systemFont(ofSize: 16, weight: .black)
				case .large:
					return .systemFont(ofSize: 18, weight: .black)
				case .modern:
					return .systemFont(ofSize: 18, weight: .black)
				case .pro:
					return .systemFont(ofSize: 18, weight: .black)
				case .max:
					return .systemFont(ofSize: 20, weight: .black)
				case .madMax:
					return .systemFont(ofSize: 20, weight: .black)
				case .proMax:
					return .systemFont(ofSize: 20, weight: .black)
			}
		}
		
		static var premiumFeatureBannerSubtitleTitle: UIFont {
			switch screenSize {
				case .small:
					return .systemFont(ofSize: 10, weight: .medium)
				case .medium:
					return .systemFont(ofSize: 12, weight: .medium)
				case .plus:
					return .systemFont(ofSize: 14, weight: .medium)
				case .large:
					return .systemFont(ofSize: 16, weight: .medium)
				case .modern:
					return .systemFont(ofSize: 16, weight: .medium)
				case .pro:
					return .systemFont(ofSize: 16, weight: .medium)
				case .max:
					return .systemFont(ofSize: 18, weight: .medium)
				case .madMax:
					return .systemFont(ofSize: 18, weight: .medium)
				case .proMax:
					return .systemFont(ofSize: 18, weight: .medium)
			}
		}
	}
}


