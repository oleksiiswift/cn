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
    
    public func getCellTitle(index: Int) -> String {
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
                        return "selfie"
                    case 4:
                        return "live photos"
                    case 5:
                        return "recently deleted photo"
                    case 6:
                        return "face" /// do not in use
                    case 7:
                        return "location" /// do not in use
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
                    case 4:
                        return "compress video"
                    case 5:
                        return "recently deleted video"
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
    
    public func getIndexPath(for mediaType: PhotoMediaType) -> IndexPath {
        
        switch self {
            case .userPhoto:
                switch mediaType {
                    case .similarPhotos:
                        return IndexPath(row: 0, section: 1)
                    case .duplicatedPhotos:
                        return IndexPath(row: 1, section: 1)
                    case .singleScreenShots:
                        return IndexPath(row: 2, section: 1)
                    case .similarLivePhotos:
                        return IndexPath(row: 3, section: 1)
                    default:
                        return IndexPath()
                }
            case .userVideo:
                switch mediaType {
                    case .singleLargeVideos:
                        return IndexPath(row: 0, section: 2)
                    case .duplicatedVideos:
                        return IndexPath(row: 1, section: 2)
                    case .similarVideos:
                        return IndexPath(row: 2, section: 2)
                    case .singleScreenRecordings:
                        return IndexPath(row: 3, section: 2)
                    default:
                        return IndexPath()
                }
            case .userContacts:
                switch mediaType {
                    case .allContacts:
                        return IndexPath(row: 0, section: 3)
                    case .emptyContacts:
                        return IndexPath(row: 1, section: 3)
                    case .duplicatedContacts:
                        return IndexPath(row: 2, section: 3)
                    default:
                        return IndexPath()
                }
            case .none:
                return IndexPath()
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
                        return "live photos"
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
