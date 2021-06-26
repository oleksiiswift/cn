//
//  MediaContentViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos
import SwiftMessages

class MediaContentViewController: UIViewController {

    @IBOutlet weak var startingDateTitileTextLabel: UILabel!
    @IBOutlet weak var endingDateTitleTextLabel: UILabel!
    @IBOutlet weak var startingDateTextLabel: UILabel!
    @IBOutlet weak var endingDateTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startingDateButtonView: UIView!
    @IBOutlet weak var endingDateButtonView: UIView!
    
    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startingDateStackView: UIStackView!
    @IBOutlet weak var endingDateStackView: UIStackView!
    
    public var contentType: MediaContentType = .none
    
    public var allScreenShots: [PHAsset] = []
    public var allSelfies: [PHAsset] = []
    public var allLiveFotos: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateColors()
        setupNavigation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.backButtonTitle = ""
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case C.identifiers.segue.showDatePicker:
                self.setupShowDatePickerSelectorController(segue: segue)
            default:
                break
        }
    }

    @IBAction func didTapSelectStartDateActionButton(_ sender: Any) {
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
    
    @IBAction func didTapSelectEndDateActionButton(_ sender: Any) {
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
}

extension MediaContentViewController: UITableViewDelegate, UITableViewDataSource {

    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
        
        var assetContentCount: Int = 0
    
        switch self.contentType {
            case .userPhoto:
                switch indexPath.row {
                    case 2:
                        assetContentCount = self.allScreenShots.count
                    case 3:
                        assetContentCount = self.allSelfies.count
                    case 5:
                        assetContentCount = self.allLiveFotos.count
                    default:
                        debugPrint("")
                }
            case .userVideo:
                debugPrint("")
            case .userContacts:
                debugPrint("")
            default:
                return
        }
        
        cell.cellConfig(contentType: contentType, indexPath: indexPath, phasetCount: assetContentCount)
        
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return contentType.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentType.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
}

extension MediaContentViewController: Themeble {
    
    private func setupUI() {
        
        switch contentType {
            case .userPhoto:
                title = "title photo"
            case .userVideo:
                title = "title video"
            case .userContacts:
                title = "title contact"
                dateSelectContainerHeigntConstraint.constant = 0
                dateSelectContainerView.isHidden = true
            case .none:
                debugPrint("")
        }
        
        startingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        startingDateStackView.isLayoutMarginsRelativeArrangement = true
        endingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        endingDateStackView.isLayoutMarginsRelativeArrangement = true
    
        startingDateButtonView.setCorner(12)
        endingDateButtonView.setCorner(12)
        
        startingDateTitileTextLabel.text = "from"
        endingDateTitleTextLabel.text = "to"
        
        startingDateTextLabel.text = "date from"
        endingDateTextLabel.text = "date to"
        
        
        startingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        startingDateTitileTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private func setupNavigation() {
        self.navigationController?.updateNavigationColors()
        self.navigationItem.backButtonTitle = ""
    }
    
    func updateColors() {
        dateSelectContainerView.addBottomBorder(with: currentTheme.contentBackgroundColor, andWidth: 1)
        startingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        endingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        
        startingDateTitileTextLabel.textColor = currentTheme.titleTextColor
        endingDateTextLabel.textColor = currentTheme.titleTextColor
        
        startingDateTitileTextLabel.textColor = currentTheme.subTitleTextColor
        endingDateTitleTextLabel.textColor = currentTheme.subTitleTextColor
    }
    
    private func setupShowDatePickerSelectorController(segue: UIStoryboardSegue) {
        
        if let segue = segue as? SwiftMessagesSegue {
            segue.configure(layout: .bottomMessage)
            segue.dimMode = .gray(interactive: false)
            segue.interactiveHide = false
            segue.messageView.configureNoDropShadow()
            segue.messageView.backgroundHeight = Device.isSafeAreaiPhone ? 458 : 438
            
            if let dateSelectorController = segue.destination as? DateSelectorViewController {
                
            }
        }
    }
}
