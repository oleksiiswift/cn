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
    @IBOutlet weak var deleteAssetsButtonView: UIView!
    @IBOutlet weak var deleteAssetsTexetLabel: UILabel!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    
    public var assetCollection: [PHAsset] = []
    public var photoMediaType: PhotoMediaType = .none
    
    private var photoManager = PhotoManager()
//        let zoomAndSnap = ZoomAndSnapFlowLayout()

    private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3, minimumInterSpacing: 3, minimumLineSpacing: 3, inset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
    private var bottomMenuHeight: CGFloat = 80
    
    private lazy var selectAllButton = UIBarButtonItem(title: "select all", style: .plain, target: self, action: #selector(handleSelectAllButtonTapped))
    private lazy var deselectAllButton = UIBarButtonItem(title: "deselect all", style: .plain, target: self, action: #selector(handleSelectAllButtonTapped))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateColors()
        setupCollectionView()
        setupNavigation()
        setupListenersAndObservers()
    }
    
    @IBAction func didTapDeleteAssetsActionButton(_ sender: Any) {
        showDeleteSelectedAssetsAlert()
    }
}

//  MARK: - collection view setup -

extension SimpleAssetsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        
        switch photoMediaType {
            case .largeVideos:
                flowLayout.isSquare = true
            default:
                flowLayout.itemHieght = ((U.screenWidth - 26) / 3) / U.ratio
        }
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.reloadData()
        
        if U.hasTopNotch {
//            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: U.bottomSafeAreaHeight * 2, right: 0)
        }
    }
    
    private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        /// config thumbnail according screen type
        switch photoMediaType {
            case .screenshots:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: ((U.screenWidth - 26) / 2),
                                                    height: ((U.screenHeight - 26) / 2) / U.ratio ))
            case .selfies:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenHeight - 26) / 2) / U.ratio))
            case .livephotos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .largeVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .similarVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .duplicateVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .screenRecording:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            default:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
        }
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        debugPrint("some other func ")
        return false
    }
        
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let asset = self.assetCollection[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil) {
            return AssetContextPreviewViewController(asset: asset)
        } actionProvider: { _ in
            return self.createCellContextMenu(for: asset, at: indexPath)
        }
    }
}

extension SimpleAssetsListViewController: PhotoCollectionViewCellDelegate {
    
    /// custom select deselect button for selected cells
    /// did select item need for preview photo
    /// need handle select button state and check cell.isSelected for checkmark image
    /// for celected cell use cell delegate and indexPath
    
    func didSelectCell(at indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            if cell.isSelected {
                self.collectionView.deselectItem(at: indexPath, animated: true)
                cell.isSelected = false
            } else {
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                cell.isSelected = true
            }
        }
        
        handleSelectAllButtonState()
        handleBottomButtonMenu()
    }
}

extension SimpleAssetsListViewController {
    
    @objc func handleSelectAllButtonTapped() {
    
        let selected = collectionView.indexPathsForSelectedItems?.count == assetCollection.count
        self.navigationItem.rightBarButtonItem = selected ? selectAllButton : deselectAllButton
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
            
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.isSelected = !selected
                cell.checkIsSelected()
            }
        }
    }
    
    private func handleSelectAllButtonState() {
        
        self.navigationItem.rightBarButtonItem = self.collectionView.indexPathsForSelectedItems?.count != assetCollection.count ? selectAllButton : deselectAllButton
    }
    
    private func handleBottomButtonMenu() {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
            self.collectionView.contentInset.bottom = selectedItems.count > 0 ? 10 : 5
            U.animate(0.5) {
                self.collectionView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func showDeleteSelectedAssetsAlert() {
        
        AlertManager.showDeletePhotoAssetsAlert {
            self.deleteSelectedAssets()
        }
    }
    
//    MARK: - delete assets - 
    private func deleteSelectedAssets() {
        
        guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
        
        var assetsToDelete: [PHAsset] = []
        
        selectedIndexPath.forEach { indexPath in
            let assetInCollection = self.assetCollection[indexPath.row]
                assetsToDelete.append(assetInCollection)
        }
            
        photoManager.deleteSelected(assets: assetsToDelete) { success in
            if success {
                let assetIdentifiers = assetsToDelete.map({ $0.localIdentifier})                
                self.assetCollection = self.assetCollection.filter({!assetIdentifiers.contains($0.localIdentifier)})
                self.collectionView.reloadData()
                self.handleSelectAllButtonState()
                self.handleBottomButtonMenu()
            }
        }
    }
    
    private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
        
        let fullScreenPreviewAction = UIAction(title: "full screen preview", image: I.cellElementsItems.fullScreen) { _ in
            debugPrint("show full screen preview at :\(asset.imageSize)")
            debugPrint(indexPath)
        }
        
        let deleteAssetAction = UIAction(title: "delete", image: I.cellElementsItems.trashBin) { _ in
            debugPrint("delete action at :\(asset.imageSize)")
            debugPrint(indexPath)
        }
        
        return UIMenu(title: "", children: [fullScreenPreviewAction, deleteAssetAction])
    }
}

//      MARK: - setup UI -

extension SimpleAssetsListViewController: Themeble {
    
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
        
        self.navigationItem.rightBarButtonItem = selectAllButton
    }
    
    private func setupListenersAndObservers() {
        
        UpdatingChangesInOpenedScreensMediator.instance.setListener(listener: self)
    }
}

//      MARK: - updating screen if photolibrary did change it content -

extension SimpleAssetsListViewController: UpdatingChangesInOpenedScreensListeners {
    
    /// updating screenshots
    func getUpdatingScreenShots() {
        
        if photoMediaType == .screenshots {
            photoManager.getScreenShots(from: S.startingSavedDate, to: S.endingSavedDate) { screenShots in
                if self.assetCollection.count != screenShots.count {
                    self.assetCollection = screenShots
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    /// updating selfies
    func getUpdatingSelfies() {
        
        if photoMediaType == .selfies {
            photoManager.getSelfiePhotos(from: S.startingSavedDate, to: S.endingSavedDate) { selfies in
                if self.assetCollection.count != selfies.count {
                    self.assetCollection = selfies
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
