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
    private var progressAlert = AlertProgressAlertController.shared
    public var contactGroup: [ContactsGroup] = []
    public var contactGroupListViewModel: ContactGroupListViewModel!
    public var contactGroupListDataSource: ContactsGroupDataSource!
    public var mediaType: MediaContentType = .none
    public var contentType: PhotoMediaType = .none
    
    private var isSelectedAllItems: Bool {
        return contactGroup.count == contactGroupListDataSource.selectedSections.count
    }
    
    private var isMergeContactsProcessing: Bool = true
    
    public var navigationTitle: String?
    private var bottomButtonHeight: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel(contacts: self.contactGroup)
        setupNavigation()
        setupTableView()
        setupObserversAndDelegate()
        handleMergeContactsAppearButton(disableAnimation: true)
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
    
    private func forceDeselectAllItems() {
        contactGroupListDataSource.selectedSections.removeAll()
        self.tableView.reloadData()
        self.handleMergeContactsAppearButton()
    }
    
    private func mergeSelectedItems() {
        
        guard !contactGroupListDataSource.selectedSections.isEmpty else { return }
        
        let totalIndexesCount = contactGroupListDataSource.selectedSections.count
        let indexesForMerged = contactGroupListDataSource.selectedSections

        self.forceDeselectAllItems()
        P.hideIndicator()
        indexesForMerged.count > 1 ?  self.showMergeProgressAlert() : ()
    
        self.updateProgressMergeAlert(with: 0, total: "0 / \(totalIndexesCount)")
        
        self.contactsManager.mergeContacts(in: self.contactGroup, merged: indexesForMerged) { suxxess, mergedIndexes  in
            
            if suxxess {
                if self.contactGroup.count == mergedIndexes.count {
                    U.UI {
                        A.showSuxxessFullMerged(for: .many) {
                            self.closeController()
                        }
                    }
                } else {
                    let errorsCont = indexesForMerged.count - mergedIndexes.count
                    U.UI {
                        if errorsCont == 0 {
                            A.showSuxxessFullMerged(for: .many) {
                                self.updateRemovedIndexes(mergedIndexes, errorsCount: 0)
                            }
                        } else {
                            A.showSuxxessFullMerged(for: .many) {
                                self.updateRemovedIndexes(mergedIndexes, errorsCount: errorsCont)
                            }
                        }
                    }
                }
            } else {
                U.UI {
                    A.showSuxxessFullMerged(for: .many) {
                        self.updateRemovedIndexes(mergedIndexes, errorsCount: 0)
                    }
                }
            }
            
            self.contactsManager.setProcess(.merge, state: .availible)
        }
    }
    
    /// `merge single section`
    private func mergeContacts(in section: Int) {
        
        let mergedSingleGroup = contactGroup[section]
        P.showIndicator()
        self.contactsManager.smartMergeContacts(in: mergedSingleGroup) { contactsToDelete in
            self.contactsManager.deleteContacts(contactsToDelete) { suxxess, deletedCount in
                P.hideIndicator()
                if suxxess {
                    if self.contactGroup.count == 1 {
                        A.showSuxxessFullMerged(for: .one) {
                            U.UI {
                                self.closeController()
                            }
                        }
                    } else {
                        U.UI {
                            A.showSuxxessFullMerged(for: .one) {
                                self.updateRemovedIndexes([section], errorsCount: 0)
                            }
                        }
                    }
                } else {
                    U.UI {
                        ErrorHandler.shared.showMergeAlertError(.errorMergeContact)
                    }
                }
            }
        }
    }
    
    private func deleteContacts(in section: Int) {
        showDeleteProgressAlert()
        let contacts = self.contactGroup[section].contacts
        
        self.contactsManager.deleteContacts(contacts) { suxxess, contactsCount in
            self.isMergeContactsProcessing = false
            if suxxess {
                if contacts.count == contactsCount {
                    if self.contactGroup.count != 1 {
                            self.updateRemovedIndexes([section], errorsCount: 0)
                    } else {
                        A.showSuxxessfullDeleted(for: .one) {
                            U.UI {
                                self.closeController()
                            }
                        }
                    }
                }
            } else {
                U.UI {
                    ErrorHandler.shared.showDeleteAlertError(.errorDeleteContacts)
                }
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

extension ContactsGroupViewController: ProgressAlertControllerDelegate {
    
    private func showDeleteProgressAlert() {
        self.isMergeContactsProcessing = false
        progressAlert.showDeleteContactsProgressAlert()
    }
    
    private func showMergeProgressAlert() {
        self.isMergeContactsProcessing = true
        progressAlert.showMergeContactsProgressAlert()
    }
    
    private func updateProgressMergeAlert(with progress: CGFloat, total filesProcessing: String) {
        U.UI {
            self.progressAlert.setProgress(progress, totalFilesProcessong: filesProcessing)
        }
    }
    
    func didTapCancelOperation() {
        contactsManager.setProcess(self.isMergeContactsProcessing ? .merge : .delete, state: .disable)
    }
    
    func didAutoCloseController() {
        
    }
    
    @objc func progressDeleteAlertNotification(_ notification: Notification) {
        guard !isMergeContactsProcessing else { return }
        guard let userInfo = notification.userInfo else { return }
        self.handleProcessNotoficationInfo(userInfo)
       
    }
    
    @objc func progressMergeAlertNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        self.handleProcessNotoficationInfo(userInfo)
    }
    
    
    private func handleProcessNotoficationInfo(_ userInfo: [AnyHashable: Any]) {
        
        if let progress = userInfo[C.key.notificationDictionary.progressAlert.progrssAlertValue] as? CGFloat,
           let totalFilesCount = userInfo[C.key.notificationDictionary.progressAlert.progressAlertFilesCount] as? String {
            U.UI {
                self.progressAlert.setProgress(progress, totalFilesProcessong: totalFilesCount)
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

//  MARK: - header delegate -
extension ContactsGroupViewController: SingleContactsGroupOperationsListener {
    
    /// `merge single section contacts`
    func didMergeContacts(in section: Int) {
        A.showMergeContactsAlert(for: .one) {
            self.mergeContacts(in: section)
        }
    }
    
    /// `delete singe section contacts`
    func didDeleteFullContactsGroup(in section: Int) {
        A.showDeleteContactsAlerts(for: .many) {
            self.deleteContacts(in: section)
        }
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
    
    /// `merge contacts from bottom button`
    func didTapActionButton() {
        A.showMergeContactsAlert(for: self.contactGroupListDataSource.selectedSections.count > 1 ? .many : .one) {
            P.showIndicator()
            self.mergeSelectedItems()
        }
    }
}

extension ContactsGroupViewController {
    
    @objc func mergeContactsDidChange(_ notification: Notification) {
        
        handleMergeContactsAppearButton()
    }
    
    private func handleMergeContactsAppearButton(disableAnimation: Bool = false) {
        
        let calculatedBottomButtonHeight: CGFloat = bottomButtonHeight + U.bottomSafeAreaHeight
        bottomButtonHeightConstraint.constant = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight : 0
        
        let buttonTitle: String = "merge selected".uppercased() + " (\(self.contactGroupListDataSource.selectedSections.count))"
        self.bottomButtonBarView.title(buttonTitle)
        
        if disableAnimation {
            self.bottomButtonBarView.layoutIfNeeded()
            self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight :  34
        } else {
            U.animate(0.5) {
                self.bottomButtonBarView.layoutIfNeeded()
            }
            self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight :  34
        }
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
        self.contactGroupListDataSource.contentType = self.contentType
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
        progressAlert.delegate = self
        
        SingleContactsGroupOperationMediator.instance.setListener(listener: self)
        U.notificationCenter.addObserver(self, selector: #selector(mergeContactsDidChange(_:)), name: .mergeContactsSelectionDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(progressDeleteAlertNotification(_:)), name: .progressDeleteContactsAlertDidChangeProgress, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(progressMergeAlertNotification(_:)), name: .progressMergeContactsAlertDidChangeProgress, object: nil)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
        bottomButtonBarView.buttonColor = theme.contactsTintColor
        bottomButtonBarView.updateColorsSettings()
    }
}
