//
//  ContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomDoubleButtonView: BottomDoubleButtonBarView!
    @IBOutlet weak var bottomDoubleButtonHeightConstraint: NSLayoutConstraint!
    
    lazy var setEditingModeOptionItem = DropDownOptionsMenuItem(titleMenu: "edit",
                                                                itemThumbnail: I.systemItems.selectItems.roundedCheckMark,
                                                                isSelected: false,
                                                                menuItem: .edit)
    
    lazy var exportAllContactOptionItem = DropDownOptionsMenuItem(titleMenu: "export selected",
                                                              itemThumbnail: I.systemItems.defaultItems.share,
                                                              isSelected: false,
                                                              menuItem: .share)
    
    private var bottomButtonHeight: CGFloat = 70
    public var contactContentIsEditing: Bool = false
    private var isSelectedAllItems: Bool {
        return contacts.count == self.tableView.indexPathsForSelectedRows?.count
    }

    public var contactListViewModel: ContactListViewModel!
    public var contactListDataSource: ContactListDataSource!
    
    public var contacts: [CNContact] = []
    public var contentType: PhotoMediaType = .none
    public var mediaType: MediaContentType = .none
    private var contactManager = ContactsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setNavigationEditMode(isEditing: false)
        setupViewModel(contacts: self.contacts)
        setupUI()
        setupObserversAndDelegate()
        setupTableView()
        updateColors()
        handleBottomButtonChangeAppearence(disableAnimation: true)
    }
}

