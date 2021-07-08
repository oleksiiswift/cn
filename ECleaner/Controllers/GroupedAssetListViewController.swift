//
//  GroupedAssetListViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit
import Photos

enum GropedAsset {
    case duplicatePhotos
    case similarPhotos
    case similarLivePhotos
    case duplicatedVideo
    case similarVideo
}

class GroupedAssetListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var deleteAssetsButtonView: UIView!
    @IBOutlet weak var deleteAssetsTexetLabel: UILabel!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    
    lazy var burgerOptionSettingButton = UIBarButtonItem(image: I.navigationItems.elipseBurger, style: .plain, target: self, action: #selector(openOptionsBurgerMenu))
    
    private let sliderMenuOptionItem = DropDownOptionsMenuItem(titleMenu: "slider", itemThumbnail: I.systemElementsItems.sliderView, isSelected: false, menuItem: .changeLayout)
    private let tileMenuOptionItem = DropDownOptionsMenuItem(titleMenu: "tile", itemThumbnail: I.systemElementsItems.tileView, isSelected: false, menuItem: .changeLayout)
    private let selectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "select all", itemThumbnail: I.systemElementsItems.circleBox!, isSelected: false, menuItem: .unselectAll)
    private let deselectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "deselect all", itemThumbnail: I.systemElementsItems.circleCheckBox!, isSelected: false, menuItem: .unselectAll)
    
    public var grouped: GropedAsset?
    public var assetGroups: [PhassetGroup] = []
    
    private var selectedAssets: [PHAsset] = []
    private var selectedSection: Set<Int> = []
    
    let collectionViewFlowLayout = SNCollectionViewLayout()
    
    private var isSliderFlowLayout: Bool = false
    private var isSelectAllAssetsMode: Bool = false

    private var bottomMenuHeight: CGFloat = 80
    private var photoManager = PhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateColors()
        setupCollectionView()
        setupNavigation()
        setupListenersAndObservers()
    }
    
    @IBAction func didTapDeleteAssetsActionButton(_ sender: Any) {
        showDeleteConfirmAlert()
    }
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
        
        switch kind {
            
            case UICollectionView.elementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: C.identifiers.views.groupHeaderView, for: indexPath)
            
                guard let sectionHeader = headerView as? GroupedAssetsReusableHeaderView else { return headerView }
                
                sectionHeader.assetsSelectedCountTextLabel.text = "\(assetGroups[indexPath.section].assets.count) itmes"
                
                checkSelectedHeaderView(for: indexPath, headerView: sectionHeader)
                
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
                                
                                if !self.selectedSection.contains(indexPath.section) {
                                    self.selectedSection.insert(indexPath.section)
                                }
                            
                                sectionHeader.setSelectDeselectButton(true)
                            
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
                
            default:
                assert(false, "Invalid element type")
//            debugPrint("invalid")
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
            self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
        }
        self.handleSelectAllButtonSection(indexPath)
        self.handleDeleteAssetsButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        if self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
            self.selectedAssets = self.selectedAssets.filter({ $0 != self.assetGroups[indexPath.section].assets[indexPath.row]})
        }
        self.handleSelectAllButtonSection(indexPath)
        self.handleDeleteAssetsButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        self.lazyHardcoreCheckForSelectedItemsAndAssets()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    
        guard let headerview = view as? GroupedAssetsReusableHeaderView else { return }
        
        checkSelectedHeaderView(for: indexPath, headerView: headerview)
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
    /// `checkSelectedHeaderView` - check header for selected items when load and reuse
    /// `isSelectedSection` check if contains selected cell and current section
    /// `getSectionsCells` get all cell and current section
    /// `lazyHardcoreCheckForSelectedItemsAndAssets` hardcore check for lost index pathes and elements of array if they lost
    
    private func didSelectAllAssets(at indexPath: IndexPath, in sectionHeader: GroupedAssetsReusableHeaderView) {
        
        var addingSection: Bool = false
        
        if selectedSection.contains(indexPath.section) {
            for asset in self.assetGroups[indexPath.section].assets {
                self.selectedAssets.removeAll(asset)
            }
        } else {
            for asset in self.assetGroups[indexPath.section].assets {
                let index = self.assetGroups[indexPath.section].assets.indexes(of: asset)
                if index != [0] {
                    self.selectedAssets.append(asset)
                    addingSection = true
                }
            }
        }
        
        if addingSection {
            selectedSection.insert(indexPath.section)
            self.collectionView.selectAllItems(in: indexPath.section, first: 1, animated: true)
            sectionHeader.setSelectDeselectButton(true)
        } else {
            selectedSection.remove(indexPath.section)
            self.collectionView.deselectAllItems(in: indexPath.section, first: 0, animated: true)
            sectionHeader.setSelectDeselectButton(false)
        }
    
        self.handleDeleteAssetsButton()
    }
    
    private func getIndexPathInSectionWithoutFirst(section: Int) -> [IndexPath] {
        let cellsCountInSection = self.collectionView.numberOfItems(inSection: section)
        return (1..<cellsCountInSection).map({IndexPath(item: $0, section: section)})
    }
    
    private func checkSelectedHeaderView(for indexPath: IndexPath, headerView: GroupedAssetsReusableHeaderView) {
        
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
            if !selectedIndexPaths.isEmpty {
                let sectionSelectedPathFiltered = selectedIndexPaths.filter({ $0.section == indexPath.section})
                if sectionSelectedPathFiltered.contains(where: {$0.section == indexPath.section}) {
                    
                    if self.collectionView.numberOfItems(inSection: indexPath.section) - 1 == sectionSelectedPathFiltered.count {
                        headerView.setSelectDeselectButton(true)
                    } else {
                        headerView.setSelectDeselectButton(false)
                    }
                } else {
                    headerView.setSelectDeselectButton(false)
                }
            } else {
                headerView.setSelectDeselectButton(false)
            }
        } else {
            headerView.setSelectDeselectButton(false)
        }
        collectionViewFlowLayout.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
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
    
    private func handleSelectAllButtonSection(_ indexPath: IndexPath) {
        
        if let view = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                            at: IndexPath(row: 0, section: indexPath.section)) {
            
            guard let headerView = view as? GroupedAssetsReusableHeaderView else { return }
            
            if let selectedIndexPath = self.collectionView.indexPathsForSelectedItems {
                let sectionFilters = selectedIndexPath.filter({ $0.section == indexPath.section})
                if sectionFilters.contains(where: {$0.section == indexPath .section}) {
                    let numbersOfItems = self.collectionView.numberOfItems(inSection: indexPath.section)
                    if numbersOfItems - 1 == sectionFilters.count || numbersOfItems == sectionFilters.count{
                        if !selectedSection.contains(indexPath.section) {
                            selectedSection.insert(indexPath.section)
                        }
                        headerView.setSelectDeselectButton(true)
                    } else {
                        if selectedSection.contains(indexPath.section) {
                            selectedSection.remove(indexPath.section)
                        }
                        headerView.setSelectDeselectButton(false)
                    }
                } else {
                    headerView.setSelectDeselectButton(false)
                }
            }
            collectionViewFlowLayout.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        }
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

