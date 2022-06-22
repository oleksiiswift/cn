//
//  ContactsGroupViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit
import Contacts
import SwiftMessages

class ContactsGroupViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
    @IBOutlet weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
	public var selectedContactsDelegate: DeepCleanSelectableAssetsDelegate?
	
    private var contactsManager = ContactsManager.shared
    private var progressAlert = ProgressAlertController.shared
	private var shareManager = ShareManager.shared
	
    public var contactGroup: [ContactsGroup] = []
    public var contactGroupListViewModel: ContactGroupListViewModel!
    public var contactGroupListDataSource: ContactsGroupDataSource!
    public var mediaType: MediaContentType = .none
    public var contentType: PhotoMediaType = .none
	public var cleaningType: ContactasCleaningType = .none
	
	private var contactStoreDidChange: Bool = false
	public var updatableContactsAfterProcessing: ((_ contactsGroups: [ContactsGroup],_ type: PhotoMediaType,_ contactStoreDidChangeCompletion: Bool) -> Void)?
    private var isSelectedAllItems: Bool {
        return contactGroup.count == contactGroupListDataSource.selectedSections.count
    }
	public var isDeepCleaningSelectableFlow: Bool = false
	private var isMergeContactsProcessing: Bool = true
	private var previouslySelectedIndexPaths: [IndexPath] = []
    public var navigationTitle: String?
    
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
		
		!previouslySelectedIndexPaths.isEmpty ? didSelectPreviouslyIndexPath() : ()
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

//      MARK: - handle select contacts -
extension ContactsGroupViewController {
	
	private func didSelectDeselecAllItems() {
		
		if !isSelectedAllItems {
			for (index, _) in self.contactGroup.enumerated() {
				if !contactGroupListDataSource.selectedSections.contains(index) {
					contactGroupListDataSource.selectedSections.append(index)
				}
			}
		} else {
			contactGroupListDataSource.selectedSections.removeAll()
		}
		self.tableView.reloadData()
		self.handleMergeContactsAppearButton()
		handleSelectedAssetsNavigationCount()
	}
	
	private func forceDeselectAllItems() {
		contactGroupListDataSource.selectedSections.removeAll()
		self.tableView.reloadData()
		self.handleMergeContactsAppearButton()
		handleSelectedAssetsNavigationCount()
	}
	
	private func didSelectPreviouslyIndexPath() {
		
		guard isDeepCleaningSelectableFlow, !previouslySelectedIndexPaths.isEmpty else { return }
		
		for indexPath in previouslySelectedIndexPaths {
			if !contactGroupListDataSource.selectedSections.contains(indexPath.section) {
				contactGroupListDataSource.selectedSections.append(indexPath.section)
			}
		}
		
		U.UI {
			self.tableView.reloadData()
			self.handleSelectedAssetsNavigationCount()
		}
	}
	
	public func handleContactsPreviousSelected(selectedContactsIDs: [String], contactsGroupCollection: [ContactsGroup]) {
		
		for selectedContactsID in selectedContactsIDs {
			
			if let sectionIndex = contactsGroupCollection.firstIndex(where: {$0.groupIdentifier == selectedContactsID}) {
				self.previouslySelectedIndexPaths.append(IndexPath(row: 0, section: sectionIndex))
			}
		}
	}
	
	private func handleStartingSelectableAssets() {
		self.didSelectDeselecAllItems()
	}
}

//		MARK: - merge contacts -
extension ContactsGroupViewController {

    private func mergeSelectedItems() {
        
        guard !contactGroupListDataSource.selectedSections.isEmpty else { return }
        
        let totalIndexesCount = contactGroupListDataSource.selectedSections.count
        let selectedSectionsIndexes = contactGroupListDataSource.selectedSections

        self.forceDeselectAllItems()
		
        P.hideIndicator()
		
		self.showMergeProgressAlert()
        self.updateProgressMergeAlert(with: 0, total: "0 / \(totalIndexesCount)")
		self.contactStoreDidChange = true
		
		U.delay(1) {
			self.contactsManager.mergeAsyncContacts(in: self.contactGroup, merged: selectedSectionsIndexes) { progressType, currentIndex, totalIndexes in
				self.updateProgressAlert(of: .mergeContacts, currentPosition: currentIndex, totalProcessing: totalIndexes)
			} completionHandler: { success, indexes in
				let errorsCount = selectedSectionsIndexes.count - indexes.count
				
				U.delay(0.5) {
					self.contactsManager.setProcess(.merge, state: .availible)
				}
				
				U.delay(1) {
					if success {
						if self.contactGroup.count == indexes.count {
							AlertManager.showAlert(for: .mergeCompleted) {
								U.delay(1) {
									self.updateRemovedIndexes(indexes, errorsCount: errorsCount)
									self.closeController()
								}
							}
						} else {
							self.progressAlert.showSimpleProgressAlerControllerBar(of: .updatingContacts, from: self, delegate: self)
							self.updateContactsGroups { contactsGroup in
								self.progressAlert.closeProgressAnimatedController()
								self.contactGroup = contactsGroup
								self.contactGroup.isEmpty ? self.closeController() : self.reloadDataSource()
							}
						}
					} else {
						ErrorHandler.shared.showMergeAlertError(.errorMergeContacts) {
							self.closeController()
						}
					}
				}
			}
		}
    }
	
