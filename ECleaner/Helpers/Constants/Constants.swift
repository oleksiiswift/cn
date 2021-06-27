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
            static let photoLibraryAccessGranted = "photoLibraryAccessGranted"
            static let contactStoreAccessGranted = "contactStoreAccessGranted"
            static let startingSavedDate = "startingSavedDate"
            static let endingSavedDate = "endingSavedDate"
            
        }
    }
    
//    MARK: - public identifiers -
    struct identifiers {
        
        struct storyboards {
            static let main = "Main"
            static let media = "MediaContent"
        }
        
        struct viewControllers {
            static let advertise = "AdvertisementViewController"
            static let main = "MainViewController"
            static let content = "MediaContentViewController"
            static let datePicker = "DateSelectorViewController"
            static let assetsList = "SimpleAssetsListViewController"
        }
        
        struct cells {
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
        }
        
        struct xibs {
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
        }
        
        struct segue {
            static let showDatePicker = "ShowDatePickerSelectorViewControllerSegue"
        }
    }
    
    
    struct dateFormat {
        static let dmy = "dd-MM-yyy"
        static let dateFormat = "dd MMM, yyyy"
        static let fullDateFormat = "yyyy-MM-dd HH:mm:ss"
        static let expiredDateFormat = "dd\\MM\\yyyy"
        
    }
}
