//
//  PhotoCollectionViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit
import Photos

protocol PhotoCollectionViewCellDelegate {
    func didSelectCell(at indexPath: IndexPath)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var photoThumbnailImageView: UIImageView!
    @IBOutlet weak var photoCheckmarkImageView: UIImageView!
    
    public var indexPath: IndexPath?
    
    var delegate: PhotoCollectionViewCellDelegate?
        
//    override var isSelected: Bool {
//        didSet {
//            checkIsSelected()
//        }
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoCheckmarkImageView.image = I.systemElementsItems.circleBox
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
    
    @IBAction func didTapSetSelectedCellActionButton(_ sender: Any) {
        if let indexPath = self.indexPath {
            delegate?.didSelectCell(at: indexPath)
            checkIsSelected()
        }
    }
}

extension PhotoCollectionViewCell: Themeble {
    
    private func setupUI() {
        
        baseView.setCorner(12)
        photoCheckmarkImageView.image = I.systemElementsItems.circleBox
    }
    
    func updateColors() {
        
        baseView.backgroundColor = currentTheme.sectionBackgroundColor
        photoCheckmarkImageView.tintColor = currentTheme.accentBackgroundColor
    }
    
    public func loadCellThumbnail(_ asset: PHAsset, size: CGSize) {
        let thumbnail = PHAssetFetchManager.shared.getThumbnail(from: asset, size: size)
        photoThumbnailImageView.contentMode = .scaleAspectFill
        photoThumbnailImageView.image = thumbnail
    }

    public func checkIsSelected() {
        self.photoCheckmarkImageView.image = self.isSelected ? I.systemElementsItems.circleCheckBox : I.systemElementsItems.circleBox
    }
}
