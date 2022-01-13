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

	@IBOutlet weak var reuseShadowView: CollectionShadowView!
	@IBOutlet weak var baseView: UIView!
	
	@IBOutlet weak var selectableView: UIView!
	@IBOutlet weak var circleSelectThumbView: UIView!
	@IBOutlet weak var bulbview: UIView!
	
    @IBOutlet weak var photoThumbnailImageView: UIImageView!
    @IBOutlet weak var photoCheckmarkImageView: UIImageView!
	@IBOutlet weak var buttonView: UIButton!
	@IBOutlet weak var bestView: UIView!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var videoAssetDurationView: UIView!
    
    @IBOutlet weak var videoAssetDurationTextLabel: UILabel!
	@IBOutlet weak var playPhassetImageView: UIImageView!
	@IBOutlet weak var selectCellButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCellButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var reuseTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var reuseLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var reuseTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var reuseBottomConstraint: NSLayoutConstraint!
	
    public var indexPath: IndexPath?
    public var cellMediaType: PhotoMediaType = .none
	public var cellContentType: MediaContentType = .none
    
    var delegate: PhotoCollectionViewCellDelegate?
	
	var pointOfNowReturn = 3
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoCheckmarkImageView.image = I.systemElementsItems.circleBox
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }
	
	override func layoutSubviews() {
		 super.layoutSubviews()
	
	}
    
    @IBAction func didTapSetSelectedCellActionButton(_ sender: Any) {
        
        if let indexPath = self.indexPath {
            delegate?.didSelectCell(at: indexPath)
            checkIsSelected()
        }
    }
}

extension PhotoCollectionViewCell: Themeble {
    
    public func setupUI() {
		
		self.setCorner(6)
		self.contentView.setCorner(8)
		
		bestView.setCorner(11)
		bestLabel.text = "best".uppercased()
		bestLabel.font = .systemFont(ofSize: 10, weight: .bold)
		
        baseView.setCorner(14)
		photoThumbnailImageView.setCorner(10)
		
		circleSelectThumbView.rounded()
		bulbview.rounded()
		
        photoCheckmarkImageView.image = I.systemElementsItems.circleBox
        videoAssetDurationView.setCorner(6)
		
		switch cellMediaType {
			case .similarPhotos, .duplicatedPhotos, .duplicatedVideos, .similarVideos:
				reuseTopConstraint.constant = 6
				reuseBottomConstraint.constant = 6
				reuseLeadingConstraint.constant = 6
				reuseTrailingConstraint.constant = 6
				baseView.layoutIfNeeded()
				reuseShadowView.layoutIfNeeded()
				reuseShadowView.layoutSubviews()
			default:
				return
		}
    }
	
    public func selectButtonSetup(by contentType: PhotoMediaType) {
        switch contentType {
            case .duplicatedVideos, .similarVideos, .similarPhotos, .duplicatedPhotos:
                if indexPath?.row != 0 {
                    selectCellButtonWidthConstraint.constant = 40
                    selectCellButtonHeightConstraint.constant = 40
                    buttonView.layoutIfNeeded()
					setBestView(availible: false)
					setSelectable(availible: true)
				} else {
					setSelectable(availible: false)
					setupBestView()
					setBestView(availible: true)
				}
            default:
                setBestView(availible: false)
				setSelectable(availible: true)
        }
    }
    
    func updateColors() {
	
		baseView.backgroundColor = theme.backgroundColor
        photoCheckmarkImageView.tintColor = theme.accentBackgroundColor
	
		bestLabel.textColor  = theme.activeTitleTextColor
        videoAssetDurationView.backgroundColor = theme.subTitleTextColor
		videoAssetDurationTextLabel.textColor = theme.activeTitleTextColor
		videoAssetDurationTextLabel.font = .systemFont(ofSize: 10, weight: .bold)
		
		circleSelectThumbView.backgroundColor = theme.cellBackGroundColor
		bulbview.backgroundColor = cellContentType.screenAcentTintColor
    }
    
    public func loadCellThumbnail(_ asset: PHAsset, image: UIImage?) {

        photoThumbnailImageView.contentMode = .scaleAspectFill
        photoThumbnailImageView.image = image
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
	
	public func setBestView(availible: Bool = false) {
		bestView.isHidden = !availible
	}
	
	public func setupBestView() {
		
		let bestViewGradientMask: CAGradientLayer = CAGradientLayer()
		bestViewGradientMask.frame = CGRect(x: 0, y: 0, width: bestView.frame.width, height: bestView.frame.height)
		bestViewGradientMask.colors = self.cellContentType.screeAcentGradientColorSet
		bestViewGradientMask.startPoint = CGPoint(x: 0.0, y: 0.0)
		bestViewGradientMask.endPoint = CGPoint(x: 0.0, y: 1.0)
		bestView.layer.addSublayer(bestViewGradientMask)
		bestView.bringSubviewToFront(bestLabel)
	}
	
	public func setSelectable(availible: Bool = true) {
		selectableView.isHidden = !availible
	}
}
