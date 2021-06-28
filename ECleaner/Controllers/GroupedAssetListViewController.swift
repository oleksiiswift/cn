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
    
    let columnLayout = SimpleColumnFlowLayout(
        cellsPerRow: 4,
        minimumInterSpacing: 1,
        minimumLineSpacing: 1,
        inset: UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    )
    
    let circularLayoutObject = CustomCircularCollectionViewLayout()
    
    
    let compositionalLayout: UICollectionViewCompositionalLayout = {
        let inset: CGFloat = 2.5
        
        // Items
        let largeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
        largeItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let smallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
        smallItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // Nested Group
        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
        let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: nestedGroupSize, subitems: [smallItem])
        
        // Outer Group
        let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let outerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: outerGroupSize, subitems: [largeItem, nestedGroup, nestedGroup])
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // Supplementary Item
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: "header", alignment: .top)
        section.boundarySupplementaryItems = [headerItem]
         
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateColors()
        setupCollectionView()
        setupNavigation()
    }
    
    @IBAction func didTapDeleteAssetsActionButton(_ sender: Any) {
        
    }


}

extension GroupedAssetListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
  
    private func setupCollectionView() {
        
//        flowLayout.itemHieght = ((U.screenWidth - 26) / 3) / U.ratio
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        
//        columnLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 40.0)
        
//        self.collectionView.collectionViewLayout = columnLayout
//        self.collectionView.collectionViewLayout = circularLayoutObject
        self.collectionView.collectionViewLayout = compositionalLayout
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

    private func setupNavigation() {


    }
}

//
//}
//
//extension SimpleAssetsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//
//
//    private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
//
//        switch photoMediaType {
//            case .screenshots:
//                cell.loadCellThumbnail(assetCollection[indexPath.row], size: CGSize(width: ((U.screenWidth - 26) / 2), height: ((U.screenHeight - 26) / 2) / U.ratio ))
//            case .selfies:
//                cell.loadCellThumbnail(assetCollection[indexPath.row], size: CGSize(width: U.screenWidth, height: U.screenHeight))
//            default:
//                return
//        }
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return assetCollection.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
//        configure(cell, at: indexPath)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
//        if let cell = collectionView.cellForItem(at: indexPath) {
//            cell.isSelected = true
//        }
//        handleSelectAllButtonState()
//        handleBottomButtonMenu()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        if let cell = collectionView.cellForItem(at: indexPath) {
//            cell.isSelected = false
//        }
//        handleSelectAllButtonState()
//        handleBottomButtonMenu()
//    }
//}
//
//extension SimpleAssetsListViewController {
//
//    @objc func handleSelectAllButtonTapped() {
//
//        let selected = collectionView.indexPathsForSelectedItems?.count == assetCollection.count
//        selectAllButton.title = selected ? "select all" : "deselect"
//        setCollection(selected: selected)
//        handleBottomButtonMenu()
//    }
//
//    private func setCollection(selected: Bool) {
//
//        let numbersOfItemsInSection = collectionView.numberOfItems(inSection: 0)
//
//        for indexPath in (0..<numbersOfItemsInSection).map({IndexPath(item: $0, section: 0)}) {
//            if selected {
//                collectionView.deselectItem(at: indexPath, animated: true)
//            } else {
//                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
//            }
//
//            if let cell = collectionView.cellForItem(at: indexPath) {
//                cell.isSelected = !selected
//            }
//        }
//    }
//
//    private func handleSelectAllButtonState() {
//
//        selectAllButton.title = collectionView.indexPathsForSelectedItems?.count != assetCollection.count ? "select all" : "deselect"
//    }
//
//    private func handleBottomButtonMenu() {
//        if let selectedItems = collectionView.indexPathsForSelectedItems {
//                bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? bottomMenuHeight + U.bottomSafeAreaHeight : 0
//            U.animate(0.5) {
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
//}
//
//extension SimpleAssetsListViewController: Themeble {
//
//
//}
