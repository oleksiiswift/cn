//
//  ContactListDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import UIKit

class ContactListDataSource: NSObject {
    
    public var contactListViewModel: ContactListViewModel
    
    public var isContactAvailable: ((Bool) -> (Void)) = {_ in}
    public var didSelectContact: ((ContactListViewModel) -> Void) = {_ in }
    
    init(contactListViewModel: ContactListViewModel) {
        
        self.contactListViewModel = contactListViewModel
    }
}

extension ContactListDataSource {
    
    
    
}
