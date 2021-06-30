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
    
    private var selectedAssets: [PHAsset] = []
    
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
        
        /// `delegates` subscribe
        
        collectionViewFlowLayout.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        /// `register xib`
        
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
                                           bundle: nil),
                                     forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.groupHeader,
                                           bundle: nil),
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: C.identifiers.views.groupHeaderView)
                
        /// collection view `setup`
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
        self.checkSelected(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: C.identifiers.views.groupHeaderView, for: indexPath) as? GroupedAssetsReusableHeaderView {
            
            sectionHeader.assetsSelectedCountTextLabel.text = "\(assetGroups[indexPath.section].assets.count) itmes"
            let isSelectSection = self.isSelectedSection(self.getIndexPathInSectionWithoutFirst(section: indexPath.section))
            sectionHeader.setSelectDeselectButton(!isSelectSection)
            
            
            sectionHeader.onSelectAll = {
                for asset in self.assetGroups[indexPath.section].assets {
                    
                    if self.selectedAssets.contains(asset) {
                        self.selectedAssets.removeAll(asset)
                        sectionHeader.setSelectDeselectButton(true)
                    } else if !self.selectedAssets.contains(asset) {
                        let index = self.assetGroups[indexPath.section].assets.indexes(of: asset)
                        if index != [0] {
                            sectionHeader.setSelectDeselectButton(false)
                            self.selectedAssets.append(asset)
                        }
                    }
                }
                self.checkSelected(self.getIndexPathInSectionWithoutFirst(section: indexPath.section))
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
            self.selectedAssets = self.selectedAssets.filter({ $0 != self.assetGroups[indexPath.section].assets[indexPath.row]})
        } else {
            self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
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
    
    func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return 44
    }
}

extension GroupedAssetListViewController {
    
    private func checkSelected(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
        cell.isSelected = self.selectedAssets.contains(assetGroups[indexPath.section].assets[indexPath.row])
    }
    
    private func getIndexPathInSectionWithoutFirst(section: Int) -> [IndexPath] {
        let cellsCountInSection = self.collectionView.numberOfItems(inSection: section)
        return (1..<cellsCountInSection).map({IndexPath(item: $0, section: section)})
    }
    
    private func checkSelected(_ indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                self.checkSelected(cell, at: indexPath)
            }
        }
    }
    
    private func isSelectedSection(_ indexPaths: [IndexPath]) -> Bool {
        var isCellsSelectedCount: Int = 0
        indexPaths.forEach { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                if cell.isSelected {
                    isCellsSelectedCount += 1
                }
            }
        }
        return indexPaths.count == isCellsSelectedCount
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