//      MARK: - assets processing -
extension GroupedAssetListViewController {
    
    private func handleDeleteAssetsButton() {
        
        bottomMenuHeightConstraint.constant = !selectedAssets.isEmpty ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5): 0
        U.animate(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showDeleteConfirmAlert() {
        
        AlertManager.showDeletePhotoAssetsAlert {
            self.deleteSelectedAssets()
        }
    }
    
    private func deleteSelectedAssets() {
        
        let identifiers = selectedAssets.map({$0.localIdentifier})
        
        photoManager.deleteSelected(assets: selectedAssets) { success in
            if success {
                for group in self.assetGroups {
                    group.assets = group.assets.filter({!identifiers.contains($0.localIdentifier)})
                }
                self.assetGroups = self.assetGroups.filter({$0.assets.count != 1})
            }
            self.selectedAssets = []
            self.collectionView.reloadData()
        }
    }
    
    private func shouldSelectAllAssetsInSections(_ isSelect: Bool) {
        
        for section in 0..<collectionView.numberOfSections {
            if isSelect {
                self.collectionView.deselectAllItems(in: section, animated: true)
            } else {
                self.collectionView.selectAllItems(in: section, first: 1, animated: true)
            }
            
            for item in 1..<self.collectionView.numberOfItems(inSection: section) {
                if isSelect {
                    self.selectedAssets.removeAll()
                } else {
                    if !self.selectedAssets.contains(self.assetGroups[section].assets[item]) {
                        self.selectedAssets.append(self.assetGroups[section].assets[item])
                    }
                }
            }
            self.handleSelectAllButtonSection(IndexPath(item: 0, section: section))
        }
        self.handleDeleteAssetsButton()
    }
}

extension GroupedAssetListViewController: SelectDropDownMenuDelegate {
    
    func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
        switch didSelectItem {
            case .changeLayout:
                debugPrint("later")
            case .unselectAll:
                self.shouldSelectAllAssetsInSections(isSelectAllAssetsMode)
                isSelectAllAssetsMode = !isSelectAllAssetsMode
        }
    }
}

//      MARK: - Popup viewController drop down menu setup -
extension GroupedAssetListViewController {
    
    @objc func openOptionsBurgerMenu() {
        
        let firstRowMenuItem = isSelectAllAssetsMode ? deselectAllOptionItem : selectAllOptionItem
        let secondRowMenuItem = isSliderFlowLayout ? tileMenuOptionItem : sliderMenuOptionItem
        presentingDropDownBurgerMenu(with: [[firstRowMenuItem, secondRowMenuItem]], from: burgerOptionSettingButton)
    }
    
    private func presentingDropDownBurgerMenu(with items: [[DropDownOptionsMenuItem]], from barButtonItem: UIBarButtonItem) {
        
        let drobDownViewController = DropDownMenuViewController()
        drobDownViewController.menuSectionItems = items
        drobDownViewController.delegate = self
        guard let popoverPresentationController = drobDownViewController.popoverPresentationController else { fatalError("Error modal presentation style")}
        
        popoverPresentationController.barButtonItem = barButtonItem
        popoverPresentationController.delegate = self
        self.present(drobDownViewController, animated: true, completion: nil)
    }
}

extension GroupedAssetListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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

    private func setupNavigation() {
        
        self.navigationItem.rightBarButtonItem = burgerOptionSettingButton
    }
    
    private func setupListenersAndObservers() {}
}


