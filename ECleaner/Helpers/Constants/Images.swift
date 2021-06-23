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
        static let premium = UIImage(systemName: "crown.fill")
        static let settings = UIImage(systemName: "gear")
    }
    
    struct mainMenuThumbItems {
        static let photo = UIImage(systemName: "photo.fill")
        static let video = UIImage(systemName: "video.fill")
        static let contacts = UIImage(systemName: "person.fill")
    }
}
