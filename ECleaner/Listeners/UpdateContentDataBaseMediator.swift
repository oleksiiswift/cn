//
//  UpdateContentDataBaseMediator.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation
import Photos
import Contacts


class UpdateContentDataBaseMediator {
    
    class var instance: UpdateContentDataBaseMediator {
        struct Static {
            static let instance: UpdateContentDataBaseMediator = UpdateContentDataBaseMediator()
        }
        return Static.instance
    }
    
    private var listener: UpdateContentDataBaseListener?
    private init() {}
    
    func setListener(listener: UpdateContentDataBaseListener) {
        self.listener = listener
    }
    
    func updateContentStoreCount(mediaType: MediaContentType, itemsCount: Int, calculatedSpace: Int64?) {
        listener?.updateContentStoreCount(mediaType: mediaType, itemsCount: itemsCount, calculatedSpace: calculatedSpace)
    }
    
    func getFrontCameraAssets(_ assets: [PHAsset]) {
        listener?.getFrontCameraAssets(assets)
    }
    
    func getScreenshots(_ assets: [PHAsset]) {
        listener?.getScreenAssets(assets)
    }
    
    func getLivePhotosAssets(_ assets: [PHAsset]) {
        listener?.getLivePhotosAssets(assets)
    }
    
    func getLargeVideosAssets(_ assets: [PHAsset]) {
        listener?.getLargeVideosAssets(assets)
    }
    
    func getSimilarVidesAssets(_ assetsGroup: [PhassetGroup]) {
        listener?.getSimmilarVideosAssets(assetsGroup)
    }
    
    func getDuplicatesVideosAssets(_ assetsGroup: [PhassetGroup]) {
        listener?.getSimmilarVideosAssets(assetsGroup)
    }
    
    func getScreenRecordsVideosAssets(_ assets: [PHAsset]) {
        listener?.getScreenRecordsVideosAssets(assets)
    }
    
    func getRecentlyDeletedPhotosAssets(_ assets: [PHAsset]) {
        listener?.getRecentlyDeletedPhotoAsssets(assets)
    }
    
    func getRecentlyDeletedVideosAssets(_ assets: [PHAsset]) {
        listener?.getRecentlyDeletedVideoAssets(assets)
    }
    
    func getAllContacts(_ contacts: [CNContact]) {
        listener?.getAllCNContacts(contacts)
    }
    
    func getAllEmptyContacts(_ contacts: [ContactsGroup]) {
        listener?.getAllEmptyContacts(contacts)
    }
    
    func getAllDuplicatedContactsGroup(_ contactsGroup: [ContactsGroup]) {
        listener?.getAllDuplicatedContactsGroup(contactsGroup)
    }
    
    func getAllDuplicatedNumbersContactsGroup(_ contactsGroup: [ContactsGroup]) {
        listener?.getAllDuplicatedNumbersContactsGroup(contactsGroup)
    }
    
    func getAllDuplicatedEmailsContactsGroup(_ contactsGroup: [ContactsGroup]) {
        listener?.getAllDuplicatedEmailsContactsGroup(contactsGroup)
    }

}
