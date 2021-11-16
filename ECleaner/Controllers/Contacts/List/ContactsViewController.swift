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
    
    @IBOutlet weak var tableView: UITableView!
    
//    private var searchBar = UISearchBar()
//    private var scrollView = UIScrollView()
    
    public var contactListViewModel: ContactListViewModel!
    public var contactListDataSource: ContactListDataSource!
    
    public var contacts: [CNContact] = []
    public var contentType: PhotoMediaType = .none
    public var mediaType: MediaContentType = .none
    
    public var isEdinng: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViewModel(contacts: self.contacts)
        setupUI()
        setupObserversAndDelegate()
        setupTableView()
//        setupSearchBar()
        updateColors()
    }
}

extension ContactsViewController: Themeble {
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        navigationBar.setIsDropShadow = false
        navigationBar.setupNavigation(title: mediaType.navigationTitle, leftBarButtonImage: I.navigationItems.back, rightBarButtonImage: I.navigationItems.burgerDots, mediaType: .userContacts, leftButtonTitle: nil, rightButtonTitle: nil)
    }
    
    private func setupUI() {
        
    }
    
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
        tableView.allowsSelection = false
        /// add extra top inset 
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 40)))
        view.backgroundColor = .clear
        tableView.tableHeaderView = view
        
//        let searchBar = UISearchBar()
//        searchBar.showsCancelButton = true
//        searchBar.searchBarStyle = UISearchBar.Style.default
//        searchBar.placeholder = " Search Here....."
//        searchBar.sizeToFit()
//        searchBar.backgroundColor = .clear
//        tableView.tableHeaderView = searchBar
    }
    
//    private func setupSearchBar() {
//
//        searchBar.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: 80)
//        searchBar.searchBarStyle = .default
//
//        searchBar.placeholder = " search here .... "
//        searchBar.sizeToFit()
//
//        tableView.tableHeaderView = searchBar
//    }
    
    private func isSelected(enabled: Bool) {
        
        tableView.allowsSelection = enabled
        tableView.allowsMultipleSelection = enabled
    }
    
    private func setupObserversAndDelegate() {
        
        navigationBar.delegate = self
        searchBarView.searchBar.delegate = self
        
        U.notificationCenter.addObserver(self, selector: #selector(showNavigationBarShadow(_:)), name: .searchBarDidChangeAppearance, object: nil)
    }
}

extension ContactsViewController {
    
    @objc func showNavigationBarShadow(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let minimumSearchBarHeighValue: CGFloat = 40
        let maximumSearchBarHeightValue: CGFloat = 80
        let defaultSearchBarHeightValue: CGFloat = 60
        
        if let offset = userInfo[C.key.notificationDictionary.scrollDidChangeValue] as? CGFloat {
            
            
//            containerViewHeight.constant = scrollView.contentInset.top
//                    let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
//                    containerView.clipsToBounds = offsetY <= 0
//                    imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
//                    imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
//
//            if offset > 0 || offset < maximumSearchBarHeightValue {
//            searchBarHeightConstraint.constant = defaultSearchBarHeightValue + offset
//                searchBarView.layoutIfNeeded()
//            }
        }
        
        
//        if let showShadow = userInfo[C.key.notificationDictionary.scrollDidChangeBool] as? Bool {
//            debugPrint("need sho shadow: \(showShadow)")
//            navigationBar.setDropShadow(visible: showShadow)
//        }
    }
    
    
}

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.searchBarView.setShowCancelButton(true, animated: true)
        navigationBarHeightConstraint.constant = 0
        U.animate(1) {
            self.navigationBar.containerView.alpha = 0
            self.navigationBar.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
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
    

}

extension ContactsViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_ sender: UIButton) {
        
        self.isEdinng = !isEdinng
        self.isSelected(enabled: self.isEdinng)
    }
}
