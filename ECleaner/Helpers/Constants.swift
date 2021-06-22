//
//  Constants.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation

typealias C = Constants
class Constants {
    
    struct gadAdvertisementKey {
        /**
         - parameter GADApplicationIdentifier use in info.plist file
         - parameter gadProductionKey use when app in production
        */
        
        static let GADApplicationIdentifier = ""
        static let gadProductionKey = ""
        
        static let gadTestAppIdentifier = "ca-app-pub-3940256099942544~1458002511"
        static let gadTestKey = "ca-app-pub-3940256099942544/2934735716"
    }
    
    struct key {
        
        struct settings {
            static let isDarkModeOn = "darkModeIsSetOn"
            
            
            
            
            
        }
    }
    
    
    struct identifiers {
        
        struct storyboards {
            static let main = "Main"
        }
        
        struct viewControllers {
            static let main = "MainViewController"
            
        }
        
        struct xibs {
            
        }
    }
    
    
    struct dateFormat {
        static let dmy = "dd-MM-yyy"
    }
}
