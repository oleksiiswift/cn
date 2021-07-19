//
//  PhotoMediaType.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import Foundation

enum PhotoMediaType {
    
    case duplicatedPhotos
    case duplicatedVideos
    case similarPhotos
    case similarVideos
    case similarLivePhotos
    
    case singleSelfies
    case singleLivePhotos
    case singleLargeVideos
    case singleScreenShots
    case singleScreenRecordings
    
    case singleRecentlyDeletedPhotos
    case singleRecentlyDeletedVideos
    
    case none
}
