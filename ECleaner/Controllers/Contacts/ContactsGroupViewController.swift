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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel(contacts: self.contactGroup)
        setupNavigation()
        setupTableView()
        setupObserversAndDelegate()
        self.tableView.reloadData()
    }
      
}

extension ContactsGroupViewController {
    
    
    func setupUI() {
        
    }
    
    func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        customNavBar.setUpNavigation(title: contentType.navTitle, leftImage: I.navigationItems.back, rightImage: nil)
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
    
}

extension ContactsGroupViewController: CustomNavigationBarDelegate {


    func didTapLeftBarButton(_sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_sender: UIButton) {}
    
}


