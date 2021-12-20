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

	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var circleSelectThumbView: UIView!
	@IBOutlet weak var bulbview: UIView!
	
    @IBOutlet weak var photoThumbnailImageView: UIImageView!
    @IBOutlet weak var photoCheckmarkImageView: UIImageView!
    @IBOutlet weak var buttonView: UIImageView!
    @IBOutlet weak var bestView: UIView!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var videoAssetDurationView: UIView!
    
    @IBOutlet weak var videoAssetDurationTextLabel: UILabel!
	@IBOutlet weak var playPhassetImageView: UIImageView!
	@IBOutlet weak var selectCellButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCellButtonHeightConstraint: NSLayoutConstraint!
    
    public var indexPath: IndexPath?
    public var cellMediaType: PhotoMediaType = .none
	public var cellContentType: MediaContentType = .none
    
    var delegate: PhotoCollectionViewCellDelegate?
        
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
	
		reuseShadowView.topShadowOffsetOriginY = -3
		reuseShadowView.topShadowOffsetOriginX = -3
		reuseShadowView.viewShadowOffsetOriginX = 8
		reuseShadowView.viewShadowOffsetOriginY = 8
		reuseShadowView.topBlurValue = 15
		reuseShadowView.shadowBlurValue = 5
        
        baseView.setCorner(14)
		photoThumbnailImageView.setCorner(14)
		circleSelectThumbView.rounded()
		bulbview.rounded()
		
        photoCheckmarkImageView.image = I.systemElementsItems.circleBox
        bestView.setCorner(8)
        videoAssetDurationView.setCorner(6)
    }
    
    public func selectButtonSetup(by contentType: PhotoMediaType) {
        switch contentType {
            case .duplicatedVideos, .similarVideos, .similarPhotos, .duplicatedPhotos:
                if indexPath?.row != 0 {
                    selectCellButtonWidthConstraint.constant = 40
                    selectCellButtonHeightConstraint.constant = 40
                    buttonView.layoutIfNeeded()
                    self.contentView.layoutIfNeeded()
                }
            default:
                debugPrint("")
        }
    }
    
    func updateColors() {
        
		baseView.backgroundColor = .clear
        photoCheckmarkImageView.tintColor = theme.accentBackgroundColor
        bestView.backgroundColor = theme.backgroundColor.withAlphaComponent(0.6)
		
        videoAssetDurationView.backgroundColor = theme.subTitleTextColor
		videoAssetDurationTextLabel.textColor = theme.activeTitleTextColor
		videoAssetDurationTextLabel.font = .systemFont(ofSize: 10, weight: .bold)
		
		circleSelectThumbView.backgroundColor = theme.cellBackGroundColor
		bulbview.backgroundColor = cellContentType.screenAcentTintColor
    }
    
    public func loadCellThumbnail(_ asset: PHAsset, size: CGSize) {
        let thumbnail = PHAssetFetchManager.shared.getThumbnail(from: asset, size: size)
        photoThumbnailImageView.contentMode = .scaleAspectFill
        photoThumbnailImageView.image = thumbnail
		playPhassetImageView.image = I.systemItems.defaultItems.onViewPlayButton
                
        switch cellMediaType {
			case .duplicatedVideos, .similarVideos:
                if asset.mediaType == .video {
                    let duration = CMTime(seconds: asset.duration, preferredTimescale: 1000000)
                    videoAssetDurationTextLabel.text = duration.durationText
					playPhassetImageView.isHidden = false
                }
            case .duplicatedPhotos, .similarPhotos:
                videoAssetDurationView.isHidden = true
				playPhassetImageView.isHidden = true
			case .singleScreenRecordings, .singleRecentlyDeletedVideos, .singleLargeVideos:
                if asset.mediaType == .video {
                    let duration = CMTime(seconds: asset.duration, preferredTimescale: 1000000)
                    videoAssetDurationTextLabel.text = duration.durationText
					playPhassetImageView.isHidden = false
                }
            default:
                videoAssetDurationView.isHidden = true
				playPhassetImageView.isHidden = true
        }
    }

    public func checkIsSelected() {
		self.photoCheckmarkImageView.image = self.isSelected ? cellContentType.selectableAssetsCheckMark : nil
    }
}