extension ContactsViewController: Themeble {
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        navigationBar.setIsDropShadow = false
        navigationBar.setupNavigation(title: mediaType.navigationTitle,
                                      leftBarButtonImage: I.navigationItems.back,
                                      rightBarButtonImage: I.navigationItems.burgerDots,
                                      mediaType: .userContacts,
                                      leftButtonTitle: nil,
                                      rightButtonTitle: nil)
    }
    
    private func setNavigationEditMode(isEditing: Bool) {
        
        if isEditing {
            let rightNavigationTitle: String = isSelectedAllItems ? "deselect all" : "select all"
            
            navigationBar.setupNavigation(title: mediaType.navigationTitle,
                                          leftBarButtonImage: nil,
                                          rightBarButtonImage: nil,
                                          mediaType: .userContacts,
                                          leftButtonTitle: "cancel",
                                          rightButtonTitle: rightNavigationTitle)
            
        } else {
            navigationBar.setupNavigation(title: mediaType.navigationTitle,
                                          leftBarButtonImage: I.navigationItems.back,
                                          rightBarButtonImage: I.navigationItems.burgerDots,
                                          mediaType: .userContacts,
                                          leftButtonTitle: nil,
                                          rightButtonTitle: nil)
        }
    }
    
    private func setupUI() {
        
        bottomDoubleButtonView.setLeftButtonImage(I.systemItems.defaultItems.buttonShare)
        bottomDoubleButtonView.setRightButtonImage(I.systemItems.defaultItems.delete)
        bottomDoubleButtonView.setLeftButtonTitle("share")
        
        let keyboardHide = UITapGestureRecognizer(target: self, action: #selector(searchBarResignFirstResponder))
        self.view.addGestureRecognizer(keyboardHide)
    }
    
    private func setupViewModel(contacts: [CNContact]) {
        self.contactListViewModel = ContactListViewModel(contacts: contacts)
        self.contactListDataSource = ContactListDataSource(contactListViewModel: self.contactListViewModel, contentType: self.contentType)
        
        self.contactListViewModel.isSearchEnabled.bindAndFire { _ in
            _ = self.contactListViewModel.contactsArray
            self.tableView.reloadData()
        }
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        
        bottomDoubleButtonView.tintColor = theme.activeTitleTextColor
        bottomDoubleButtonView.rightButtonColor = theme.deleteViewButtonsColor
        bottomDoubleButtonView.leftButtonColor = theme.shareViewButtonsColor
        bottomDoubleButtonView.updateColorsSettings()
    }
    
    private func setupTableView() {
        
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        tableView.delegate = contactListDataSource
        tableView.dataSource = contactListDataSource
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = theme.contacSectionIndexColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.allowsSelection = false
        /// add extra top inset 
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
        view.backgroundColor = .clear
        tableView.tableHeaderView = view
    }
        
    private func setupObserversAndDelegate() {
        
        navigationBar.delegate = self
        searchBarView.searchBar.delegate = self
        bottomDoubleButtonView.delegate = self
        
        U.notificationCenter.addObserver(self, selector: #selector(handleSearchBarState), name: .searchBarDidCancel, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(searchBarDidMove(_:)), name: .scrollViewDidScroll, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(didSelectDeselectContact), name: .selectedContactsCountDidChange, object: nil)
    }
}

extension ContactsViewController {
    
    private func setContactsEditingMode(enabled: Bool) {
            
        tableView.allowsMultipleSelection = enabled
        tableView.allowsSelection = enabled
        
        if let indexPaths = tableView.indexPathsForVisibleRows {
            self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    private func didTapSelectDeselectNavigationButton() {
        
        handleSelectDeselectAll(setSelect: !isSelectedAllItems)
    }
    
    private func handleSelectDeselectAll(setSelect: Bool) {
        
        if contacts.count > 1000 {
            U.UI {
                P.showIndicator(in: self)
            }
        }
        U.delay(0.5) {
            self.setContactsSelect(setSelect) {
                P.hideIndicator()
                self.navigationBar.handleChangeRightButtonSelectState(selectAll: setSelect)
                self.handleBottomButtonChangeAppearence()
            }
        }
    }
    
    private func setCancelAndDeselectAllItems() {
        P.showIndicator()
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            indexPaths.forEach { indexPath in
                _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
                tableView.deselectRow(at: indexPath, animated: false)
                tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
            }
        }
        P.hideIndicator()
    }
    
    private func setContactsSelect(_ allSelected: Bool, completionHandler: @escaping () -> Void) {
        
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                debugPrint(indexPath)
                if allSelected {
                    _ = tableView.delegate?.tableView?(tableView, willSelectRowAt: indexPath)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                } else {
                    _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
                    tableView.deselectRow(at: indexPath, animated: false)
                    tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
                }
            }
        }
        completionHandler()
    }
    
    @objc func didSelectDeselectContact() {
        handleBottomButtonChangeAppearence()
    }
    
    private func selectedItems() -> Int {
        if let selectedCount = tableView.indexPathsForSelectedRows?.count {
            return selectedCount
        } else {
            return 0
        }
    }
    
    private func handleBottomButtonChangeAppearence(disableAnimation: Bool = false) {
        
        let calculatedBottomButtonHeight: CGFloat = bottomButtonHeight + U.bottomSafeAreaHeight
        bottomDoubleButtonHeightConstraint.constant = selectedItems() != 0 ? calculatedBottomButtonHeight : 0
        
        let rightButtonTitle: String = "delete" + " (\(selectedItems()))"
        bottomDoubleButtonView.setRightButtonTitle(rightButtonTitle)
        
        if disableAnimation {
            self.bottomDoubleButtonView.layoutIfNeeded()
            self.tableView.contentInset.bottom = self.selectedItems() != 0 ? calculatedBottomButtonHeight :  34
        } else {
            U.animate(0.5) {
                self.view.layoutIfNeeded()
                self.bottomDoubleButtonView.layoutIfNeeded()
                self.tableView.contentInset.bottom = self.selectedItems() != 0 ? calculatedBottomButtonHeight :  34
            }
        }
    }
}

//      MARK: - handle actions buttons -
extension ContactsViewController {
    
    private func didTapCancelEditingButton() {
        
        setCancelAndDeselectAllItems()
        handleEdit()
    }
    
    private func didTapSelectEditingMode() {
        
        handleEdit()
    }
    
