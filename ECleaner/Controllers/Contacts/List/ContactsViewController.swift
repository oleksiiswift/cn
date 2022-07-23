//
//  ContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import UIKit
import Contacts
import SwiftMessages

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
    	
	public var selectedContactsDelegate: DeepCleanSelectableAssetsDelegate?
	
    public var contactContentIsEditing: Bool = false
	public var isDeepCleaningSelectableFlow: Bool = false
	
	private var searchBarIsHiden: Bool = true
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
	
	private var previouslySelectedIndexPaths: [IndexPath] = []

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
    private var progressAlert = ProgressAlertController.shared
	private var contactStoreDidChange: Bool = false
	public var updateContentAfterProcessing: ((_ contacts: [CNContact],_ contactsGroup: [ContactsGroup],_ type: PhotoMediaType,_ contactStoreDidChangeCompletion: Bool) -> Void)?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        setupUI()
		setupDelegate()
		setupObservers()
        setupTableView()
        updateColors()
        handleBottomButtonChangeAppearence(disableAnimation: true)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		didSelectPreviousIndexPath()
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

extension ContactsViewController {
	
	private func setupDataSource() {
		
		if !isDeepCleaningSelectableFlow {
			setupNavigation()
			setNavigationEditMode(isEditing: false)
		} else {
			setupForDeepCleanNavigation()
		}
		
		if contentType == .allContacts {
			setupViewModel(contacts: self.contacts)
		} else if contentType == .emptyContacts {
			setupGroupViemodel(contacts: self.contactGroup)
		}
	}
}

extension ContactsViewController {

	@objc func didSelectDeselectContact() {
		handleBottomButtonChangeAppearence()
		handleSelectAssetsNavigationCount()
	}
	
	private func selectedItems() -> Int {
		if let selectedCount = tableView.indexPathsForSelectedRows?.count {
			return selectedCount
		} else {
			return 0
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
            self.navigationBar.handleChangeRightButtonSelectState(selectAll: setSelect)
            self.setContactsSelect(setSelect) {
                P.hideIndicator()
                self.handleBottomButtonChangeAppearence()
				self.handleSelectAssetsNavigationCount()
            }
        }
    }
    
	private func handleSelectAssetsNavigationCount() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		if selectedItems() != 0 {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: String(" (\(selectedItems()))"), image: I.systemItems.navigationBarItems.back)
		} else {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: "", image: I.systemItems.navigationBarItems.back)
		}
		
		let rightNavigationTitle: String = LocalizationService.Buttons.getButtonTitle(of: isSelectedAllItems ? .deselectAll : .selectAll)
		self.navigationBar.changeHotRightTitle(newTitle: rightNavigationTitle)
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
	
	private func handleStartingSelectableContacts() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		self.handleEdit()
		self.navigationBar.handleChangeRightButtonSelectState(selectAll: true)
		self.setContactsSelect(true) {}
	}
	
	public func handleContactsPreviousSelected(selectedContactsIDs: [String], contactsCollection: [CNContact], contactsGroupCollection: [ContactsGroup]) {
		
		if !contactsCollection.isEmpty {
			handleSinglePrevoiusSelected(contacts: contactsCollection, selectedContactsIDs: selectedContactsIDs)
		} else  if !contactsGroupCollection.isEmpty {
			handleGroupedPreviousSelected(contactsGroups: contactsGroupCollection, selectedContactsIDs: selectedContactsIDs)
		}
	}
	
	private func handleSinglePrevoiusSelected(contacts: [CNContact], selectedContactsIDs: [String]) {
		
		for selectedContactsID in selectedContactsIDs {
			let indexPath = contacts.firstIndex(where: {
				$0.identifier == selectedContactsID
			}).flatMap({
				IndexPath(row: $0, section: 0)
			})
			
			if let existingIndexPath = indexPath {
				self.previouslySelectedIndexPaths.append(existingIndexPath)
			}
		}
	}
	
	private func didSelectPreviousIndexPath() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		self.handleEdit()
		
		if !previouslySelectedIndexPaths.isEmpty {
			for indexPath in previouslySelectedIndexPaths {
				_ = tableView.delegate?.tableView?(tableView, willSelectRowAt: indexPath)
				tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
				tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
			}
		}
	}
	
	private func handleGroupedPreviousSelected(contactsGroups: [ContactsGroup], selectedContactsIDs: [String]) {
	
		for selectedContactsID in selectedContactsIDs {
			
			let sectionIndex = contactsGroups.firstIndex(where: {
				$0.contacts.contains(where: {$0.identifier == selectedContactsID})
			}).flatMap({
				$0
			})
			
			if let section = sectionIndex {
				let index: Int = Int(section)
				let indexPath = contactsGroups[index].contacts.firstIndex(where: {
					$0.identifier == selectedContactsID
				}).flatMap({
					IndexPath(row: $0, section: index)
				})
				
				if let existingIndexPath = indexPath {
					self.previouslySelectedIndexPaths.append(existingIndexPath)
				}
			}
		}
	}
}

