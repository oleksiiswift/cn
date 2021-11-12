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
    @IBOutlet weak var mergeSelectedButton: UIButton!
    @IBOutlet weak var bottomMergeButtonContainerView: UIView!
    @IBOutlet weak var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    private var contactsManager = ContactsManager.shared
    
    public var contactGroup: [ContactsGroup] = []
    public var contactGroupListViewModel: ContactGroupListViewModel!
    public var contactGroupListDataSource: ContactsGroupDataSource!
    public var mediaType: MediaContentType = .none
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
    
    
    @IBAction func didTapMegreSelectedContactsActionButton(_ sender: Any) {
        
        
    }
}

extension ContactsGroupViewController: Themeble {
    
    func setupUI() {
        
        mergeSelectedButton.setCorner(14)
        mergeSelectedButton.addLeftImageWithFixLeft(spacing: 25, size: CGSize(width: 22, height: 30), image: I.personalElementsItems.mergeArrowTop!)
        mergeSelectedButton.titleLabel!.font = .systemFont(ofSize: 16.8, weight: .bold)
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
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        tableView.delegate = contactGroupListDataSource
        tableView.dataSource = contactGroupListDataSource
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset.top = 20
    }
    
    private func setupObserversAndDelegate() {
        
        navigationBar.delegate = self
    
        U.notificationCenter.addObserver(self, selector: #selector(mergeContactsDidChange(_:)), name: .mergeContactsSelectionDidChange, object: nil)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        mergeSelectedButton.backgroundColor = theme.contactsTintColor
        mergeSelectedButton.tintColor  = theme.activeTitleTextColor
        
    }
}

extension ContactsGroupViewController: NavigationBarDelegate {
    
    
    func didTapLeftBarButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_ sender: UIButton) {
        
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
        self.mergeSelectedButton.setTitleWithoutAnimation(title: buttonTitle)
        self.bottomMergeButtonContainerView.layoutIfNeeded()
        self.tableView.contentInset.bottom = !self.contactGroupListDataSource.selectedSections.isEmpty ? calculatedBottomButtonHeight :  34
    }
}


