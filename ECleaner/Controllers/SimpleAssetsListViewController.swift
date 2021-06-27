//
//  SimpleAssetsListViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit
import Photos

class SimpleAssetsListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    
    public var assetCollection: [PHAsset] = []
    
    private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3, minimumInterSpacing: 3, minimumLineSpacing: 3, inset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
    private var bottomMenuHeight: CGFloat = 110
    private lazy var selectAllButton = UIBarButtonItem(title: "select all", style: .plain, target: self, action: #selector(handleSelectAllButtonTapped))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateColors()
        setupCollectionView()
        setupNavigation()
    }
}

extension SimpleAssetsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
    
        flowLayout.itemHieght = ((U.screenWidth - 26) / 3) / U.ratio
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.reloadData()
    }
    
    private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
        
        cell.loadCellThumbnail(assetCollection[indexPath.row], size: CGSize(width: ((U.screenWidth - 26) / 3), height: ((U.screenHeight - 26) / 3) / U.ratio ))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.isSelected = true
        }
        handleSelectAllButtonState()
        handleBottomButtonMenu()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.isSelected = false
        }
        handleSelectAllButtonState()
        handleBottomButtonMenu()
    }
}

extension SimpleAssetsListViewController {
    
    @objc func handleSelectAllButtonTapped() {
    
        let selected = collectionView.indexPathsForSelectedItems?.count == assetCollection.count
        selectAllButton.title = selected ? "select all" : "deselect"
        setCollection(selected: selected)
        handleBottomButtonMenu()
    }
    
    private func setCollection(selected: Bool) {
        
        let numbersOfItemsInSection = collectionView.numberOfItems(inSection: 0)
        
        for indexPath in (0..<numbersOfItemsInSection).map({IndexPath(item: $0, section: 0)}) {
            if selected {
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.isSelected = !selected
            }
        }
    }
    
    private func handleSelectAllButtonState() {
        
        selectAllButton.title = collectionView.indexPathsForSelectedItems?.count != assetCollection.count ? "select all" : "deselect"
    }
    
    private func handleBottomButtonMenu() {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
                bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? bottomMenuHeight + U.bottomSafeAreaHeight : 0
            U.animate(0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
extension SimpleAssetsListViewController: Themeble {
    
    func setupUI() {
        
        bottomMenuHeightConstraint.constant = 0
    }
    
    func updateColors() {
        bottomMenuView.backgroundColor = currentTheme.sectionBackgroundColor
    }
    
    private func setupNavigation() {
        
        self.navigationItem.rightBarButtonItem = selectAllButton
        
    }
}
