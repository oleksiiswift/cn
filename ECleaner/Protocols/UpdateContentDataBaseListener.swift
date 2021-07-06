//
//  UpdateContentDataBaseListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation
import Photos

protocol UpdateContentDataBaseListener {
    func getPhotoLibraryCount(count: Int, calculatedSpace: Int64)
    func getVideoCount(count: Int, calculatedSpace: Int64)
    func getContactsCount(count: Int)
    
    func getScreenAsset(_ assets: [PHAsset])
    func getFrontCameraAsset(_ assets: [PHAsset])
    func getLivePhotosAsset(_ assets: [PHAsset])
    
    func getLargeVideosAsset(_ assets: [PHAsset])
}
