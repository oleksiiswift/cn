//
//  ContactsGroupDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit

enum RowPosition {
    case top
    case middle
    case bottom
    case none
}

class ContactsGroupDataSource: NSObject {

    public var contactGroupListViewModel: ContactGroupListViewModel
    
    public var selectedSections: [Int] = []

    init(viewModel: ContactGroupListViewModel) {
        self.contactGroupListViewModel = viewModel
    }
}

extension ContactsGroupDataSource {
    
    private func cellConfigure(cell: GroupContactTableViewCell, at indexPath: IndexPath, with position: RowPosition) {
        
        guard let contact = contactGroupListViewModel.getContact(at: indexPath) else { return }
        
        let isSelected = checkIfSelectedSecetion(at: indexPath.section)
    
        cell.delegate = self
        cell.updateContactCell(contact, rowPosition: position, sectionIndex: indexPath.section, isSelected: isSelected)
    }
    
    private func configureHeader(view: GroupedContactsHeaderView, at section: Int) {
        let group = self.contactGroupListViewModel.groupSection[section]
        let countryCode = group.countryIdentifier.countryCode
        let region = group.countryIdentifier.region
        
        if countryCode != "", let country = U.locale.localizedString(forRegionCode: region) {
            let futureText = "+ \(countryCode) (\(country))"
            view.configure(futureText, index: section)
        } else {
            view.configure("-", index: section)
        }
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
        
        let rowPosition = self.checkIndexPosition(from: indexPath, numberOfRows: tableView.numberOfRows(inSection: indexPath.section))
        
        self.cellConfigure(cell: cell, at: indexPath, with: rowPosition)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: C.identifiers.views.contactGroupHeader) as! GroupedContactsHeaderView
        view.delegate = self
        configureHeader(view: view, at: section)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let rowPosition = self.checkIndexPosition(from: indexPath, numberOfRows: tableView.numberOfRows(inSection: indexPath.section))
        
        switch rowPosition {
            case .top:
                return 130
            case .middle:
                return 110
            case .bottom:
                return 130
            case .none:
                return 110
        }
    }
}

extension ContactsGroupDataSource {
    
    private func checkIndexPosition(from indexPath: IndexPath, numberOfRows: Int) -> RowPosition {
        
        if indexPath.row == 0 {
            return .top
        } else if indexPath.row + 1 < numberOfRows {
            return .middle
        } else if indexPath.row + 1 == numberOfRows {
            return .bottom
        } else {
            return .none
        }
    }
}

extension ContactsGroupDataSource: GroupContactSelectableDelegate {
    
    func didSelecMeregeSection(at index: Int) {
    
        if selectedSections.contains(index) {
            selectedSections.removeAll(index)
        } else {
            selectedSections.append(index)
        }
        
        U.notificationCenter.post(name: .mergeContactsSelectionDidChange, object: nil)
    }
    
    private func checkIfSelectedSecetion(at index: Int) -> Bool {
        
        return selectedSections.contains(index)
    }
}

extension ContactsGroupDataSource: GroupedHeadersButtonDelegate {
    
    func didTapDeleteGroupActionButton(_ tag: Int?) {
        
        guard let indexOfSection = tag else { return }
        
        SingleContactsGroupOperationMediator.instance.didDeleteFullContactsGroup(in: indexOfSection)
    }
    
    func didTapMergeGroupActionButton(_ tag: Int?) {
        
        guard let indexOfSection = tag else { return }
        
        SingleContactsGroupOperationMediator.instance.didMergeContacts(in: indexOfSection)
    }
}
