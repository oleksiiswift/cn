//
//  ContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import UIKit
import Contacts
import SwiftMessages

enum ExportContactsAvailibleFormat {
    case vcf
    case csv
    case none
    
    var formatRowValue: String {
        switch self {
            case .vcf:
                return "VCF"
            case .csv:
                return "CSV"
            default:
                return "hello chao"
        }
    }
}

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomDoubleButtonView: BottomDoubleButtonBarView!
    @IBOutlet weak var bottomButtonView: BottomButtonBarView!
    @IBOutlet weak var bottomDoubleButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    lazy var setEditingModeOptionItem = DropDownOptionsMenuItem(titleMenu: "edit",
                                                                itemThumbnail: I.systemItems.selectItems.roundedCheckMark,
                                                                isSelected: false,
                                                                menuItem: .edit)
    
    lazy var exportAllContactOptionItem = DropDownOptionsMenuItem(titleMenu: "export",
                                                              itemThumbnail: I.systemItems.defaultItems.share,
                                                              isSelected: false,
                                                              menuItem: .share)
    
    private var bottomButtonHeight: CGFloat = 70
    public var contactContentIsEditing: Bool = false
    
    private var isSelectedAllItems: Bool {
        switch contentType {
            case .allContacts:
                return contacts.count == self.tableView.indexPathsForSelectedRows?.count
            case .emptyContacts:
                return contactGroup.flatMap({$0.contacts}).count == self.tableView.indexPathsForSelectedRows?.count
            default:
                return false
        }
    }

    public var contacts: [CNContact] = []
    public var contactListViewModel: ContactListViewModel!
    public var contactListDataSource: ContactListDataSource!
    
    public var contactGroup: [ContactsGroup] = []
    public var emptyContactGroupListViewModel: ContactGroupListViewModel!
    public var emptyContactGroupListDataSource: EmptyContactListDataSource!

    public var contentType: PhotoMediaType = .none
    public var mediaType: MediaContentType = .none
    private var contactManager = ContactsManager.shared
    private var shareManager = ShareManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setNavigationEditMode(isEditing: false)
        if contentType == .allContacts {
            setupViewModel(contacts: self.contacts)
        } else if contentType == .emptyContacts {
            setupGroupViemodel(contacts: self.contactGroup)
        }
        
        setupUI()
        setupObserversAndDelegate()
        setupTableView()
        updateColors()
        handleBottomButtonChangeAppearence(disableAnimation: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case C.identifiers.segue.showExportContacts:
                self.setupShowExportContactController(segue: segue)
            default:
                return
        }
    }
}

