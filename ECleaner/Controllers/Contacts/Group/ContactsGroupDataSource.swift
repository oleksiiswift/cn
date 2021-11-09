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
    
    private func cellConfigure(cell: GroupContactTableViewCell, at indexPath: IndexPath) {
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! GroupContactTableViewCell

        let numbersOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        self.setupShadowPath(in: cell, at: indexPath, numberOFRowsInSection: numbersOfRowsInSection)
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
            return 130
        } else if indexPath.row + 1 < numbersOfRowsInSection {
            return UITableView.automaticDimension
        } else if indexPath.row + 1 == numbersOfRowsInSection {
            return 130
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GroupContactTableViewCell else { return }
        
        let numbersOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        self.setupShadowPath(in: cell, at: indexPath, numberOFRowsInSection: numbersOfRowsInSection)
    }
}

extension ContactsGroupDataSource {
    
    private func setupShadowPath(in cell: GroupContactTableViewCell, at indexPath: IndexPath, numberOFRowsInSection: Int) {
        
        if numberOFRowsInSection <= 1 { return }
        
        if indexPath.row == 0 {
            cell.showTopInset()
            cell.topShadowView.sectionColorsPosition = .top
            cell.setupForCustomSeparator(true)
        } else if indexPath.row + 1 < numberOFRowsInSection {
            cell.topShadowView.sectionColorsPosition = .central
            cell.setupForCustomSeparator(true)
        } else if indexPath.row + 1 == numberOFRowsInSection {
            cell.showBottomInset()
            cell.topShadowView.sectionColorsPosition = .bottom
            cell.setupForCustomSeparator(false)
        }
    }
}
