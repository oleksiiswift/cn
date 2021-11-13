//
//  DropDownMenuItems.swift
//  ECleaner
//
//  Created by alekseii sorochan on 05.07.2021.
//

import UIKit

enum DropDownMenuItems {
    case unselectAll
    case changeLayout
    case share
}

struct DropDownOptionsMenuItem {
    var titleMenu: String
    var itemThumbnail : UIImage?
    var titleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    var isSelected: Bool
    var menuItem: DropDownMenuItems
}

extension DropDownOptionsMenuItem {
    
    func sizeForFutureText() -> CGSize {
        return titleMenu.size(withAttributes: [NSAttributedString.Key.font: titleFont])
    }
}