extension ContactsViewController: Themeble {
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        
        if contentType == .allContacts {
            navigationBar.setIsDropShadow = false
            navigationBar.setupNavigation(title: contentType.mediaTypeName,
                                          leftBarButtonImage: I.navigationItems.back,
                                          rightBarButtonImage: I.navigationItems.burgerDots,
                                          mediaType: .userContacts,
                                          leftButtonTitle: nil,
                                          rightButtonTitle: nil)
        } else if contentType == .emptyContacts {
            setSearchBarIsHiden()
            navigationBar.setupNavigation(title: contentType.mediaTypeName,
                                          leftBarButtonImage: I.navigationItems.back,
                                          rightBarButtonImage: nil,
                                          mediaType: .userContacts,
                                          leftButtonTitle: nil, rightButtonTitle: "edit")
        }
    }
    
    private func setSearchBarIsHiden() {
        
        searchBarHeightConstraint.constant = 0
        searchBarView.isHidden = true
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
            setupNavigation()
        }
    }
    
    private func setupUI() {
        
        bottomDoubleButtonView.setLeftButtonImage(I.systemItems.defaultItems.buttonShare)
        bottomDoubleButtonView.setRightButtonImage(I.systemItems.defaultItems.delete)
        bottomDoubleButtonView.setLeftButtonTitle("share")
        
        bottomButtonView.setImage(I.systemItems.defaultItems.delete)
    }
    
    private func setupViewModel(contacts: [CNContact]) {
        self.contactListViewModel = ContactListViewModel(contacts: contacts)
        self.contactListDataSource = ContactListDataSource(contactListViewModel: self.contactListViewModel, contentType: self.contentType)
        
        self.contactListViewModel.isSearchEnabled.bindAndFire { _ in
            _ = self.contactListViewModel.contactsArray
            self.tableView.reloadData()
        }
    }
    
    private func setupGroupViemodel(contacts: [ContactsGroup]) {
        self.emptyContactGroupListViewModel = ContactGroupListViewModel(contactsGroup: contacts)
        self.emptyContactGroupListDataSource = EmptyContactListDataSource(viewModel: self.emptyContactGroupListViewModel, contentType: self.contentType)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        
        if contentType == .allContacts {
            bottomDoubleButtonView.tintColor = theme.activeTitleTextColor
            bottomDoubleButtonView.rightButtonColor = theme.deleteViewButtonsColor
            bottomDoubleButtonView.leftButtonColor = theme.shareViewButtonsColor
            bottomDoubleButtonView.updateColorsSettings()
        } else if contentType == .emptyContacts {
            bottomButtonView.tintColor = theme.activeTitleTextColor
            bottomButtonView.buttonColor = theme.contactsTintColor
            bottomButtonView.updateColorsSettings()
        }
    }
    
    private func setupTableView() {
            
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        if contentType == .allContacts {
            tableView.delegate = contactListDataSource
            tableView.dataSource = contactListDataSource
        } else if contentType == .emptyContacts {
            tableView.delegate = emptyContactGroupListDataSource
            tableView.dataSource = emptyContactGroupListDataSource
        }
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
        bottomButtonView.delegate = self
        
        U.notificationCenter.addObserver(self, selector: #selector(handleSearchBarState), name: .searchBarDidCancel, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(searchBarDidMove(_:)), name: .scrollViewDidScroll, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(didSelectDeselectContact), name: .selectedContactsCountDidChange, object: nil)
    }
    
    private func setupShowExportContactController(segue: UIStoryboardSegue) {
        
        guard let segue = segue as? SwiftMessagesSegue else { return }
        
        segue.configure(layout: .bottomMessage)
        segue.dimMode = .gray(interactive: true)
        segue.interactiveHide = false
        segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
        segue.messageView.configureNoDropShadow()
        
        if let exportContactsViewController = segue.destination as? ExportContactsViewController {
            exportContactsViewController.leftExportFileFormat = .vcf
            exportContactsViewController.rightExportFileFormat = .csv
            
            exportContactsViewController.selectExportFormatCompletion = { format in
                if self.contactContentIsEditing {
                    self.exportSelectedContacts(with: format)
                } else {
                    self.exportAllContacts(with: format)
                }
            }
        }
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
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            indexPaths.forEach { indexPath in
                _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
                tableView.deselectRow(at: indexPath, animated: false)
                tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
            }
        }
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
        
        switch contentType {
            case .allContacts:
                handleAllContactsBottomButton(disableAnimation: disableAnimation, with: calculatedBottomButtonHeight)
            case .emptyContacts:
                handleEmptyContactsBottomButton(disableAnimation: disableAnimation, with: calculatedBottomButtonHeight)
            default:
                return
        }
    }
    
    private func handleAllContactsBottomButton(disableAnimation: Bool, with height: CGFloat) {
        
        bottomDoubleButtonHeightConstraint.constant = selectedItems() != 0 ? height : 0
        bottomButtonHeightConstraint.constant = 0
        
        let rightButtonTitle: String = "delete" + " (\(selectedItems()))"
        bottomDoubleButtonView.setRightButtonTitle(rightButtonTitle)
        
        if disableAnimation {
            self.bottomDoubleButtonView.layoutIfNeeded()
            self.tableView.contentInset.bottom = self.selectedItems() != 0 ? height :  34
        } else {
            U.animate(0.5) {
                self.view.layoutIfNeeded()
                self.bottomDoubleButtonView.layoutIfNeeded()
                self.tableView.contentInset.bottom = self.selectedItems() != 0 ? height :  34
            }
        }
    }
    
    private func handleEmptyContactsBottomButton(disableAnimation: Bool, with heigt: CGFloat) {
        
        bottomButtonHeightConstraint.constant = selectedItems() != 0 ? heigt : 0
        bottomDoubleButtonHeightConstraint.constant = 0
        
        let buttonTitle: String = "delete" + " (\(selectedItems()))"
        bottomButtonView.title(buttonTitle)
        
        if disableAnimation {
            self.bottomButtonView.layoutIfNeeded()
            self.tableView.contentInset.bottom = self.selectedItems() != 0 ? heigt : 34
        } else {
            U.animate(0.5) {
                self.view.layoutIfNeeded()
                self.bottomButtonView.layoutIfNeeded()
                self.tableView.contentInset.bottom = self.selectedItems() != 0 ? heigt : 34
            }
        }
    }
}

//      MARK: - handle actions buttons -
extension ContactsViewController {
    
    private func didTapCancelEditingButton() {
        P.showIndicator()
        setCancelAndDeselectAllItems()
        P.hideIndicator()
        handleEdit()
    }
    
    private func didTapSelectEditingMode() {
        
        handleEdit()
    }
    
    private func handleEdit() {
        contactContentIsEditing = !contactContentIsEditing
        if contentType == .allContacts {
            self.contactListDataSource.contactContentIsEditing = contactContentIsEditing
        } else if contentType == .emptyContacts {
            self.emptyContactGroupListDataSource.contactContentIsEditing = contactContentIsEditing
        }
        self.setContactsEditingMode(enabled: contactContentIsEditing)
        self.setNavigationEditMode(isEditing: contactContentIsEditing)
    }
    