    /// `merge single section`
    private func mergeContacts(in section: Int) {
        
        let mergedSingleGroup = contactGroup[section]
        self.showMergeProgressAlert()
        self.updateProgressMergeAlert(with: 0, total: "0 / 1")
		self.contactStoreDidChange = true
		self.contactsManager.contactsMerge(in: mergedSingleGroup) { mutableContactsID, removableContacts in
			self.contactsManager.deleteAsyncContacts(removableContacts) { currentDeletingContactIndex in
			} completionHandler: { errorsCount in
				self.updateProgressMergeAlert(with: 1, total: "1 / 1")
				if errorsCount != mergedSingleGroup.contacts.count - 1 {
					if self.contactGroup.count == 1 {
						AlertManager.showAlert(for: .mergeCompleted) {
							self.contactGroup = []
							self.closeController()
						}
					} else {
						AlertManager.showAlert(for: .mergeCompleted) {
							self.progressAlert.showSimpleProgressAlerControllerBar(of: .updatingContacts, from: self, delegate: self)
							self.updateContactsGroups { contactsGroup in
								self.progressAlert.closeProgressAnimatedController()
								self.contactGroup = contactsGroup
								self.contactGroup.isEmpty ? self.closeController() : self.reloadDataSource()
							}
						}
					}
				} else {
					ErrorHandler.shared.showMergeAlertError(.errorMergeContacts) {
						self.progressAlert.showSimpleProgressAlerControllerBar(of: .updatingContacts, from: self, delegate: self)
						self.updateContactsGroups { contactsGroup in
							self.progressAlert.closeProgressAnimatedController()
							self.contactGroup = contactsGroup
							self.contactGroup.isEmpty ? self.closeController() : self.reloadDataSource()
						}
					}
				}
			}
		}
    }
}

//		MARK: - delete contacts -
extension ContactsGroupViewController {
    
	private func deleteContacts(in section: Int,_ completionHandler: @escaping(_ errorsCount: Int) -> Void) {
		P.hideIndicator()
		self.showDeleteProgressAlert()
		self.contactStoreDidChange = true
		let contacts = self.contactGroup[section].contacts
		self.contactsManager.deleteAsyncContacts(contacts) { currentDeletingContactIndex in
			self.updateProgressAlert(of: .deleteContacts, currentPosition: currentDeletingContactIndex, totalProcessing: contacts.count)
		} completionHandler: { errorsCount in
			U.delay(0.5) {
				completionHandler(errorsCount)
			}
		}
    }
}

extension ContactsGroupViewController {
	
	private func updateContactsGroups(completionHandler: @escaping (_ contactsGroup: [ContactsGroup]) -> Void) {
		
		self.contactsManager.getSingleDuplicatedCleaningContacts(of: self.cleaningType) { contactsGroup, _ in
			completionHandler(contactsGroup)
		}
	}
}

extension ContactsGroupViewController: AnimatedProgressDelegate {
	func didProgressSetCanceled() {}
}

//		MARK: - update contacts and appearance buttons and state -
extension ContactsGroupViewController {
		
	private func updateRemovedIndexes(_ indexes: [Int], errorsCount: Int) {
		U.UI {
			_ = self.contactGroup.remove(elementsAtIndices: indexes)
			self.reloadDataSource()
		}
	}
	
