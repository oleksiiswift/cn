//
//  DeepCleaningViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.07.2021.
//

import UIKit

class DeepCleaningViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    /// properties
    private var bottomMenuHeight: CGFloat = 80
    
//    TODO: list of selected Assets or list of selected ids'
    public var cleaningAssetsList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        checkStartCleaningButtonState(false)
    }
}

extension DeepCleaningViewController {
    
    private func checkStartCleaningButtonState(_ animate: Bool) {
        
        bottomContainerHeightConstraint.constant = cleaningAssetsList.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
        self.tableView.contentInset.bottom = cleaningAssetsList.count > 0 ? 10 : 5
        
        if animate {
            U.animate(0.5) {
                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension DeepCleaningViewController: UITableViewDelegate, UITableViewDataSource {

    private func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
        tableView.register(UINib(nibName: C.identifiers.xibs.cleanInfoCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.cleanInfoCell)
        tableView.separatorStyle = .none
    }

    private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
        
        cell.setupCellSelected(at: indexPath, isSelected: false)
        
        switch indexPath.section {
            case 1:
                cell.cellConfig(contentType: MediaContentType.userPhoto, indexPath: indexPath, phasetCount: 0)
            case 2:
                cell.cellConfig(contentType: MediaContentType.userVideo, indexPath: indexPath, phasetCount: 0)
            default:
                cell.cellConfig(contentType: MediaContentType.userContacts, indexPath: indexPath, phasetCount: 0)
        }
    }
    
    private func configureInfoCell(_ cell: DeepCleanInfoTableViewCell, at indexPath: IndexPath) {
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                return MediaContentType.userPhoto.numberOfRows
            case 2:
                return MediaContentType.userVideo.numberOfRows
            default:
                return MediaContentType.userContacts.numberOfRows
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.cleanInfoCell, for: indexPath) as! DeepCleanInfoTableViewCell
                configureInfoCell(cell, at: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
                configure(cell, at: indexPath)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 150 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 30))
        let sectionTitleTextLabel = UILabel()
        
        view.addSubview(sectionTitleTextLabel)
        sectionTitleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        sectionTitleTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        sectionTitleTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sectionTitleTextLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sectionTitleTextLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
        switch section {
            case 0:
                view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: 0)
            case 1:
                sectionTitleTextLabel.text = "photo"
            case 2:
                sectionTitleTextLabel.text = "video"
            default:
                sectionTitleTextLabel.text = "contacts"
        }
        return view
    }
}

extension DeepCleaningViewController {
    
    private func setupUI() {
        
    }
}

extension DeepCleaningViewController: Themeble {
    
    func updateColors() {
        
    }
}