//		MARK: - handle bottom buttins appearance -
extension ContactsViewController {
	
	private func handleBottomButtonChangeAppearence(disableAnimation: Bool = false) {
	
		let bottomButtonMenyHeight: CGFloat = AppDimensions.BottomButton.bottomBarDefaultHeight
		
		switch contentType {
			case .allContacts:
				handleAllContactsBottomButton(disableAnimation: disableAnimation, with: bottomButtonMenyHeight)
			case .emptyContacts:
				handleEmptyContactsBottomButton(disableAnimation: disableAnimation, with: bottomButtonMenyHeight)
			default:
				return
		}
	}
	
	private func handleAllContactsBottomButton(disableAnimation: Bool, with height: CGFloat) {
		
		guard !isDeepCleaningSelectableFlow else {
			bottomDoubleButtonHeightConstraint.constant = 0
			return
		}

		bottomDoubleButtonHeightConstraint.constant = selectedItems() != 0 ? height : 0
		bottomButtonHeightConstraint.constant = 0
		
		let rightButtonTitle: String = LocalizationService.Buttons.getButtonTitle(of: .delete) + " (\(selectedItems()))"
		bottomDoubleButtonView.setRightButtonTitle(rightButtonTitle)
		
		if disableAnimation {
			self.tableView.contentInset.bottom = self.selectedItems() != 0 ? height + 10 :  10
			self.bottomDoubleButtonView.layoutIfNeeded()
		} else {
			U.animate(0.5) {
				self.bottomDoubleButtonView.layoutIfNeeded()
				self.tableView.contentInset.bottom = self.selectedItems() != 0 ? height + 10 :  10
				self.view.layoutIfNeeded()
			}
		}
	}
	
	private func handleEmptyContactsBottomButton(disableAnimation: Bool, with heigt: CGFloat) {
		
		guard !isDeepCleaningSelectableFlow else {
			bottomButtonHeightConstraint.constant = 0
			bottomDoubleButtonHeightConstraint.constant = 0
			return
		}
		
		bottomButtonHeightConstraint.constant = selectedItems() != 0 ? heigt : 0
		bottomDoubleButtonHeightConstraint.constant = 0
		
		let buttonTitle: String = LocalizationService.Buttons.getButtonTitle(of: .delete) + " (\(selectedItems()))"
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

//		MARK: - handle editing mode-
extension ContactsViewController {
	
	private func setContactsEditingMode(enabled: Bool) {
			
		tableView.allowsMultipleSelection = enabled
		tableView.allowsSelection = enabled
		self.tableView.reloadDataWithoutAnimation()
	}
	
	private func handleEdit() {
		contactContentIsEditing = !contactContentIsEditing
		
		if #available(iOS 14.0, *) {
			contactContentIsEditing ? deInitdropDownSetup() : dropDownSetup()
		}
	
		if contentType == .allContacts {
			self.contactListDataSource.contactContentIsEditing = contactContentIsEditing
		} else if contentType == .emptyContacts {
			self.emptyContactGroupListDataSource.contactContentIsEditing = contactContentIsEditing
		}
		self.setContactsEditingMode(enabled: contactContentIsEditing)
		
		isDeepCleaningSelectableFlow ? self.setupForDeepCleanNavigation() : self.setNavigationEditMode(isEditing: contactContentIsEditing)
	}
}

//      MARK: - handle actions buttons -
extension ContactsViewController {
	
	private func didTapCancelEditingButton() {
		P.showIndicator()
		resetContreollerState()
		P.hideIndicator()
	}
	
	private func didTapSelectEditingMode() {
		handleEdit()
	}
	
    private func didTapExportAllContacts() {
        self.performSegue(withIdentifier: C.identifiers.segue.showExportContacts, sender: self)
    }
    