	private func reloadDataSource() {
		self.setupViewModel(contacts: self.contactGroup)
		self.tableView.delegate = self.contactGroupListDataSource
		self.tableView.dataSource = self.contactGroupListDataSource
		self.handleMergeContactsAppearButton()
		
		UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve) {
			self.tableView.reloadData()
		} completion: { _ in
			debugPrint("data source reloaded")
			self.handleSelectedAssetsNavigationCount()
		}
	}

	@objc func mergeContactsDidChange(_ notification: Notification) {
		
		handleMergeContactsAppearButton()
		handleSelectedAssetsNavigationCount()
	}
	
	private func handleMergeContactsAppearButton(disableAnimation: Bool = false) {
		
		guard !isDeepCleaningSelectableFlow else {
			bottomButtonHeightConstraint.constant = 0
			return
		}
		
		let calculatedBottomButtonHeight: CGFloat = AppDimensions.BottomButton.bottomBarDefaultHeight
		bottomButtonHeightConstraint.constant = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight : 0
		
		let buttonTitle: String = LocalizationService.Buttons.getButtonTitle(of: .mergeSelected).uppercased() + " (\(self.contactGroupListDataSource.selectedSections.count))"
		self.bottomButtonBarView.title(buttonTitle)
		
		if disableAnimation {
			self.bottomButtonBarView.layoutIfNeeded()
			self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight - 70:  U.bottomSafeAreaHeight - 90
		} else {
			U.animate(0.5) {
				self.bottomButtonBarView.layoutIfNeeded()
				self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight - 70 :  U.bottomSafeAreaHeight - 90
			}
		}
		self.tableView.layoutIfNeeded()
		self.view.layoutIfNeeded()
	}
	
	private func handleSelectedAssetsNavigationCount() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		if self.contactGroupListDataSource.selectedSections.isEmpty {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: "", image: I.systemItems.navigationBarItems.back)
		} else {
			
			let indexesForMergedSet = contactGroupListDataSource.selectedSections
			let contacts = indexesForMergedSet.map({contactGroup[$0]}).flatMap({$0.contacts}).count
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: String(" (\(contacts))"), image: I.systemItems.navigationBarItems.back)
		}
	}
}

//		MARK: - export share contacts -
extension ContactsGroupViewController {
	
	private func didTapSharePopUpMenuButton() {

		guard !contactGroupListDataSource.selectedSections.isEmpty else { return }
		self.performSegue(withIdentifier: C.identifiers.segue.showExportContacts, sender: self)
	}
	
	private func shareSelectedItems(with format: ExportContactsAvailibleFormat) {

		guard !contactGroupListDataSource.selectedSections.isEmpty else { return }
		let contacts = contactGroupListDataSource.selectedSections.compactMap({self.contactGroup[$0]}).flatMap({$0.contacts})
		self.export(contacts: contacts, with: format)
	}
	
	private func shareAllItems(with format: ExportContactsAvailibleFormat) {
		P.showIndicator()
		let contacts = contactGroup.flatMap({$0.contacts})
		self.export(contacts: contacts, with: format)
	}
	
	private func export(contacts: [CNContact], with format: ExportContactsAvailibleFormat) {
		if contacts.isEmpty {
			P.hideIndicator()
			ErrorHandler.shared.showEmptySearchResultsFor(.contactsIsEmpty) {}
		} else {
			self.shareManager.shareContacts(contacts, of: format) { fileCreated in
				P.hideIndicator()
				!fileCreated ? ErrorHandler.shared.showLoadAlertError(.errorCreateExportFile) : ()
				self.forceDeselectAllItems()
			}
		}
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
				self.isSelectedAllItems ? self.shareAllItems(with: format) : self.shareSelectedItems(with: format)
			}
		}
	}
}

//		MARK: - progress controller -
extension ContactsGroupViewController: ProgressAlertControllerDelegate {
    
    private func showDeleteProgressAlert() {
        self.isMergeContactsProcessing = false
		U.UI {
			self.progressAlert.showDeleteContactsProgressAlert()
		}
    }
    
    private func showMergeProgressAlert() {
        self.isMergeContactsProcessing = true
		U.UI {
			self.progressAlert.showMergeContactsProgressAlert()
		}
    }
    
    private func updateProgressMergeAlert(with progress: CGFloat, total filesProcessing: String) {
        U.UI {
            self.progressAlert.setProgress(progress, totalFilesProcessong: filesProcessing)
        }
    }
	
	private func updateProgressAlert(of type: ProgressAlertType, currentPosition: Int, totalProcessing: Int) {
		
		let progress: CGFloat = CGFloat(100 * currentPosition / totalProcessing) / 100
		let totalProcessingString: String = "\(currentPosition) / \(totalProcessing)"
		
		U.UI {
			self.progressAlert.setProgress(progress, totalFilesProcessong: totalProcessingString)
		}
	}
    
