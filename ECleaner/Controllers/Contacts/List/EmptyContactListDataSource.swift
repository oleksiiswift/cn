//
//  EmptyContactListDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 18.11.2021.
//

import Foundation
import UIKit

class EmptyContactListDataSource: NSObject {
    
    public var emptyContactGroupListViewModel: ContactGroupListViewModel
    public var isContactAvailable: ((Bool) -> (Void)) = {_ in}
    public var didSelectContact: ((ContactListViewModel) -> Void) = {_ in}
    public var contactContentIsEditing: Bool = false
    public var contentType: PhotoMediaType = .none
    
    init(viewModel: ContactGroupListViewModel, contentType: PhotoMediaType) {
        self.emptyContactGroupListViewModel = viewModel
        self.contentType = contentType
    }
}

extension EmptyContactListDataSource {
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
    
        guard let contact = emptyContactGroupListViewModel.getContact(at: indexPath) else { return }
        cell.contactEditingMode = self.contactContentIsEditing
        cell.updateContactCell(contact, contentType: self.contentType)
    }
    
    private func didSelectDeselectContact() {
        U.notificationCenter.post(name: .selectedContactsCountDidChange, object: nil)
    }
}

extension EmptyContactListDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.emptyContactGroupListViewModel.numbersOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emptyContactGroupListViewModel.numbersOfRows(at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! ContactTableViewCell
        
        self.cellConfigure(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return emptyContactGroupListViewModel.setSectionTitle(for: section)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.didSelectDeselectContact()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.didSelectDeselectContact()
    }
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if contactContentIsEditing {
			return indexPath
		} else {
			return nil
		}
	}
}
