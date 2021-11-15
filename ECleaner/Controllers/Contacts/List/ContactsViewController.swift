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
    @IBOutlet weak var tableView: UITableView!
    
    public var contactListViewModel: ContactListViewModel!
    public var contactListDataSource: ContactListDataSource!
    
    public var contacts: [CNContact] = []
    public var contentType: PhotoMediaType = .none
    public var mediaType: MediaContentType = .none
    
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
//        customNavBar.setUpNavigation(title: mediaType.navigationTitle, leftImage: I.navigationItems.back, rightImage: nil)
        
    }
    
    private func setupUI() {}
    
    private func setupViewModel(contacts: [CNContact]) {
        self.contactListViewModel = ContactListViewModel(contacts: contacts)
        self.contactListDataSource = ContactListDataSource(contactListViewModel: self.contactListViewModel, contentType: self.contentType)
    }
    
    func updateColors() {
        self.view.backgroundColor = theme.backgroundColor
    }
    
    
    private func setupTableView() {
        
        tableView.register(UINib(nibName: C.identifiers.xibs.contactCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contactCell)
        tableView.delegate = contactListDataSource
        tableView.dataSource = contactListDataSource
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = UIColor().colorFromHexString("30C08F")
        tableView.backgroundColor = theme.backgroundColor
    }
    
    private func setupObserversAndDelegate() {
        
        navigationBar.delegate = self
    }
}

extension ContactsViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_ sender: UIButton) {}
}
