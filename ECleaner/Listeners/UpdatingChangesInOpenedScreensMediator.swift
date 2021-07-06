//
//  UpdatingChangesInOpenedScreensMediator.swift
//  ECleaner
//
//  Created by alekseii sorochan on 29.06.2021.
//

import Foundation

class UpdatingChangesInOpenedScreensMediator {
    
    class var instance: UpdatingChangesInOpenedScreensMediator {
        struct Static {
            static let instance: UpdatingChangesInOpenedScreensMediator = UpdatingChangesInOpenedScreensMediator()
        }
        return Static.instance
    }
    
    private var listener: UpdatingChangesInOpenedScreensListeners?
    private init() {}
    
    func setListener(listener: UpdatingChangesInOpenedScreensListeners) {
        self.listener = listener
    }
    
    func updatingChangedScreenShots() {
        listener?.getUpdatingScreenShots()
    }
    
    func updatingChangedSelfies() {
        listener?.getUpdatingSelfies()
    }
}
