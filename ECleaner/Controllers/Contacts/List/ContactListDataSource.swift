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
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
        
        guard let contact = contactListViewModel.getContactOnRow(at: indexPath) else { return }
        cell.updateContactCell(contact)
    }
}

extension ContactListDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactListViewModel.contactsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListViewModel.numbersOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! ContactTableViewCell
        self.cellConfigure(cell: cell, at: indexPath)
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactListViewModel.contactsSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactListViewModel.titleOFHeader(at: section)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = ThemeManager.theme.backgroundColor
        header.textLabel?.textColor = ThemeManager.theme.titleTextColor
        header.textLabel?.font = UIFont(font: FontManager.robotoBold, size: 18.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
