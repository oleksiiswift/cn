//
//  ContactsGroupViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit
import Contacts

class ContactsGroupViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
    @IBOutlet weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    lazy var selectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "select all",
                                                           itemThumbnail: I.systemItems.selectItems.roundedCheckMark,
                                                           isSelected: false,
                                                           menuItem: .unselectAll)
    
    lazy var deselectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "deselect all",
                                                             itemThumbnail: I.systemItems.selectItems.circleMark,
                                                             isSelected: false,
                                                             menuItem: .unselectAll)
    
    lazy var exportSelectedContacts = DropDownOptionsMenuItem(titleMenu: "export selected",
                                                              itemThumbnail: I.systemItems.defaultItems.share,
                                                              isSelected: false,
                                                              menuItem: .share)
    
    private var contactsManager = ContactsManager.shared
    
    public var contactGroup: [ContactsGroup] = []
    public var contactGroupListViewModel: ContactGroupListViewModel!
    public var contactGroupListDataSource: ContactsGroupDataSource!
    public var mediaType: MediaContentType = .none
    
    private var isSelectedAllItems: Bool {
        return contactGroup.count == contactGroupListDataSource.selectedSections.count
    }
    
    public var navigationTitle: String?
    private var bottomButtonHeight: CGFloat = 56
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel(contacts: self.contactGroup)
        setupNavigation()
        setupTableView()
        setupObserversAndDelegate()
        handleMergeContactsAppearButton()
        updateColors()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
}

extension ContactsGroupViewController: Themeble {
    
    func setupUI() {
        bottomButtonBarView.setImage(I.systemItems.defaultItems.merge)
    }
    
    func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        navigationBar.setupNavigation(title: navigationTitle, leftBarButtonImage: I.navigationItems.back, rightBarButtonImage: I.navigationItems.burgerDots, mediaType: mediaType)
    }
    
    func setupViewModel(contacts: [ContactsGroup]) {
        
        self.contactGroupListViewModel = ContactGroupListViewModel(contactsGroup: contacts)
        self.contactGroupListDataSource = ContactsGroupDataSource(viewModel: self.contactGroupListViewModel)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: C.identifiers.xibs.contactGroupHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: C.identifiers.views.contactGroupHeader)
        tableView.register(UINib(nibName: C.identifiers.xibs.groupContactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.groupContactCell)
        tableView.delegate = contactGroupListDataSource
        tableView.dataSource = contactGroupListDataSource
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset.top = 20
    }
    
    private func setupObserversAndDelegate() {
        
        navigationBar.delegate = self
        bottomButtonBarView.delegate = self
        
        SingleContactsGroupOperationMediator.instance.setListener(listener: self)
        U.notificationCenter.addObserver(self, selector: #selector(mergeContactsDidChange(_:)), name: .mergeContactsSelectionDidChange, object: nil)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
        bottomButtonBarView.buttonColor = theme.contactsTintColor
        bottomButtonBarView.updateColorsSettings()
    }
}

//      MARK: - operations with contacts methods -
extension ContactsGroupViewController {
    
    private func didSelectDeselecAllItems() {
        
        if !isSelectedAllItems {
            for index in 0...self.contactGroup.count - 1 {
                if !contactGroupListDataSource.selectedSections.contains(index) {
                    contactGroupListDataSource.selectedSections.append(index)
                }
            }
        } else {
            contactGroupListDataSource.selectedSections.removeAll()
        }
        self.tableView.reloadData()
        self.handleMergeContactsAppearButton()
    }
    