    private func didTapExportAllContacts() {
        self.performSegue(withIdentifier: C.identifiers.segue.showExportContacts, sender: self)
    }
    
    private func didTapExportSelectedContacts() {
        self.performSegue(withIdentifier: C.identifiers.segue.showExportContacts, sender: self)
    }
    
    private func didTapDeleteSelectedContacts() {
        
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            
            var removableContacts: [CNContact] = []
            
            if contentType == .allContacts {
                removableContacts = contactListViewModel.getContacts(at: indexPaths)
            } else if contentType == .emptyContacts {
                removableContacts = emptyContactGroupListViewModel.getContacts(at: indexPaths)
            }
            self.setCancelAndDeselectAllItems()
            self.handleEdit()
            P.showIndicator()
            
            self.deleteContacts(removableContacts) {
                self.reloadContactsAfterRefactor()
            }
        }
    }
    
    private func deleteContacts(_ contacts: [CNContact], completion: @escaping() -> Void) {
        
        contactManager.deleteContacts(contacts) { suxxessful, deletedCount in
            debugPrint("deleted is \(suxxessful)")
            if deletedCount == contacts.count {
                debugPrint("all deleted")
            } else {
                debugPrint("errors count \(contacts.count - deletedCount)")
            }
            completion()
        }
    }
    
    private func reloadContactsAfterRefactor() {
        
        if contentType == .allContacts {
            self.contactManager.getAllContacts { allContacts in
                U.UI {
                    if allContacts.count != 0 {
                        P.hideIndicator()
                        self.setupViewModel(contacts: allContacts)
                        self.tableView.delegate = self.contactListDataSource
                        self.tableView.dataSource = self.contactListDataSource
                        self.tableView.reloadData()
                    } else {
                        self.closeController()
                    }
                }
            }
        } else if contentType == .emptyContacts {
            self.contactManager.getEmptyContacts { contactsGroups in
                U.UI {
                    if contactsGroups.map({$0.contacts}).count != 0 {
                        let group = contactsGroups.filter({!$0.contacts.isEmpty})
                        P.hideIndicator()
                        self.setupGroupViemodel(contacts: group)
                        self.tableView.delegate = self.emptyContactGroupListDataSource
                        self.tableView.dataSource = self.emptyContactGroupListDataSource
                        self.tableView.reloadData()
                    } else {
                        self.closeController()
                    }
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

extension ContactsViewController {
    
    private func exportAllContacts(with format: ExportContactsAvailibleFormat) {
        P.showIndicator()
        shareManager.shareAllContacts(format) { fileCreate in
            if !fileCreate {
//                TODO: Error alert
            }
        }
    }
    
    private func exportSelectedContacts(with format: ExportContactsAvailibleFormat) {
        
        if isSelectedAllItems {
            exportAllContacts(with: format)
            self.setCancelAndDeselectAllItems()
            self.handleEdit()
        } else {
            
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                var contacts: [CNContact] = []
                
                if contentType == .allContacts {
                    contacts = contactListViewModel.getContacts(at: indexPaths)
                }
                
                self.setCancelAndDeselectAllItems()
                self.handleEdit()
                
                if !contacts.isEmpty {
                    P.showIndicator()
                    shareManager.shareContacts(contacts, of: format) { fileCreated in
                        if !fileCreated {
//                            TODO show alert
                        }
                    }
                }
            }
        }
    }
}

extension ContactsViewController: BottomDoubleActionButtonDelegate {
    
    func didTapLeftActionButton() {
        self.didTapExportSelectedContacts()
    }
    
    func didTapRightActionButton() {
        self.didTapDeleteSelectedContacts()
    }
}

extension ContactsViewController: BottomActionButtonDelegate {
    
    func didTapActionButton() {
        self.didTapDeleteSelectedContacts()
    }
}

extension ContactsViewController: SelectDropDownMenuDelegate {
    
    func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
        
        switch didSelectItem {
            case .share:
                self.didTapExportAllContacts()
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
        
        if contentType == .allContacts {
            self.contactContentIsEditing ? self.didTapSelectDeselectNavigationButton() : self.didTapOpenBurgerMenu()
        } else if contentType == .emptyContacts {
            self.contactContentIsEditing ? self.didTapSelectDeselectNavigationButton() : self.didTapSelectEditingMode()
        }
    }
}

extension ContactsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


//let transition = CATransition()
//transition.type = CATransitionType.push
//transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//transition.fillMode = CAMediaTimingFillMode.forwards
//transition.duration = 0.5
//transition.subtype = CATransitionSubtype.fromTop
//self.tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
//// Update your data source here
//self.tableView.reloadData()