    private func didTapExportSelectedContacts() {
        self.performSegue(withIdentifier: C.identifiers.segue.showExportContacts, sender: self)
    }

    private func didTapOpenBurgerMenu() {
  
		if #available(iOS 14.0, *) {} else {
			let menuItems = getDropDownItems()
			presentDropDonwMenu(with: menuItems, from: navigationBar.rightBarButtonItem)
		}
    }
	
	func getDropDownItems() -> [MenuItem] {
		
		let editing: MenuItem = .init(type: .edit, selected: true)
		let share: MenuItem = .init(type: .export, selected: true)
		return [editing, share]
	}
	
	@available(iOS 14.0, *)
	func dropDownSetup() {
		let menuItems = getDropDownItems()
		let menu = performMenu(from: menuItems)
		navigationBar.rightBarButtonItem.menu = menu
		navigationBar.rightBarButtonItem.showsMenuAsPrimaryAction = true
		
		navigationBar.rightBarButtonItem.onMenuActionTriggered { menu in
			let updatedItems = self.getDropDownItems()
			self.navigationBar.rightBarButtonItem.menu = self.performMenu(from: updatedItems)
			return menu
		}
	}
	
	@available(iOS 14.0, *)
	func deInitdropDownSetup() {
		navigationBar.rightBarButtonItem.showsMenuAsPrimaryAction = false
		navigationBar.rightBarButtonItem.menu = nil
	}
	
	private func performMenu(from items: [MenuItem]) -> UIMenu {
		var actions: [UIAction] = []
		
		items.forEach { item in
			let attributes: UIMenuElement.Attributes = item.selected ? [] : .disabled
			let action = UIAction(title: item.title, image: item.thumbnail, attributes: attributes) { _ in
				self.handleDropDownMenu(item.type)
			}
			actions.append(action)
		}
		return UIMenu(children: actions)
	}

    private func presentDropDonwMenu(with items: [MenuItem], from navigationButton: UIButton) {
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
		self.navigationController?.popViewController(animated: true, completion: {
			self.updateContentAfterProcessing?(self.contacts, self.contactGroup, self.contentType, self.contactStoreDidChange)
		})
    }
}

//	MARK: - delete contacts module -
extension ContactsViewController {
	
	private func showDeleteContactsAlert() {
		P.showIndicator()
		guard let indexPaths = self.tableView.indexPathsForSelectedRows else {
			P.hideIndicator()
			return
		}
		U.delay(0.33) {
			P.hideIndicator()
			AlertManager.showDeleteAlert(with: .userContacts, of: .getRaw(from: indexPaths.count)) {
				P.showIndicator()
				U.delay(0.33) {
					self.contactManager.contactsProcessingOperationQueuer.cancelAll()
					self.deleteSelectedContacts(at: indexPaths)
				}
			}
		}
	}
	
	private func deleteSingleContact(at indexPath: IndexPath) {
		AlertManager.showDeleteAlert(with: .userContacts, of: .one) {
			P.showIndicator()
			U.delay(0.33) {
				self.contactManager.contactsProcessingOperationQueuer.cancelAll()
				self.deleteSelectedContacts(at: [indexPath])
			}
		}
	}
	
	private func deleteSelectedContacts(at indexPaths: [IndexPath]) {
	
		var removableContacts: [CNContact] = []
		if contentType == .allContacts {
			removableContacts = contactListViewModel.getContacts(at: indexPaths)
		} else if contentType == .emptyContacts {
			removableContacts = emptyContactGroupListViewModel.getContacts(at: indexPaths)
		}
		self.deleteContacts(removableContacts, updatebleIndexPath: indexPaths) {
			U.delay(0.5) {
				self.reloadContactsAfterRefactor(of: removableContacts, from: indexPaths)
			}
		}
	}
	
	private func deleteContacts(_ contacts: [CNContact], updatebleIndexPath: [IndexPath], completion: @escaping() -> Void) {
		P.hideIndicator()
		self.showDeleteProgressAlert()
		self.contactManager.deleteAsyncContacts(contacts) { currentDeletingContactIndex in
			self.updateProgressAlert(of: .deleteContacts, currentPosition: currentDeletingContactIndex, totalProcessing: contacts.count)
		} completionHandler: { errorsCount in
			U.delay(0.5) {
				if errorsCount != contacts.count {
//					AlertManager.showDeleteAlert(with: .userContacts, of: .getRaw(from: contacts.count)) {}
				} else {
					ErrorHandler.shared.showDeleteAlertError(.errorDeleteContacts)
				}
				completion()
			}
		}
	}
	
