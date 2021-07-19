//
//  PhotoPreviewViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 19.07.2021.
//

import UIKit
import Photos

enum CollectionType {
    case grouped
    case single
    case none
}

class PhotoPreviewViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var photoMediaContentType: PhotoMediaType = .none
    public var groupAssetsCollection: [PhassetGroup] = []
    public var singleAssetsCollection: [PHAsset] = []
    private var collectionType: CollectionType = .none
    
    private var chacheManager = PHCachingImageManager()
    
    init() {
        super.init(nibName: C.identifiers.xibs.photoPreview, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        setupCollectionView()    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

//      MARK: - ui setup -
extension PhotoPreviewViewController {

    private func setupUI() {
    }
    
    private func setupCollectionView() {
    
        let cellPadding: CGFloat = 0
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: self.view.frame.width, height: self.view.frame.height)
        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        carouselLayout.minimumLineSpacing = cellPadding
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = carouselLayout
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: C.identifiers.cells.carouselCell)
    }
    
    public func mediaContentTypeSetup() {
        
        switch photoMediaContentType {
            case .singleSelfies, .singleLivePhotos, .singleLargeVideos, .singleScreenShots, .singleScreenRecordings:
                self.collectionType = .single
            case .duplicatedPhotos, .duplicatedVideos, .similarPhotos, .similarVideos, .similarLivePhotos:
                self.collectionType = .grouped
            default:
                self.collectionType = .none
        }
    }
    
    private func configure(_ cell: CarouselCollectionViewCell, at indexPath: IndexPath) {
        
        let targetSize = CGSize(width: U.screenWidth, height: U.screenHeight)
        
        switch collectionType {
            case .single:
                chacheManager.requestImage(for: singleAssetsCollection[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
                    U.UI {
                        if let image = image {
                            cell.configureCell(image: image)
                            debugPrint("cell config")
                        }
                    }
                }
            case .grouped:
//                chacheManager.requestImage(for: groupAssetsCollection[indexPath.section].assets[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
//                    U.UI {
//                        if let image = image {
//                            cell.configureCell(image: image)
//                            debugPrint("group cell configured")
//                        }
//                    }
//                }
                if let image = groupAssetsCollection[indexPath.section].assets[indexPath.row].thumbnail {
                    cell.configureCell(image: image)
                }
            
            default:
                debugPrint("no collection error")
        }
    }
    
    public func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    public func scrollToImageView(at indexPath: IndexPath) {
        debugPrint(indexPath)
        U.UI {
            self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
}



extension PhotoPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionType == .single ? 1 : groupAssetsCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionType == .single ? singleAssetsCollection.count : groupAssetsCollection[section].assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.carouselCell, for: indexPath) as! CarouselCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        U.UI {
//            switch self.collectionType {
//                case .single:
//                    let scale = max(U.mainScreen.scale, 2)
//                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
//                    self.chacheManager.startCachingImages(for: self.singleAssetsCollection, targetSize: targetSize, contentMode: .aspectFit, options: nil)
//                case .grouped:
//                    let scale = max(U.mainScreen.scale, 2)
//                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
//                    var assets: [PHAsset] = []
//                    for group in self.groupAssetsCollection {
//                        assets.append(contentsOf: group.assets)
//                    }
//                    self.chacheManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFit, options: nil)
//                default:
//                    return
//            }
        }
    }
}

class CarouselViewRemove: UIView {
    
//    MARK: - properties -
    
    struct CarouselDataAssets {
        let image: UIImage?
        let isSelected: Bool
    }

}


//// MARK: - UICollectionView Delegate
//extension CarouselView: UICollectionViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
//}
//// MARKK: - Helpers
//private extension CarouselView {
//    func getCurrentPage() -> Int {
//
//        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
//            return visibleIndexPath.row
//        }
//
//        return currentPage
//    }
//}
