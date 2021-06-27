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
    private var bottomMenuHeight: CGFloat = 110
    
    private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3, minimumInterSpacing: 3, minimumLineSpacing: 3, inset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateColors()
        setupCollectionView()
    }
}

extension SimpleAssetsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    
    
    private func setupCollectionView() {
    
        flowLayout.itemHieght = ((U.screenWidth - 26) / 3) / U.ratio
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        self.collectionView.collectionViewLayout = flowLayout
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
}

extension SimpleAssetsListViewController: Themeble {
    
    func setupUI() {
        
        bottomMenuHeightConstraint.constant = 0

        //        bottomMenuHeightConstraint.constant = bottomMenuHeight + U.bottomSafeAreaHeight
        
    }
    
    func updateColors() {
        
        bottomMenuView.backgroundColor = currentTheme.sectionBackgroundColor
    }
}
