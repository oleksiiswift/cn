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
    //iPhone 4-inch //iPhone 5, iPhone 5S, iPhone 5C, iPhone SE //320 x 568 points
    case medium
    //iPhone 4.7-inch //iPhone 6, iPhone 6S, iPhone 7, iPhone 8, iPhone SE2 //375 x 667 points
    case plus
    //iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus, iPhone 8 Plus //414 x 736 points
    //iPhone 5.5-inch //iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus, iPhone 8 Plus //414 x 736 points
    case large
    //iPhone 5.8-inch //iPhone X, iPhone XS, iPhone 11 Pro //375 x 812 points//
    //iPhone 5.4-inch //iPhone 12 Mini //375 x 812 points
    case modern
    //iPhone 6.1-inch //iPhone 12, iPhone 12 Pro //390 x 844 points
    case max
    //iPhone 6.1-inch //iPhone XR, iPhone 11 //414 x 896 points
    //iPhone 6.5-inch //iPhone XS Max, iPhone 11 Pro Max //414 x 896 points
    case madMax
    //iPhone 6.7-inch //iPhone 12 Pro Max //428 x 926 points
}

struct Screen {
    
    static public var size: ScreenSize {
        
        let screenSize: CGFloat = UIScreen.main.bounds.height
            /// 568 . 667 . 736 .812 . 844 . 896 . 926
		U.notificationCenter
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
            case 896:
                return .max
            case 926:
                return .madMax
            default:
                return .medium
        }
    }
}











