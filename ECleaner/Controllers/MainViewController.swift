//
//  MainViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mediaCollectionViewContainer: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var deepCleaningButtonView: UIView!
    @IBOutlet weak var deepCleaningButtonTextLabel: UILabel!
    
    lazy var premiumButton = UIBarButtonItem(image: I.navigationItems.premium, style: .plain, target: self, action: #selector(premiumButtonPressed))
    lazy var settingsButton = UIBarButtonItem(image: I.navigationItems.settings, style: .plain, target: self, action: #selector(settingsButtonPressed))
    
    private var photoMenager = PhotoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupObserversAndDelegates()
        setupNavigation()
        setupUI()
        setupCollectionView()
        updateColors()
    }
}

extension MainViewController {
    
    private func getTotalDiskSpace() {
    }
    
    @objc func settingsButtonPressed() {}
    @objc func premiumButtonPressed() {}
}

//
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.mediaTypeCell, for: indexPath) as! MediaTypeCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
}

extension MainViewController {
    
    private func setupCollectionView() {
        
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.collectionViewLayout = BaseCarouselFlowLayout()
        mediaCollectionView.register(UINib(nibName: C.identifiers.xibs.mediaTypeCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.mediaTypeCell)
        mediaCollectionView.showsVerticalScrollIndicator = false
        mediaCollectionView.showsHorizontalScrollIndicator = false
    }

    private func configure(_ cell: MediaTypeCollectionViewCell, at indexPath: IndexPath) {
        
        switch indexPath.item {
            case 0:
                cell.mediaTypeCell = .userPhoto
                cell.configureCell(mediaType: .userPhoto)
            case 1:
                cell.mediaTypeCell = .userVideo
                cell.configureCell(mediaType: .userVideo)
            case 2:
                cell.mediaTypeCell = .userContacts
                cell.configureCell(mediaType: .userContacts)
            default:
                debugPrint("")
        }
    }
}

extension MainViewController: UpdateColorsDelegate {
    
    private func setupObserversAndDelegates() {
        
        
    }
    
    private func setupNavigation() {
            
        self.navigationController?.updateNavigationColors()
        self.navigationItem.leftBarButtonItem = premiumButton
        self.navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func setupUI() {
        
        deepCleaningButtonView.setCorner(12)
        #warning("LOCO add loco")
        deepCleaningButtonTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
        deepCleaningButtonTextLabel.text = "Deep Cleaning"
    }
    
    func updateColors() {
        self.view.backgroundColor = currentTheme.backgroundColor
        deepCleaningButtonView.backgroundColor = currentTheme.accentBackgroundColor
        deepCleaningButtonTextLabel.textColor = currentTheme.activeTitleTextColor
        
    }
}

