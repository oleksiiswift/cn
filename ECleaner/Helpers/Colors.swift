//
//  Colors.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

enum CurrentTheme: Int {
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
}

