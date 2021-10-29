//
//  ContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var customNavBar: CustomNavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var contactListViewModel: ContactListViewModel!
    public var contactListDataSource: ContactListDataSource!
    
    public var contacts: [CNContact] = []
    public var contentType: MediaContentType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViewModel(contacts: self.contacts)
        setupUI()
        setupObserversAndDelegate()
        setupTableView()
        updateColors()
    }
}


extension ContactsViewController: Themeble {
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        customNavBar.setUpNavigation(title: contentType.navTitle, leftImage: I.navigationItems.back, rightImage: nil)
    }
    
    private func setupUI() {
        
    }
    
    private func setupViewModel(contacts: [CNContact]) {
        self.contactListViewModel = ContactListViewModel(contacts: contacts)
        self.contactListDataSource = ContactListDataSource(contactListViewModel: self.contactListViewModel)
    }
    
    func updateColors() {
        self.view.backgroundColor = theme.backgroundColor
    }
    
    
    private func setupTableView() {
        
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        tableView.delegate = contactListDataSource
        tableView.dataSource = contactListDataSource
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = theme.backgroundColor
    }
    
    private func setupObserversAndDelegate() {
        
        customNavBar.delegate = self
    }
}

extension ContactsViewController: CustomNavigationBarDelegate {
    
    
    func didTapLeftBarButton(_sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_sender: UIButton) {}
    
    
}