	private func reloadContactsAfterRefactor(of deletedContacts: [CNContact], from updatableIndexPath: [IndexPath]) {
		
		P.showIndicator()
		contactContentIsEditing ? self.handleEdit() : ()
		U.delay(0.33) {
			
			if self.searchBarView.searchBarIsActive {
				self.resetSearchBarState()
				self.setActiveSearchBar(setActive: false)
			}
			
			self.contactStoreDidChange = true
			
			if self.contentType == .allContacts {
				self.tableView.performBatchUpdates {
					self.contactManager.getAllContacts { allContacts in
						U.UI {
							if allContacts.count != 0 {
								defer {
									self.smoothReloadData(with: 0.25)
								}
								
								self.setupViewModel(contacts: allContacts, reloadData: false)
								self.tableView.delegate = self.contactListDataSource
								self.tableView.dataSource = self.contactListDataSource
								
								P.hideIndicator()
								self.handleBottomButtonChangeAppearence()
							} else {
								P.hideIndicator()
								self.closeController()
							}
						}
					}
				}
			} else if self.contentType == .emptyContacts {
				self.contactGroup.forEach { group in
					let removableIndicates = group.contacts.map({deletedContacts.firstIndex(of: $0)}).compactMap { $0 }
					if !removableIndicates.isEmpty {
						_ = group.contacts.remove(elementsAtIndices: removableIndicates)
					}
				}
				U.UI {
					if self.contactGroup.flatMap({$0.contacts}).count != 0 {
						self.contactGroup = self.contactGroup.filter({!$0.contacts.isEmpty})
						self.setupGroupViemodel(contacts: self.contactGroup)
						self.tableView.delegate = self.emptyContactGroupListDataSource
						self.tableView.dataSource = self.emptyContactGroupListDataSource
						self.smoothReloadData(with: 0.25)
						P.hideIndicator()
						self.handleBottomButtonChangeAppearence()
					} else {
						P.hideIndicator()
						self.closeController()
					}
				}
			}
		}
	}
}

//		MARK: - export contacts module -
extension ContactsViewController {
    
    private func exportAllContacts(with format: ExportContactsAvailibleFormat) {
        P.showIndicator()
        shareManager.shareAllContacts(format) { fileCreate in
            if !fileCreate {
                ErrorHandler.shared.showLoadAlertError(.errorCreateExportFile)
            }
        }
    }
    
    private func exportSelectedContacts(with format: ExportContactsAvailibleFormat) {
        
        if isSelectedAllItems {
            exportAllContacts(with: format)
			self.resetContreollerState()
        } else {
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                var contacts: [CNContact] = []
                
                if contentType == .allContacts {
                    contacts = contactListViewModel.getContacts(at: indexPaths)
                }
                
				self.resetContreollerState()
	
                if !contacts.isEmpty {
                    P.showIndicator()
                    shareManager.shareContacts(contacts, of: format) { fileCreated in
                        if !fileCreated {
                            ErrorHandler.shared.showLoadAlertError(.errorCreateExportFile)
                        }
                    }
                }
            }
        }
    }
	
	private func shareSingleContact(at indexPath: IndexPath) {
		let contacts = contactListViewModel.getContacts(at: [indexPath])
		shareManager.shareContacts(contacts, of: .vcf) { fileCreated in
			if !fileCreated {
				ErrorHandler.shared.showLoadAlertError(.errorCreateExportFile)
			}
		}
	}
}

	//		MARK: - bottom action button/buttons -
extension ContactsViewController: BottomDoubleActionButtonDelegate {
    
    func didTapLeftActionButton() {
        self.didTapExportSelectedContacts()
    }
    
    func didTapRightActionButton() {
        self.showDeleteContactsAlert()
    }
}

extension ContactsViewController: BottomActionButtonDelegate {
    
    func didTapActionButton() {
        self.showDeleteContactsAlert()
    }
}

//      MARK: - hadle search bar -
extension ContactsViewController {
    