    private func mergeSelectedItems() {
        
        guard !contactGroupListDataSource.selectedSections.isEmpty else { return }
        
        let totalIndexesCount = contactGroupListDataSource.selectedSections.count
        var errorsCount: Int = 0
        var deletedIndexesCount: Int = 0
        
        contactGroupListDataSource.selectedSections.forEach { index in
            self.contactsManager.smartMergeContacts(in: self.contactGroup[index]) { deletingContacts in
                self.contactsManager.deleteContacts(deletingContacts) { suxxess, deletetCount in
                    
                    if suxxess {
                        deletedIndexesCount += 1
                    } else {
                        errorsCount += deletetCount
                        self.contactGroupListDataSource.selectedSections.remove(at: index)
                    }
                    
                    if totalIndexesCount == deletedIndexesCount {
                        if deletedIndexesCount == self.contactGroup.count {
                            U.UI {
                                debugPrint("totdo clean complete alert")
                                self.closeController()
                            }
                        } else {
                            let removableSections: [Int] = self.contactGroupListDataSource.selectedSections
                            if errorsCount == 0 {
                                debugPrint("todo alerr all contacts remove without errors")
                                self.updateRemovedIndexes(removableSections, errorsCount: errorsCount)
                            } else {
                                debugPrint("TODO show alert delete with errors")
                                self.updateRemovedIndexes(removableSections, errorsCount: 0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func mergeContacts(in section: Int) {
        
        let mergedSingleGroup = contactGroup[section]
        
        self.contactsManager.smartMergeContacts(in: mergedSingleGroup) { contactsToDelete in
            self.contactsManager.deleteContacts(contactsToDelete) { suxxess, deletedCount in
                if suxxess {
                    if self.contactGroup.count == 1 {
                        U.UI {
                            self.closeController()
                        }
                    } else {
                        self.updateRemovedIndexes([section], errorsCount: 0)
                    }
                } else {
                    debugPrint("TODO alert merge error")
                }
            }
        }
    }
    
    private func deleteContacts(in section: Int) {
        
        let contacts = self.contactGroup[section].contacts
        
        self.contactsManager.deleteContacts(contacts) { suxxess, contactsCount in
            if suxxess {
                if contacts.count == contactsCount {
                    if self.contactGroup.count != 1 {
                            self.updateRemovedIndexes([section], errorsCount: 0)
                    } else {
                        debugPrint("delete suxxess")
                        U.UI {
                            self.closeController()                            
                        }
                    }
                }
            } else {
                debugPrint("todo delete alert error")
            }
        }
    }

    private func updateRemovedIndexes(_ indexes: [Int], errorsCount: Int) {
        U.UI {
            _ = self.contactGroup.remove(elementsAtIndices: indexes)
            self.setupViewModel(contacts: self.contactGroup)
            self.tableView.delegate = self.contactGroupListDataSource
            self.tableView.dataSource = self.contactGroupListDataSource
            self.handleMergeContactsAppearButton()
            self.tableView.reloadData()
        }
    }
    
    private func exportBackupSelectedItems() {
        
        for itemInGroup in contactGroup {
            self.contactsManager.smartMergeContacts(in: itemInGroup) { deletingContacts in
                self.contactsManager.deleteContacts(deletingContacts) { suxxess, deletetCount in
                    
                }
            }
        }
    }
}

//      MARK: - burger derop down menu
extension ContactsGroupViewController: SelectDropDownMenuDelegate {
    
    private func didTapOpenBurgerMenu() {
        
        let firstRowItem = isSelectedAllItems ? self.deselectAllOptionItem : self.selectAllOptionItem
        let secontRowItem = exportSelectedContacts
        self.presentDropDonwMenu(with: [[firstRowItem, secontRowItem]], from: navigationBar.rightBarButtonItem)
    }

    private func presentDropDonwMenu(with items: [[DropDownOptionsMenuItem]], from navigationButton: UIButton) {
        let dropDownViewController = DropDownMenuViewController()
        dropDownViewController.menuSectionItems = items
        dropDownViewController.delegate = self
        
        guard let popoverPresentationController = dropDownViewController.popoverPresentationController else { return }
        
        popoverPresentationController.delegate = self
        popoverPresentationController.sourceView = navigationButton
        popoverPresentationController.sourceRect = CGRect(x: navigationButton.bounds.midX, y: navigationButton.bounds.maxY - 13, width: 0, height: 0)
        popoverPresentationController.permittedArrowDirections = .up
        self.present(dropDownViewController, animated: true, completion: nil)
    }
    
    func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
        
        switch didSelectItem {
            case .unselectAll:
                self.didSelectDeselecAllItems()
            case .share:
                self.exportBackupSelectedItems()
            default:
                return
        }
    }
}

extension ContactsGroupViewController: SingleContactsGroupOperationsListener {
    
    func didMergeContacts(in section: Int) {
        self.mergeContacts(in: section)
    }
    
    func didDeleteFullContactsGroup(in section: Int) {
        self.deleteContacts(in: section)
    }
    
    func didRefactorContactsGroup(in section: Int, with indexPath: IndexPath) {}
}

extension ContactsGroupViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ContactsGroupViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        closeController()
    }

    func didTapRightBarButton(_ sender: UIButton) {
        self.didTapOpenBurgerMenu()
    }
    
    func closeController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactsGroupViewController: BottomActionButtonDelegate {
    
    func didTapActionButton() {
        debugPrint("merge indexes")
        debugPrint(self.contactGroupListDataSource.selectedSections)
        self.mergeSelectedItems()
    }
}

extension ContactsGroupViewController {
    
    @objc func mergeContactsDidChange(_ notification: Notification) {
        
        handleMergeContactsAppearButton()
    }
    
    private func handleMergeContactsAppearButton() {
    
        let calculatedBottomButtonHeight: CGFloat = bottomButtonHeight + U.bottomSafeAreaHeight
        bottomButtonHeightConstraint.constant = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight : 0
        
        let buttonTitle: String = "merge selected".uppercased() + " (\(self.contactGroupListDataSource.selectedSections.count))"
        self.bottomButtonBarView.title(buttonTitle)
        self.bottomButtonBarView.layoutIfNeeded()
        self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight :  34
    }
}


