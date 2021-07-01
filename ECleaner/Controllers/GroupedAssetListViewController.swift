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
    private var bottomMenuHeight: CGFloat = 110
    
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: C.identifiers.views.groupHeaderView, for: indexPath) as? GroupedAssetsReusableHeaderView {
            
            sectionHeader.tag = indexPath.section
            
            sectionHeader.assetsSelectedCountTextLabel.text = "\(assetGroups[indexPath.section].assets.count) itmes"
            let isSelectSection = self.isSelectedSection(self.getIndexPathInSectionWithoutFirst(section: indexPath.section))
            
            sectionHeader.setSelectDeselectButton(!isSelectSection)
            
            sectionHeader.onSelectAll = {
                let indexPaths = self.getIndexPathInSectionWithoutFirst(section: indexPath.section)
                let sectionsCells = self.getSectionsCells(at: indexPaths)
    
                if !sectionsCells.isEmpty {
                    
                    /// check if section contains selected cells
                    
                    let selectedCell = sectionsCells.filter({ $0.isSelected })
                    if !selectedCell.isEmpty {
                        
                        let cells = sectionsCells.filter({ !$0.isSelected })
                        /// check if section contains selected and not selected cells
                        if !cells.isEmpty {
                            cells.forEach { cell in
                                if let cellIndexPath = self.collectionView.indexPath(for: cell), cellIndexPath != IndexPath(row: 0, section: indexPath.section) {
                                    if !self.selectedAssets.contains(self.assetGroups[cellIndexPath.section].assets[cellIndexPath.row]) {
                                        self.selectedAssets.append(self.assetGroups[cellIndexPath.section].assets[cellIndexPath.row])
                                        collectionView.selectItem(at: cellIndexPath, animated: true, scrollPosition: .centeredHorizontally)
                                    }
                                }
                            }
                            self.checkSelectedSection(indexPath)
                        } else {
                            /// select - deselect all section withoit first cell
                            /// section are full selected or deselected
                            self.didSelectAllAssets(at: indexPath, in: sectionHeader)
                        }
                    } else {
                        self.didSelectAllAssets(at: indexPath, in: sectionHeader)
                    }
                }
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
            self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
        }
        self.checkSelectedSection(indexPath)
        self.handleDeleteAssetsButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        if self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
            self.selectedAssets = self.selectedAssets.filter({ $0 != self.assetGroups[indexPath.section].assets[indexPath.row]})
        }
        self.checkSelectedSection(indexPath)
        self.handleDeleteAssetsButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.lazyHardcoreCheckForSelectedItemsAndAssets()
        self.checkSelectedIndexPath(self.getIndexPathInSectionWithoutFirst(section: indexPath.section))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        checkSelectedSection(indexPath)
        if let headerView = view as? GroupedAssetsReusableHeaderView {
            headerView.setSelectDeselectButton(!self.isSelectedSection(self.getIndexPathInSectionWithoutFirst(section: indexPath.section)))
        } else {
            debugPrint("header view cant find")
        }
    }
}

extension GroupedAssetListViewController: SNCollectionViewLayoutDelegate {
//    MARK: TODO: set if 3 asset
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if indexPath.row == 0 {
            return 2
        }
        return 1
    }
    
    func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return 44
    }
}

//      MARK: - check selected index path cell

extension GroupedAssetListViewController {
    
    /// `didSelectAllAssets` select deselect all assets in section
    /// `getIndexPathInSectionWithoutFirst` - get all index path in section without first index
    /// `checkSelectedIndexPath` vs `checkSelected` -> select and deselect automate cells index path and isSelected
    /// `isSelectedSection` check if contanse selected cell ind current section
    /// `getSectionsCells` get all cell ind current section
    
    private func didSelectAllAssets(at indexPath: IndexPath, in sectionHeader: GroupedAssetsReusableHeaderView) {
        
        for asset in self.assetGroups[indexPath.section].assets {
            if self.selectedAssets.contains(asset) {
                self.selectedAssets.removeAll(asset)
                sectionHeader.setSelectDeselectButton(true)
                self.collectionView.deselectAllItems(in: indexPath.section, first: 0, animated: true)
            } else if !self.selectedAssets.contains(asset) {
                let index = self.assetGroups[indexPath.section].assets.indexes(of: asset)
                if index != [0] {
                    sectionHeader.setSelectDeselectButton(false)
                    self.selectedAssets.append(asset)
                }
                self.collectionView.selectAllItems(in: indexPath.section, first: 1, animated: true)
            }
        }
        self.handleDeleteAssetsButton()
    }
    
    private func getIndexPathInSectionWithoutFirst(section: Int) -> [IndexPath] {
        let cellsCountInSection = self.collectionView.numberOfItems(inSection: section)
        return (1..<cellsCountInSection).map({IndexPath(item: $0, section: section)})
    }
    
    private func checkSelectedIndexPath(_ indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                self.checkSelected(cell, at: indexPath)
            }
        }
    }
    
    private func checkSelected(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
        
        if self.selectedAssets.contains(assetGroups[indexPath.section].assets[indexPath.row]) {
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        } else {
            self.collectionView.deselectItem(at: indexPath, animated: true)
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
    
    private func checkSelectedSection(_ indexPath: IndexPath) {
        debugPrint(indexPath.section)
        debugPrint("selected section")
        
        debugPrint(self.isSelectedSection(self.getIndexPathInSectionWithoutFirst(section: indexPath.section)))
        
        GroupedReusebleMediator.instance.updateSeleAllButtonState(index: indexPath.section,
                                                                  selectAllState: !self.isSelectedSection(self.getIndexPathInSectionWithoutFirst(section: indexPath.section)))
    }
    
    private func lazyHardcoreCheckForSelectedItemsAndAssets() {
        
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        
        if selectedItems.isEmpty, !self.selectedAssets.isEmpty {
            self.selectedAssets.removeAll()
        } else if !selectedItems.isEmpty, self.selectedAssets.isEmpty {
            selectedItems.forEach { indexPath in
                if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
                    self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
                }
            }
        } else if !selectedItems.isEmpty, !self.selectedAssets.isEmpty {
            self.selectedAssets.removeAll()
            
            selectedItems.forEach { indexPath in
                if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
                    self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
                }
            }
        }
    }
    
    private func getSectionsCells(at indexPaths: [IndexPath]) -> [PhotoCollectionViewCell] {
        var cells: [PhotoCollectionViewCell] = []
        
        indexPaths.forEach { indexPath in
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cells.append(cell)
            }
        }
        return cells
    }
}

extension GroupedAssetListViewController {
    
    private func handleDeleteAssetsButton() {
        
        bottomMenuHeightConstraint.constant = !selectedAssets.isEmpty ? bottomMenuHeight + U.bottomSafeAreaHeight : 0
        U.animate(0.5) {
            self.view.layoutIfNeeded()
        }
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

