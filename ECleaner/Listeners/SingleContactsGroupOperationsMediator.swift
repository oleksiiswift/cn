//
//  SingleContactsGroupOperationsMediator.swift
//  ECleaner
//
//  Created by alexey sorochan on 14.11.2021.
//

import Foundation

class SingleContactsGroupOperationMediator {
    
    class var instance: SingleContactsGroupOperationMediator {
        struct Static {
            static let instance: SingleContactsGroupOperationMediator = SingleContactsGroupOperationMediator()
        }
        return Static.instance
    }
    
    private var listener: SingleContactsGroupOperationsListener?
    private init() {}
    
    func setListener(listener: SingleContactsGroupOperationsListener) {
        self.listener = listener
    }

    func didMergeContacts(in section: Int) {
        listener?.didMergeContacts(in: section)
    }
    
    func didDeleteFullContactsGroup(in section: Int) {
        listener?.didDeleteFullContactsGroup(in: section)
    }
    
    func didRefactorContactsGroup(in section: Int, with indexPath: IndexPath) {
        didRefactorContactsGroup(in: section, with: indexPath)
    }
}
