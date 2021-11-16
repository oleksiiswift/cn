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
    
    public var contentType: PhotoMediaType = .none
    
    init(contactListViewModel: ContactListViewModel, contentType: PhotoMediaType) {
        
        self.contactListViewModel = contactListViewModel
        self.contentType = contentType
    }
}

extension ContactListDataSource {
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
    
        guard let contact = contactListViewModel.getContactOnRow(at: indexPath) else { return }
        cell.updateContactCell(contact, contentType: self.contentType)
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
        header.contentView.alpha = 0.8
        header.textLabel?.textColor = ThemeManager.theme.sectionTitleTextColor
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        let userInfo = [C.key.notificationDictionary.scrollDidChangeValue: contentOffset]
        U.notificationCenter.post(name: .searchBarDidChangeAppearance, object: nil, userInfo: userInfo)
    }
}
