//
//  Images.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

typealias I = Images
class Images {

    static let blank = UIImage(named: "")
    
    struct navigationItems {
        static let dissmiss = UIImage(named: "dissmiss")!
        static let back = UIImage(named: "back")!
        static let premium = UIImage(named: "premium")!
        static let settings = UIImage(named: "settings")!
        static let elipseBurger = UIImage(systemName: "ellipsis.circle.fill")
        static let leftShevronBack = UIImage(systemName: "chevron.left")
        static let rightShevronBack = UIImage(named: "chevron")!
    }
    
    struct mainMenuThumbItems {
        static let photo = UIImage(named: "photo")!
        static let video = UIImage(named: "video")!
        static let contacts = UIImage(named: "contact")!
    }
    
    struct systemElementsItems {
        static let crissCross = UIImage(systemName: "xmark.circle.fill")
        static let checkBox = UIImage(named: "check")!
        static let checkBoxIsChecked = UIImage(systemName: "checkmark.square")
        static let circleBox = UIImage(systemName: "circle")
        static let circleCheckBox = UIImage(systemName: "checkmark.circle.fill")
        static let tileView = UIImage(systemName: "square.grid.2x2.fill")
        static let sliderView = UIImage(named: "sliderItem")
    }
    
    struct cellElementsItems {
        static let fullScreen = UIImage(systemName: "arrow.up.backward.and.arrow.down.forward")
        static let trashBin = UIImage(systemName: "trash")
    }
    
    
    struct personalElementsItems {
        static let crossContacts = UIImage(named: "crossContacts")
        static let mergeArrow = UIImage(named: "mergeArrow")!
        static let activeCheckmark = UIImage(named: "activeCheckmark")
    }
}