    private func setActiveSearchBar(setActive: Bool) {
		
		self.searchBarTopConstraint.constant = setActive ? 5 : AppDimensions.ContactsController.SearchBar.searchBarTopInset
        self.searchBarView.searchBarIsActive = setActive
		self.searchBarView.setShowCancelButton(setActive, animated: true)
        contactListDataSource.searchBarIsFirstResponder = setActive
		U.animate(0.3) {
			self.view.layoutIfNeeded()
			self.searchBarView.layoutIfNeeded()
            self.navigationBar.containerView.alpha = setActive ? 0 : 1
            self.navigationBar.layoutIfNeeded()
        }
    }
	
	private func resetContreollerState(_ withCancelSearch: Bool = false) {
		self.setCancelAndDeselectAllItems()
		self.handleEdit()
		withCancelSearch ? self.resetSearchBarState() : ()
	}
	
	@objc func resetSearchBarState() {
		U.UI {
			if self.contactListViewModel.searchContact.value != "" {
				self.contactListViewModel.searchContact.value = ""
			}
			
			if self.searchBarView.searchBar.text != "" {
				self.searchBarView.searchBar.text = ""
			}
			self.contactListViewModel.updateSearchState()
			self.setActiveSearchBar(setActive: false)
			self.handleBottomButtonChangeAppearence()
			self.contactContentIsEditing ? self.handleEdit() : ()
		}
	}
    
    @objc func contentDidBeginDraging() {
        
		guard searchBarTopConstraint.constant != AppDimensions.ContactsController.SearchBar.searchBarTopInset else { return }
        
        if searchBarView.searchBar.text == "" {
            setActiveSearchBar(setActive: false)
        } else {
			searchBarTopConstraint.constant = AppDimensions.ContactsController.SearchBar.searchBarTopInset
            U.animate(0.3) {
                self.navigationBar.containerView.alpha = 1
                self.navigationBar.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func searchBarDidMove(_ notification: Notification) {
        
        guard let _ = notification.userInfo else { return }
    }
    
    @objc func searchBarResignFirstResponder() {
        searchBarView.searchBar.resignFirstResponder()
        setActiveSearchBar(setActive: false)
    }
    
    @objc func dissmissKeyboardResponder() {
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
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBarView.searchBar.resignFirstResponder()
    }
	
	@objc func searchBarClearButtonClicked() {
		self.contactContentIsEditing ? self.resetContreollerState() : ()
		self.setCancelAndDeselectAllItems()
		self.handleBottomButtonChangeAppearence(disableAnimation: true)
	}
}

extension ContactsViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        
		if isDeepCleaningSelectableFlow {
			self.didTapDeepCleanCloseController()
		} else {
			self.contactContentIsEditing ?  self.didTapCancelEditingButton() : self.closeController()
		}
    }
    
    func didTapRightBarButton(_ sender: UIButton) {
        
        if contentType == .allContacts {
            self.contactContentIsEditing ? self.didTapSelectDeselectNavigationButton() : self.didTapOpenBurgerMenu()
        } else if contentType == .emptyContacts {
            self.contactContentIsEditing ? self.didTapSelectDeselectNavigationButton() : self.didTapSelectEditingMode()
        }
    }
	
	private func didTapDeepCleanCloseController() {
		
		if let selectedIndexPath = self.tableView.indexPathsForSelectedRows {
			if contentType == .emptyContacts {
				let contactsToRemove = emptyContactGroupListViewModel.getContacts(at: selectedIndexPath)
				let selectableIDs = contactsToRemove.map({$0.identifier})
				self.selectedContactsDelegate?.didSelect(assetsListIds: selectableIDs, contentType: contentType, updatableGroup: [], updatableAssets: [], updatableContactsGroup: contactGroup)
				self.navigationController?.popViewController(animated: true)
			}
		} else {
			self.selectedContactsDelegate?.didSelect(assetsListIds: [], contentType: contentType, updatableGroup: [], updatableAssets: [], updatableContactsGroup: contactGroup)
			self.navigationController?.popViewController(animated: true)
		}
	}
}

extension ContactsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// 		MARK: - handle progress alert controller -
extension ContactsViewController: ProgressAlertControllerDelegate {
	
	private func updateProgressAlert(of type: ProgressAlertType, currentPosition: Int, totalProcessing: Int) {
		
		let progress: CGFloat = CGFloat(100 * currentPosition / totalProcessing) / 100
		let totalProcessingString: String = "\(currentPosition) / \(totalProcessing)"
		
		U.UI {
			self.progressAlert.setProgress(progress, totalFilesProcessong: totalProcessingString)
		}
	}
    
