//
//  UpdateContentDataBaseMediator.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation


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
    
    func updatePhotos(_ count: Int) {
        listener?.getPhotoLibraryCount(count: count)
    }
    
    func updateVideos(_ count: Int) {
        listener?.getVideoCount(count: count)
    }
    
    func updateContacts(_ count: Int) {
        listener?.getContactsCount(count: count)
    }
}
