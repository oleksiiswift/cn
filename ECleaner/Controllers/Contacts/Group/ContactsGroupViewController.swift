//
//  ContactsGroupViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit
import Contacts

class ContactsGroupViewController: UIViewController {
    
    @IBOutlet weak var customNavBar: CustomNavigationBar!
    @IBOutlet weak var tableView: UITableView!

    public var contactGroup: [ContactsGroup] = []
    public var contactGroupListViewModel: ContactGroupListViewModel!
    public var contactGroupListDataSource: ContactsGroupDataSource!
    
    public var contentType: MediaContentType = .none
    
    private var contactsManager = ContactsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel(contacts: self.contactGroup)
        setupNavigation()
        setupTableView()
        setupObserversAndDelegate()
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
    
    func setupUI() {}
    
    func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        customNavBar.setUpNavigation(title: contentType.navTitle, leftImage: I.navigationItems.back, rightImage: I.navigationItems.back)
    }
    
    func setupViewModel(contacts: [ContactsGroup]) {
        
        self.contactGroupListViewModel = ContactGroupListViewModel(contactsGroup: contacts)
        self.contactGroupListDataSource = ContactsGroupDataSource(viewModel: self.contactGroupListViewModel)
    }
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        tableView.delegate = contactGroupListDataSource
        tableView.dataSource = contactGroupListDataSource
        tableView.separatorStyle = .none
        tableView.backgroundColor = theme.backgroundColor
    }
    
    private func setupObserversAndDelegate() {
        
        customNavBar.delegate = self
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
        self.customNavBar.backgroundColor = theme.backgroundColor
    }
}

extension ContactsGroupViewController: CustomNavigationBarDelegate {


    func didTapLeftBarButton(_sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_sender: UIButton) {
        
        contactGroup.forEach { group in
            self.contactsManager.smartMergeContacts(in: group) { deletingContacts in
                self.contactsManager.deleteContacts(deletingContacts)
            }
        }
    }
}


