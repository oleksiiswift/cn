//
//  Screen.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import Foundation
import UIKit


enum ScreenSize {
    case small
//	5.5" (414 x 736 points @3x)
//	iPhone 8 Plus, iPhone 7 Plus, iPhone 6S Plus
    case medium
//	4.7" (375 x 667 points @2x)
//	iPhone SE (3rd & 2nd Gen), iPhone 8, iPhone 7, iPhone 6S
    case plus
//	5.5" (414 x 736 points @3x)
//	iPhone 8 Plus, iPhone 7 Plus, iPhone 6S Plus
    case large
//	5.8" (375 x 812 points @3x)
//	iPhone 11 Pro, iPhone XS, iPhone X
//	5.4" (375 x 812 points @3x)
//	iPhone 13 mini, iPhone 12 mini
    case modern
//	6.1" (390 x 844 points @3x)
//	iPhone 14, iPhone 13 Pro, iPhone 13, iPhone 12 Pro, iPhone 12
	case pro
//	6.1" (393 x 852 points @3x)
//	iPhone 14 Pro
    case max
//	6.5" (414 x 896 points @3x)
//	iPhone 11 Pro Max, iPhone XS Max
//	6.1" (414 x 896 points @2x)
//	iPhone 11, iPhone XR
    case madMax
//	6.7" (428 x 926 points @3x)
//	iPhone 14 Plus, iPhone 13 Pro Max, iPhone 12 Pro Max
	case proMax
//	6.7" (430 x 932 points @3x)
//	iPhone 14 Pro Max
}

struct Screen {
    
    static public var size: ScreenSize {
        
        let screenSize: CGFloat = UIScreen.main.bounds.height
            /// 568 . 667 . 736 .812 . 844 .852 .896 . 926 .932
        switch screenSize {
            case 568:
                return .small
            case 667:
                return .medium
            case 736:
                return .plus
            case 812:
                return .large
            case 844:
                return .modern
			case 852:
				return .pro
            case 896:
                return .max
            case 926:
                return .madMax
			case 932:
				return .proMax
            default:
                return .medium
        }
    }
}











