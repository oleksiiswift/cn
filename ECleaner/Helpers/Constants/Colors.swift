//
//  Colors.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

enum Theme: Int {
    case light
    case dark
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
            case .light:
                return .darkContent
            case .dark:
                return .lightContent
        }
    }
    
//    MARK: - backgroud colors -
    
    var backgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E3E8F1")
            case .dark:
                return UIColor().colorFromHexString("E3E8F1")
        }
    }
    
    var navigationBarBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E3E8F1")
            case .dark :
                return UIColor().colorFromHexString("E3E8F1")
        }
    }
    
    var cellBackGroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("ECF0F6")
            case .dark :
                return UIColor().colorFromHexString("ECF0F6")
        }
    }
    
    var innerBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E1E8F0")
            case .dark:
                return UIColor().colorFromHexString("E1E8F0")
        }
    }
    
    var separatorMainColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D8DEE9")
            case .dark :
                return UIColor().colorFromHexString("D8DEE9")
        }
    }

    var separatorHelperColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F5F9FF")
            case .dark :
                return UIColor().colorFromHexString("F5F9FF")
        }
    }
    
    var primaryButtonBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E9EFF2")
            case .dark :
                return UIColor().colorFromHexString("E9EFF2")
        }
    }

    var dropDownMenuBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F3F7FD")
            case .dark :
                return UIColor().colorFromHexString("F3F7FD")
        }
    }

    
//    MARK: - shadow colors -
    
    var topShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark :
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var sideShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D8DFEB")
            case .dark :
                return UIColor().colorFromHexString("D8DFEB")
        }
    }
    
    var bottomShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("A4B5C4")
            case .dark :
                return UIColor().colorFromHexString("A4B5C4")
        }
    }
    
    var primaryButtonTopShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark :
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var primaryButtonBottomShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D1DAE8")
            case .dark :
                return UIColor().colorFromHexString("D1DAE8")
        }
    }

//      MARK: - accent tint colors -
        
    var contactsTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("1AC18E")
            case .dark :
                return UIColor().colorFromHexString("1AC18E")
        }
    }
    
    var videosTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("418CFF")
            case .dark :
                return UIColor().colorFromHexString("418CFF")
        }
    }
    
    var phoneTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F07378")
            case .dark :
                return UIColor().colorFromHexString("F07378")
        }
    }
    
    var defaulTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("418CFF")
            case .dark :
                return UIColor().colorFromHexString("418CFF")
        }
    }
    
    var activeTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
//    MARK: - title and subtitle colors -
    
    var titleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("374058")
            case .dark:
                return UIColor().colorFromHexString("374058")
        }
    }
    
    var sectionTitleTextColor: UIColor {
        
        switch self {
            case .light:
                return UIColor().colorFromHexString("8D93A4")
            case .dark:
                return UIColor().colorFromHexString("8F97A7")
        }
    }
    
    
    
    
    
    #warning("check colors") 
// MARK: - `neeed! Check colors for new aftet this linge!!!!!
    
    var blueTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("3587E3")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    

    
    var subTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("374058").withAlphaComponent(0.5)
            case .dark:
                return UIColor().colorFromHexString("374058").withAlphaComponent(0.5)
        }
    }
    
    var customRedColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FA796F")
            case .dark:
                return UIColor().colorFromHexString("FA796F")
        }
    }
    

    
//    var progressBackgroundColor: UIColor {
//        switch self {
//            case .light:
//                return UIColor().colorFromHexString("EAF0F6")
//            case .dark:
//                return UIColor().colorFromHexString("EAF0F6")
//        }
//    }
    
    var progressBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("DCE3EB")
            case .dark:
                return UIColor().colorFromHexString("DCE3EB")
        }
    }
    
    
    
    
    
  
  
    
    var contentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F0F0F0")
            case .dark:
                return UIColor().colorFromHexString("F0F0F0")
        }
    }
    
    var accentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
//    MARK: - Tint colors -
    
    var tintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
//    MARK: - Title text colors -
    
    var navigationBarTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
    var sectionBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("C4C4C4")
            case .dark:
                return UIColor().colorFromHexString("C4C4C4")
        }
    }
}



//var templateColor: UIColor {
//    switch self {
//        case .light:
//            return UIColor().colorFromHexString("C4C4C4")
//        case .dark :
//            return UIColor().colorFromHexString("C4C4C4")
//    }
//}
