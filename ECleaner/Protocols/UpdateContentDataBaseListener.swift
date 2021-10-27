//
//  UpdateContentDataBaseListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation
import Photos
import Contacts

protocol UpdateContentDataBaseListener {
    func getPhotoLibraryCount(count: Int, calculatedSpace: Int64)
    func getVideoCount(count: Int, calculatedSpace: Int64)
    func getContactsCount(count: Int)
    
    func getScreenAssets(_ assets: [PHAsset])
    func getLivePhotosAssets(_ assets: [PHAsset])
    func getFrontCameraAssets(_ assets: [PHAsset])
    
    func getLargeVideosAssets(_ assets: [PHAsset])
    func getSimmilarVideosAssets(_ assets: [PhassetGroup])
    func getDuplicateVideosAssets(_ assets: [PhassetGroup])
    func getScreenRecordsVideosAssets(_ assets: [PHAsset])
    
    func getRecentlyDeletedPhotoAsssets(_ assets: [PHAsset])
    func getRecentlyDeletedVideoAssets(_ assts: [PHAsset])
    
    func getAllCNContacts(_ contacts: [CNContact])
    func getAllEmptyContacts(_ contacts: [ContactsGroup])
    func getAllDuplicatedContacts(_ contacts: [ContactsGroup])
}
