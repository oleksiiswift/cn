//
//  CNContacts+FillRows.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.11.2021.
//

import Foundation
import Contacts

extension CNContact{
    func fieldStatus() -> Int {
        return self.emailAddresses.count + self.phoneNumbers.count + (self.givenName.isEmpty ? 0 : 1) + (self.familyName.isEmpty ? 0 : 1) + (self.middleName.isEmpty ? 0 : 1)
    }
}
