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
        static let back = UIImage(named: "back")!
        static let premium = UIImage(named: "premium")!//UIImage(systemName: "crown.fill")
        static let settings = UIImage(named: "settings")!//UIImage(systemName: "gear")
        static let elipseBurger = UIImage(systemName: "ellipsis.circle.fill")
        static let leftShevronBack = UIImage(systemName: "chevron.left")
        static let rightShevronBack = UIImage(named: "chevron")!//UIImage(systemName: "chevron.right")
    }
    
    struct mainMenuThumbItems {
        static let photo = UIImage(named: "photo")!//UIImage(systemName: "photo.fill")
        static let video = UIImage(named: "video")!//UIImage(systemName: "video.fill")
        static let contacts = UIImage(named: "contact")!//UIImage(systemName: "person.fill")
    }
    
    struct systemElementsItems {
        static let crissCross = UIImage(systemName: "xmark.circle.fill")
        static let checkBox = UIImage(systemName: "stop")
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
}
