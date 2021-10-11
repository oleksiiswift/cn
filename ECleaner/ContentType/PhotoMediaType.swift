//
//  PhotoMediaType.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import Foundation

enum PhotoMediaType {
    
    case similarPhotos
    case duplicatedPhotos
    case singleScreenShots
    case singleLivePhotos
    case similarLivePhotos

    case singleLargeVideos
    case duplicatedVideos
    case similarVideos
    
    case singleSelfies
    case singleScreenRecordings
    
    case singleRecentlyDeletedPhotos
    case singleRecentlyDeletedVideos
    
    case allContacts
    case emptyContacts
    case duplicatedContacts
    
    case none
    
    func mediaTypeName() -> String {
        
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
