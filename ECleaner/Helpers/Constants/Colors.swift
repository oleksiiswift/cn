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
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
  
  var dateViewBackgroundColor: UIColor {
    switch self {
      case .light:
        return UIColor().colorFromHexString("E1E8F0")
      case .dark:
        return UIColor().colorFromHexString("FFFFFF")
    }
  }
  
  var blueTextColor: UIColor {
    switch self {
      case .light:
        return UIColor().colorFromHexString("3587E3")
      case .dark:
        return UIColor().colorFromHexString("FFFFFF")
    }
  }
  
  var titleTextColor: UIColor {
    switch self {
      case .light:
        return UIColor().colorFromHexString("374058")
      case .dark:
        return UIColor().colorFromHexString("374058")
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
    
    
    
    
    
    var activeTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
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
    
    var progressBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("dedede")
            case .dark:
                return UIColor().colorFromHexString("dedede")
        }
    }
}