    private func showDeleteProgressAlert() {
        progressAlert.showDeleteContactsProgressAlert()
    }
    
    func didAutoCloseController() {}
    
    func didTapCancelOperation() {
        contactManager.setProcess(.delete, state: .disable)
    }

    @objc func progressNotification(_ notification: Notification) {

        guard let userInfo = notification.userInfo else { return }
        
        if let progress = userInfo[C.key.notificationDictionary.progressAlert.progrssAlertValue] as? CGFloat, let totalFilesCount = userInfo[C.key.notificationDictionary.progressAlert.progressAlertFilesCount] as? String {
            U.UI {
                self.progressAlert.setProgress(progress, totalFilesProcessong: totalFilesCount)
            }
        }
    }
}

extension ContactsViewController: SelectDropDownMenuDelegate {
	
	func handleDropDownMenu(_ item: MenuItemType) {
		switch item {
			case .edit:
				self.didTapSelectEditingMode()
			case .export:
				self.didTapExportAllContacts()
			default:
				return
		}
	}
}

extension ContactsViewController {
	
	private func selectContactInfo(with contact: CNContact, at indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: Constants.identifiers.storyboards.contacts, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: Constants.identifiers.viewControllers.contactsInfo) as! ContactsInfoViewController
		viewController.modalPresentationStyle = .overFullScreen
		viewController.contact = contact
		
		viewController.deleteContact = {
			Utils.delay(0.33) {
				self.deleteSelectedContacts(at: [indexPath])
			}
		}
		
		self.present(viewController, animated: true)
	}
}

extension ContactsViewController: ContactDataSourceDelegate {
	func viewContact(at indexPath: IndexPath) {
		
		if self.contentType == .allContacts {
			if let contact = self.contactListViewModel.getContactOnRow(at: indexPath) {
				self.selectContactInfo(with: contact, at: indexPath)
			}
		} else if self.contentType == .emptyContacts {
			if let contact = self.emptyContactGroupListViewModel.getContactOnRow(at: indexPath) {
				self.selectContactInfo(with: contact, at: indexPath)
			}
		}
	}
	
	func shareContact(at indexPath: IndexPath) {
		self.shareSingleContact(at: indexPath)
	}
	
	func deleteContact(at indexPath: IndexPath) {
		self.deleteSingleContact(at: indexPath)
	}
}

