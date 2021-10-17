//
//  PhotoMediaType.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import Foundation

enum PhotoMediaType: String {
    
    case similarPhotos = "similarPhotos"
    case duplicatedPhotos = "duplicatedPhotos"
    case singleScreenShots = "singleScreenShots"
    case singleLivePhotos = "singleLivePhotos"
    case similarLivePhotos = "similarLivePhotos"

    case singleLargeVideos = "singleLargeVideos"
    case duplicatedVideos = "duplicatedVideos"
    case similarVideos = "similarVideos"
    
    case singleSelfies = "singleSelfies"
    case singleScreenRecordings = "singleScreenRecordings"
    
    case singleRecentlyDeletedPhotos = "singleRecentlyDeletedPhotos"
    case singleRecentlyDeletedVideos = "singleRecentlyDeletedVideos"
    
    case allContacts = "allContacts"
    case emptyContacts = "emptyContacts"
    case duplicatedContacts = "duplicatedContacts"
    
    case none = ""
    
    /// use this only for deep cleab screen section
    var indexPath: IndexPath {
     
        switch self {
            case .similarPhotos:
                return IndexPath(row: 0, section: 1)
            case .duplicatedPhotos:
                return IndexPath(row: 1, section: 1)
            case .singleScreenShots:
                return IndexPath(row: 2, section: 1)
            case .similarLivePhotos:
                return IndexPath(row: 3, section: 1)
            case .singleLargeVideos:
                return IndexPath(row: 0, section: 2)
            case .duplicatedVideos:
                return IndexPath(row: 1, section: 2)
            case .similarVideos:
                return IndexPath(row: 2, section: 2)
            case .singleScreenRecordings:
                return IndexPath(row: 3, section: 2)
            case .allContacts:
                return IndexPath(row: 0, section: 3)
            case .emptyContacts:
                return IndexPath(row: 1, section: 3)
            case .duplicatedContacts:
                return IndexPath(row: 2, section: 3)
            default:
                return IndexPath()
        }
    }
    
    var mediaTypeName: String {
        
        switch self {
            case .duplicatedPhotos:
                return "duplicated photo"
            case .duplicatedVideos:
                return "duplicated video"
            case .similarPhotos:
                return "similar photo"
            case .similarVideos:
                return "similar video"
            case .similarLivePhotos:
                return "similar live photo"
            case .singleSelfies:
                return "similar selfie"
            case .singleLivePhotos:
                return "single live video"
            case .singleLargeVideos:
                return "large video"
            case .singleScreenShots:
                return "screenshots"
            case .singleScreenRecordings:
                return "screen recordings"
            case .singleRecentlyDeletedPhotos:
                return "recently deleted photos"
            case .singleRecentlyDeletedVideos:
                return "recentle deleted video"
            case .allContacts:
                return "all contacts"
            case .emptyContacts:
                return "empty contacts"
            case .duplicatedContacts:
                return "duplicated contacts"
            case .none:
                return ""
        }
    }
}

class MediaType {
    
    /// use this only for deep cleab screen section
    public static func getMediaContentType(from indexPath: IndexPath) -> PhotoMediaType {
        
        switch indexPath.section {
            case 1:
                /// `photo section`
                switch indexPath.row {
                    case 0:
                        return .similarPhotos
                    case 1:
                        return .duplicatedPhotos
                    case 2:
                        return .singleScreenShots
                    case 3:
                        return .similarLivePhotos
                    default:
                        return .none
                }
            case 2:
                /// `video section`
                switch indexPath.row {
                    case 0:
                        return .singleLargeVideos
                    case 1:
                        return .duplicatedVideos
                    case 2:
                        return .similarVideos
                    case 3:
                        return .singleScreenRecordings
                    default:
                        return .none
                }
            case 3:
                /// `contats section`
                switch indexPath.row {
                    case 0:
                        return .allContacts
                    case 1:
                        return .emptyContacts
                    case 2:
                        return .duplicatedContacts
                    default:
                        return .none
                }
            default:
                return .none
        }   
    }
}