    func didTapCancelOperation() {
        contactsManager.setProcess(self.isMergeContactsProcessing ? .merge : .delete, state: .disable)
    }
    
    func didAutoCloseController() {}
    
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
	
	func getDropDownItems() -> [MenuItem] {
		
		let selectAllItem: MenuItem = .init(type: .select, selected: true)
		let deselectAllItem: MenuItem = .init(type: .delete, selected: true)
		let shareItem: MenuItem = .init(type: .share, selected: !self.contactGroupListDataSource.selectedSections.isEmpty)
		return [isSelectedAllItems ? deselectAllItem : selectAllItem, shareItem]
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
	
    private func didTapOpenBurgerMenu() {
	
		if #available(iOS 14.0, *) {} else {
			let menuItems = getDropDownItems()
			self.presentDropDonwMenu(with: menuItems, from: navigationBar.rightBarButtonItem)
		}
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
    
	func handleDropDownMenu(_ item: MenuItemType) {
		switch item {
			case .select, .deselect:
				self.didSelectDeselecAllItems()
			case .share:
				self.didTapSharePopUpMenuButton()
			default:
				return
		}
	}
}

//  MARK: - header delegate -
extension ContactsGroupViewController: SingleContactsGroupOperationsListener {
    
    /// `merge single section contacts`
    func didMergeContacts(in section: Int) {
		AlertManager.showAlert(for: .mergeContacts) {
            self.mergeContacts(in: section)
        }
    }
    
    /// `delete singe section contacts`
    func didDeleteFullContactsGroup(in section: Int) {
		AlertManager.showDeleteAlert(with: .userContacts, of: .many) {
			self.deleteContacts(in: section) { errorsCount in
				if errorsCount == 0 {
					AlertManager.showAlert(for: .deleteContactsCompleted) {}
					self.updateRemovedIndexes([section], errorsCount: 0)
					self.contactGroup.count == 0 ? self.closeController() : ()
				} else {
					self.progressAlert.showSimpleProgressAlerControllerBar(of: .updatingContacts, from: self, delegate: self)
					self.updateContactsGroups { contactsGroup in
						self.progressAlert.closeProgressAnimatedController()
						self.contactGroup = contactsGroup
						self.contactGroup.isEmpty ? self.closeController() : self.reloadDataSource()
					}
				}
			}
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
		
		isDeepCleaningSelectableFlow ? didTapCloseDeepCleanController() : closeController()
    }

    func didTapRightBarButton(_ sender: UIButton) {
        self.didTapOpenBurgerMenu()
    }
    
    func closeController() {
		self.navigationController?.popViewController(animated: true, completion: {
			self.updatableContactsAfterProcessing?(self.contactGroup, self.contentType, self.contactStoreDidChange)
		})
    }
	
	func didTapCloseDeepCleanController() {
		
		let indexesForMergedSet = contactGroupListDataSource.selectedSections
		let filteredContacts = indexesForMergedSet.map({contactGroup[$0]})
		let selectedGroupsIDs = filteredContacts.map({$0.groupIdentifier})
		self.selectedContactsDelegate?.didSelect(assetsListIds: selectedGroupsIDs, contentType: self.contentType, updatableGroup: [], updatableAssets: [], updatableContactsGroup: contactGroup)
		self.navigationController?.popViewController(animated: true)
	}
}

extension ContactsGroupViewController: BottomActionButtonDelegate {
    
    /// `merge contacts from bottom button`
    func didTapActionButton() {
		AlertManager.showAlert(for: .mergeContacts) {
			P.showIndicator()
			self.mergeSelectedItems()
		}
    }
}

extension ContactsGroupViewController: Themeble {
    
    func setupUI() {
        bottomButtonBarView.setImage(I.systemItems.defaultItems.merge)
    }
    
    func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        navigationBar.setupNavigation(title: navigationTitle, leftBarButtonImage: I.systemItems.navigationBarItems.back, rightBarButtonImage: I.systemItems.navigationBarItems.burgerDots, contentType: mediaType)
		if #available(iOS 14.0, *) {
			dropDownSetup()
		}
    }
    
    func setupViewModel(contacts: [ContactsGroup]) {
        self.contactGroupListViewModel = ContactGroupListViewModel(contactsGroup: contacts)
        self.contactGroupListDataSource = ContactsGroupDataSource(viewModel: self.contactGroupListViewModel)
        self.contactGroupListDataSource.contentType = self.contentType
    }
    
    private func setupTableView() {
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
