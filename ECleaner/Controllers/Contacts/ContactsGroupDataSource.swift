//
//  ContactsGroupDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit

class ContactsGroupDataSource: NSObject {
    
    public var contactGroupListViewModel: ContactGroupListViewModel
    
    init(viewModel: ContactGroupListViewModel) {
        self.contactGroupListViewModel = viewModel
    }
}

extension ContactsGroupDataSource {
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
        
        guard let contact = contactGroupListViewModel.getContact(at: indexPath) else { return }
        
        cell.updateContactCell(contact)
    }
}

extension ContactsGroupDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactGroupListViewModel.numbersOfSections()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactGroupListViewModel.numbersOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! ContactTableViewCell
        self.cellConfigure(cell: cell, at: indexPath)
        return cell
    }
}


