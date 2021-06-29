//
//  GroupedAssetListViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit
import Photos

enum GropedAsset {
    case similarPhotos
    case similarLivePhotos
    case similarVideo
}

class GroupedAssetListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var deleteAssetsButtonView: UIView!
    @IBOutlet weak var deleteAssetsTexetLabel: UILabel!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    
    public var grouped: GropedAsset?
    public var assetGroups: [PhassetGroup] = []
    
    let collectionViewFlowLayout = SNCollectionViewLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateColors()
        setupCollectionView()
        setupNavigation()
    }
    
    @IBAction func didTapDeleteAssetsActionButton(_ sender: Any) {}
}

//      MARK: - setup collection view with flow layout -

extension GroupedAssetListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        
        /// delegates
        collectionViewFlowLayout.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        
        /// collection view setup
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionViewFlowLayout.fixedDivisionCount = 4
        collectionViewFlowLayout.itemSpacing = 5
        
        self.collectionView.collectionViewLayout = collectionViewFlowLayout
        self.collectionView.allowsMultipleSelection = true
        
        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return assetGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetGroups[section].assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
        cell.loadCellThumbnail(assetGroups[indexPath.section].assets[indexPath.row], size: CGSize(width: 300, height: 300))
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == assetGroups.count - 1 {
            return CGSize(width: self.view.frame.width, height: 100)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}

extension GroupedAssetListViewController: SNCollectionViewLayoutDelegate {
//    MARK: TODO: set if 3 asset 
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if indexPath.row == 0 { //|| indexPath.row == 3 || indexPath.row == 10 || indexPath.row == 70 {
            return 2
        }
        return 1
    }
}
    
//      MARK: - setup UI -

extension GroupedAssetListViewController: Themeble {

    func setupUI() {
        deleteAssetsButtonView.setCorner(12)
        bottomMenuHeightConstraint.constant = 0
        deleteAssetsTexetLabel.font = .systemFont(ofSize: 17, weight: .bold)
        deleteAssetsTexetLabel.text = "delete photos"
    }

    func updateColors() {
        bottomMenuView.backgroundColor = currentTheme.sectionBackgroundColor
        deleteAssetsButtonView.backgroundColor = currentTheme.accentBackgroundColor
        deleteAssetsTexetLabel.textColor = currentTheme.activeTitleTextColor
    }

    private func setupNavigation() {}
}

