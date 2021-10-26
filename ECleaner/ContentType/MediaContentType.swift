//
//  MediaContentType.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit

enum MediaContentType {
    
    case userPhoto
    case userVideo
    case userContacts
    case none
    
    var navTitle: String {
        switch self {
            case .userPhoto:
            return "PHOTOS_NAV_TITLE".localized()
            case .userVideo:
            return "VIDEOS_NAV_TITLE".localized()
            case .userContacts:
            return "CONTACTS_NAV_TITLE".localized()
            case .none:
                return ""
        }
    }
    
    /// `SECTION PROPERTIES`
    var cellTitle: [Int: [Int : String]] {
        switch self {
            case .userPhoto:
                return [0: [0: "similar",
                            1: "dublicate",
                            2: "screenshots",
                            3: "selfie",
                            4: "live",
                            5: "recently deleted photo",
                            6: "face",
                            7: "location"]]
            case .userVideo:
                return [0: [0: "large video",
                            1: "duplicate",
                            2: "similart",
                            3: "screen rec",
                            4: "compress video",
                            5: "recently deleted video"]]
            case .userContacts:
                return [0: [0: "all contacts",
                            1: "empty",
                            2: "duplicates"]]
            case .none:
                return [0: [0: ""]]
        }
    }
    
    var numberOfSection: Int {
        return 1
    }
    
    var numberOfRows: Int {
        switch self {
            case .userPhoto:
                return 6
            case .userVideo:
                return 6
            case .userContacts:
                return 3
            case .none:
                return 0
        }
    }
    
    var imageOfRows: UIImage {
        switch self {
        case .userPhoto:
            return I.mainMenuThumbItems.photo
        case .userVideo:
            return I.mainMenuThumbItems.video
        case .userContacts:
            return I.mainMenuThumbItems.contacts
        case .none:
            return UIImage()
        }
    }
    
    public func getCellTitle(index: Int) -> String {
        switch self {
            case .userPhoto:
                switch index {
                    case 0:
                    return "SIMILAR_PHOTO".localized()
                    case 1:
                        return "DUBLICATES_PHOTO".localized()
                    case 2:
                        return "SCREENSHOTS".localized()
                    case 3:
                        return "SELFIE".localized()
                    case 4:
                        return "LIVE_PHOTO".localized()
                    case 5:
                        return "RECENTLY_DEL_PHOTO".localized()
                    case 6:
                        return "FACE".localized() /// do not in use
                    case 7:
                        return "LOCATION".localized() /// do not in use
                    default:
                        return ""
                }
            case .userVideo:
                switch index {
                    case 0:
                        return "LARGE_VIDEO".localized()
                    case 1:
                        return "DUPLICATE_VIDEO".localized()
                    case 2:
                        return "SIMILAR_VIDEO".localized()
                    case 3:
                        return "SCREEN_RECORDING".localized()
                    case 4:
                        return "COMPRESS_VIDEO".localized()
                    case 5:
                        return "RECENTLY_DEL_VIDEO".localized()
                    default:
                        return ""
                }
            case .userContacts:
                switch index {
                    case 0:
                        return "all contacts"
                    case 1:
                        return "empty"
                    case 2:
                        return "duplicates"
                    default:
                        return ""
                }
            case .none:
                return ""
        }
    }
    
    ///    `DEEP CLEAN PROPERTIES`
    var deepCleanNumbersOfRows: Int {
        switch self {
            case .userPhoto:
                return 4
            case .userVideo:
                return 4
            case .userContacts:
                return 3
            default:
                return 0
        }
    }

    public func getDeepCellTitle(index: Int) -> String {
        switch self {
            case .userPhoto:
                switch index {
                    case 0:
                        return "simmilar photo"
                    case 1:
                        return "dublicates photo"
                    case 2:
                        return "screenshots"
                    case 3:
                        return "similar allive photos"
                    default:
                        return ""
                }
            case .userVideo:
                switch index {
                    case 0:
                        return "large video"
                    case 1:
                        return "duplicate video"
                    case 2:
                        return "similar video"
                    case 3:
                        return "screen recording"
                    default:
                        return ""
                }
            case .userContacts:
                switch index {
                    case 0:
                        return "all contacts"
                    case 1:
                        return "empty"
                    case 2:
                        return "duplicates"
                    default:
                        return ""
                }
            case .none:
                return ""
        }
    }
}
