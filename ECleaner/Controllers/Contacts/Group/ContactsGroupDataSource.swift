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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 60))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numbersOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        
        if indexPath.row == 0 {
            return 100
        } else if indexPath.row + 1 < numbersOfRowsInSection {
            return 80
        } else if indexPath.row + 1 == numbersOfRowsInSection {
            return 100
        }
        
        return 80
    }
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let groupCell = cell as? ContactTableViewCell else { return }
        
        let numbersOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        
        if numbersOfRows <= 1 { return }
        
        if indexPath.row == 0 {
            groupCell.showTopInset()
            groupCell.topShadowView.sectionColorsPosition = .top
            
        } else if indexPath.row + 1 < numbersOfRows {
            groupCell.topShadowView.sectionColorsPosition = .central
        } else if indexPath.row + 1 == numbersOfRows {
            groupCell.showBottomInset()
            groupCell.topShadowView.sectionColorsPosition = .bottom
        }
    }
}
