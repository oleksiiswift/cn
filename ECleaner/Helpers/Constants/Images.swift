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
    
    struct systemItems {
        
        struct selectItems {
            static let roundedCheckMark = UIImage(named: "roundedCheckmark")!
            static let circleMark = UIImage(named: "circle")!
        }
        
        struct defaultItems {
            static let share = UIImage(named: "share")!
            static let merge = UIImage(named: "mergeArrowTop")!
        }
        
        struct backroundStaticItems {
            static let spreadBackground = UIImage(named: "dateViewBackground")!
        }
    }
    
    struct personalisation {
        
        struct contacts {
            static let sectionSelect = UIImage(named: "contactSectionSelect")!
            static let selectContact = UIImage(named: "selectContact")
            static let deselectContact = UIImage(named: "deselectContact")
            static let deleteContact = UIImage(named: "contactWithCross")!
            static let mergeContact = UIImage(named: "mergeContactArrowRight")!
        }
        
        struct photo {
            
        }
        
        struct video {
            
        }
    }
    
    
    
    
    
    
    
    
    
//  TODO: Check all images!!!!
    #warning("check all images -> ")
    struct navigationItems {
        static let dissmiss = UIImage(named: "dissmiss")!
        static let back = UIImage(named: "back")!
        static let premium = UIImage(named: "premium")!
        static let settings = UIImage(named: "settings")!
        static let elipseBurger = UIImage(systemName: "ellipsis.circle.fill")
        static let leftShevronBack = UIImage(systemName: "chevron.left")
        static let rightShevronBack = UIImage(named: "chevron")!
        static let burgerDots = UIImage(named: "burgerDots")
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
}