extension ContactsViewController: Themeble {
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        
        if contentType == .allContacts {
            navigationBar.setIsDropShadow = false
			self.searchBarIsHiden = false
            navigationBar.setupNavigation(title: contentType.mediaTypeName,
                                          leftBarButtonImage: I.systemItems.navigationBarItems.back,
                                          rightBarButtonImage: I.systemItems.navigationBarItems.burgerDots,
										  contentType: .userContacts,
                                          leftButtonTitle: nil,
                                          rightButtonTitle: nil)
        } else if contentType == .emptyContacts {
			self.searchBarIsHiden = true
            navigationBar.setupNavigation(title: contentType.mediaTypeName,
                                          leftBarButtonImage: I.systemItems.navigationBarItems.back,
                                          rightBarButtonImage: nil,
										  contentType: .userContacts,
                                          leftButtonTitle: nil, rightButtonTitle: LocalizationService.Buttons.getButtonTitle(of: .edit))
        }
    }
	
	private func setupForDeepCleanNavigation() {
		
		let rightNavigationTitle: String = LocalizationService.Buttons.getButtonTitle(of: isSelectedAllItems ? .deselectAll : .selectAll)
		self.searchBarIsHiden = true
		navigationBar.setupNavigation(title: contentType.mediaTypeName,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: .userContacts,
									  leftButtonTitle: nil, rightButtonTitle: rightNavigationTitle)
	}
    
    private func setNavigationEditMode(isEditing: Bool) {
        
        if isEditing {
            let rightNavigationTitle: String = LocalizationService.Buttons.getButtonTitle(of: isSelectedAllItems ? .deselectAll : .selectAll)
			self.navigationBar.changeHotLeftTitle(newTitle: LocalizationService.Buttons.getButtonTitle(of: .cancel))
			self.navigationBar.changeHotRightTitle(newTitle: rightNavigationTitle)
        } else {
            setupNavigation()
        }
    }
    
    private func setupUI() {
         
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		
		if #available(iOS 14.0, *) {
			dropDownSetup()
		}
		
		searchBarHeightConstraint.constant = self.searchBarIsHiden ? 10 : AppDimensions.ContactsController.SearchBar.searchBarContainerHeight
		searchBarView.isHidden = self.searchBarIsHiden
		
		searchBarTopConstraint.constant = AppDimensions.ContactsController.SearchBar.searchBarTopInset
		
        bottomDoubleButtonView.setLeftButtonImage(I.systemItems.defaultItems.buttonShare)
        bottomDoubleButtonView.setRightButtonImage(I.systemItems.defaultItems.delete)
		bottomDoubleButtonView.setLeftButtonTitle(LocalizationService.Buttons.getButtonTitle(of: .share))
        
        bottomButtonView.setImage(I.systemItems.defaultItems.delete)
    }
    
	private func setupViewModel(contacts: [CNContact], reloadData: Bool = true) {
        self.contactListViewModel = ContactListViewModel(contacts: contacts)
        self.contactListDataSource = ContactListDataSource(contactListViewModel: self.contactListViewModel, contentType: self.contentType)
		self.contactListDataSource.delegate = self
        self.contactListViewModel.isSearchEnabled.bindAndFire { _ in
            _ = self.contactListViewModel.contactsArray
			reloadData ? self.smoothReloadData() : ()
        }
		
		self.contactListDataSource.didSelectViewContactInfo = { contact, indexPath in
			self.selectContactInfo(with: contact, at: indexPath)
		}
    }
    
    private func setupGroupViemodel(contacts: [ContactsGroup]) {
        self.emptyContactGroupListViewModel = ContactGroupListViewModel(contactsGroup: contacts)
        self.emptyContactGroupListDataSource = EmptyContactListDataSource(viewModel: self.emptyContactGroupListViewModel, contentType: self.contentType)
		self.emptyContactGroupListDataSource.delegate = self
		self.emptyContactGroupListDataSource.didSelectViewContactInfo = { contact, indexPath in
			self.selectContactInfo(with: contact, at: indexPath)
		}
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
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = theme.backgroundColor
//        tableView.allowsSelection = false
            /// add extra top inset
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
        view.backgroundColor = .clear
        tableView.tableHeaderView = view
    }
    
	private func smoothReloadData(with duration: Double = 0.25) {
        
		UIView.transition(with: self.tableView, duration: duration, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        } completion: { _ in
            debugPrint("data source reloaded")
        }
    }
    
    private func smoothReloadData(at indexPaths: [IndexPath]) {
		UIView.transition(with: self.tableView, duration: 0.75, options: .transitionCrossDissolve) {
            self.tableView.reloadRows(at: indexPaths, with: .none)
        } completion: { _ in
            debugPrint("data source reloaded")
        }
    }
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
		searchBarView.searchBar.delegate = self
		bottomDoubleButtonView.delegate = self
		bottomButtonView.delegate = self
		progressAlert.delegate = self
	}
	
	private func setupObservers() {
		
		U.notificationCenter.addObserver(self, selector: #selector(progressNotification(_:)), name: .progressDeleteContactsAlertDidChangeProgress, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(resetSearchBarState), name: .searchBarDidCancel, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(searchBarDidMove(_:)), name: .scrollViewDidScroll, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(contentDidBeginDraging), name: .scrollViewDidBegingDragging, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(didSelectDeselectContact), name: .selectedContactsCountDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(searchBarResignFirstResponder), name: .searchBarShouldResign, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(searchBarClearButtonClicked), name: .searchBarClearButtonClicked, object: nil)
	}

    private func setupShowExportContactController(segue: UIStoryboardSegue) {
        
        guard let segue = segue as? SwiftMessagesSegue else { return }
        
        segue.configure(layout: .bottomMessage)
        segue.dimMode = .gray(interactive: true)
        segue.interactiveHide = true
        segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
        segue.messageView.configureNoDropShadow()
        
        if let exportContactsViewController = segue.destination as? ExportContactsViewController {
            exportContactsViewController.leftExportFileFormat = .vcf
            exportContactsViewController.rightExportFileFormat = .csv
            
            exportContactsViewController.selectExportFormatCompletion = { format in
				self.contactContentIsEditing ? self.exportSelectedContacts(with: format) : self.exportAllContacts(with: format)
            }
			
			exportContactsViewController.selectExtraOptionalOption = {
				self.contactContentIsEditing ? self.didTapCancelEditingButton() : ()
			}
        }
    }
}
