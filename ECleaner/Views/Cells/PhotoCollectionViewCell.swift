//
//  PhotoCollectionViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var photoThumbnailImageView: UIImageView!
    @IBOutlet weak var photoCheckmarkImageView: UIImageView!
    

    public var cellSelected: Bool = false {
        didSet {
            
        }
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoThumbnailImageView.image = nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

}

extension PhotoCollectionViewCell: Themeble {
    
    private func setupUI() {
        
        baseView.setCorner(12)
    }
    
    func updateColors() {
        
        baseView.backgroundColor = currentTheme.sectionBackgroundColor
    }
    
    public func loadCellThumbnail(_ asset: PHAsset, size: CGSize) {

        let thumbnail = PHAssetFetchManager.shared.getThumbnail(from: asset, size: size)
        photoThumbnailImageView.image = thumbnail
        
    }
}
