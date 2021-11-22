//
//  SingleContactsGroupOperationsListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 14.11.2021.
//

import Foundation

protocol SingleContactsGroupOperationsListener {
    func didMergeContacts(in section: Int)
    func didDeleteFullContactsGroup(in section: Int)
    func didRefactorContactsGroup(in section: Int, with indexPath: IndexPath)
}
