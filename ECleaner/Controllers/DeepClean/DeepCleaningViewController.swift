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
        checkStartCleaningButtonState()
    }
}

extension DeepCleaningViewController {
    
    private func checkStartCleaningButtonState() {
        
        bottomContainerHeightConstraint.constant = cleaningAssetsList.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
        self.tableView.contentInset.bottom = cleaningAssetsList.count > 0 ? 10 : 5
        
        U.animate(0.5) {
            self.tableView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
}

extension DeepCleaningViewController: UITableViewDelegate, UITableViewDataSource {

    private func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
    }

    private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
        
        switch indexPath.section {
            case 1:
                cell.cellConfig(contentType: MediaContentType.userPhoto, indexPath: indexPath, phasetCount: 0)
            case 2:
                cell.cellConfig(contentType: MediaContentType.userVideo, indexPath: indexPath, phasetCount: 0)
            case 3:
                cell.cellConfig(contentType: MediaContentType.userContacts, indexPath: indexPath, phasetCount: 0)
            default:
//                TODO: set zero info cell
                cell.cellConfig(contentType: MediaContentType.userContacts, indexPath: indexPath, phasetCount: 0)
        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return MediaContentType.userPhoto.numberOfRows
            case 1:
                return MediaContentType.userVideo.numberOfRows
            case 2:
                return MediaContentType.userContacts.numberOfRows
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
        configure(cell, at: indexPath)
        return cell
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