    private func handleEdit() {
        contactContentIsEditing = !contactContentIsEditing
        self.contactListDataSource.contactContentIsEditing = contactContentIsEditing
        self.setContactsEditingMode(enabled: contactContentIsEditing)
        self.setNavigationEditMode(isEditing: contactContentIsEditing)
    }
    
    private func didTapShareAllContacts() {}
    
    private func didTapShareSelectedContacts() {}
    
    private func didTapDeleteSelectedContacts() {
        
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            
            let contacts = contactListViewModel.getContacts(at: indexPaths)
            
            contactManager.deleteContacts(contacts) { suxxessful, deletedCount in
                if deletedCount == contacts.count {
                    debugPrint("all deleted")
                } else {
                    debugPrint("errors count \(contacts.count - deletedCount)")
                }
            }
        }
    }
    
    private func didTapOpenBurgerMenu() {
        
        presentDropDonwMenu(with: [[setEditingModeOptionItem, exportAllContactOptionItem]], from: navigationBar.rightBarButtonItem)
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

    private func closeController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactsViewController: BottomDoubleActionButtonDelegate {
    
    func didTapLeftActionButton() {
        self.didTapShareSelectedContacts()
    }
    
    func didTapRightActionButton() {
        self.didTapDeleteSelectedContacts()
    }
}

extension ContactsViewController: SelectDropDownMenuDelegate {
    
    func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
        
        switch didSelectItem {
            case .share:
                self.didTapShareAllContacts()
            case .edit:
                self.didTapSelectEditingMode()
            default:
                return
        }
    }
}

//      MARK: - hadle search bar -
extension ContactsViewController {
    
    private func setActiveSearchBar(setActive: Bool) {
        
        self.searchBarView.setShowCancelButton(setActive, animated: true)
        searchBarTopConstraint.constant = setActive ? 0 : 60
        U.animate(0.3) {
            self.navigationBar.containerView.alpha = setActive ? 0 : 1
            self.navigationBar.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleSearchBarState() {
        
        self.contactListViewModel.searchContact.value = ""
        self.contactListViewModel.updateSearchState()
        setActiveSearchBar(setActive: false)
    }
    
    @objc func searchBarDidMove(_ notification: Notification) {
        
//        guard let userInfo = notification.userInfo else { return }
    }
    
    @objc func searchBarResignFirstResponder() {
        searchBarView.searchBar.resignFirstResponder()
        setActiveSearchBar(setActive: false)
    }
}

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.setActiveSearchBar(setActive: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarView.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.contactListViewModel.searchContact.value = searchText
        self.contactListViewModel.updateSearchState()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text != "" {
            self.contactListViewModel.searchContact.value = text
            self.contactListViewModel.updateSearchState()
        }
        searchBarResignFirstResponder()
    }
}

extension ContactsViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        
        self.contactContentIsEditing ?  self.didTapCancelEditingButton() : self.closeController()
    }
    
    func didTapRightBarButton(_ sender: UIButton) {
        
        self.contactContentIsEditing ? self.didTapSelectDeselectNavigationButton() : self.didTapOpenBurgerMenu()
    }
}


extension ContactsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool // return NO to not become first responder
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) // called when text starts editing
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool // return NO to not resign first responder
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarTextDidEndEditing(_ searchBar: UISearchBar) // called when text ends editing
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) // called when text changes (including clear)
    //
    //    @available(iOS 3.0, *)
    //    optional func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool // called before text changes
    //
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarSearchButtonClicked(_ searchBar: UISearchBar) // called when keyboard search button pressed
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) // called when bookmark button pressed
    //
    //    @available(iOS 2.0, *)
    //    optional func searchBarCancelButtonClicked(_ searchBar: UISearchBar) // called when cancel button pressed
    //
    //    @available(iOS 3.2, *)
    //    optional func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) // called when search results button pressed
    //
    //
    //    @available(iOS 3.0, *)
    //    optional func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
