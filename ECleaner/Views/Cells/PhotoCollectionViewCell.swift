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
    @IBOutlet weak var buttonView: UIImageView!
    @IBOutlet weak var bestView: UIView!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var videoAssetDurationView: UIView!
    
    @IBOutlet weak var videoAssetDurationTextLabel: UILabel!
    @IBOutlet weak var selectCellButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCellButtonHeightConstraint: NSLayoutConstraint!
    
    public var indexPath: IndexPath?
    public var cellContentType: PhotoMediaType = .none
    
    var delegate: PhotoCollectionViewCellDelegate?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.setBestView(isHiden: true)
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
        
        baseView.backgroundColor = currentTheme.sectionBackgroundColor
        photoCheckmarkImageView.tintColor = currentTheme.accentBackgroundColor
    }
    
    public func loadCellThumbnail(_ asset: PHAsset, size: CGSize) {
        let thumbnail = PHAssetFetchManager.shared.getThumbnail(from: asset, size: size)
        photoThumbnailImageView.contentMode = .scaleAspectFill
        photoThumbnailImageView.image = thumbnail
                
        switch cellContentType {
            case .duplicatedVideos, .similarVideos:
                if asset.mediaType == .video {
                    let duration = CMTime(seconds: asset.duration, preferredTimescale: 1000000)
                    videoAssetDurationTextLabel.text = duration.durationText
                }
                
                self.setBestView(isHiden: indexPath?.row != 0)
            case .duplicatedPhotos, .similarPhotos:
                
                self.setBestView(isHiden: indexPath?.row != 0)
                videoAssetDurationView.isHidden = true
                
            case .singleScreenRecordings:
                if asset.mediaType == .video {
                    let duration = CMTime(seconds: asset.duration, preferredTimescale: 1000000)
                    videoAssetDurationTextLabel.text = duration.durationText
                }

            default:
                videoAssetDurationView.isHidden = true
        }
    }
    
    private func setBestView(isHiden: Bool) {
        bestView.isHidden = isHidden
        bestLabel.text = isHidden ? "" : "best"
    }

    public func checkIsSelected() {
        self.photoCheckmarkImageView.image = self.isSelected ? I.systemElementsItems.circleCheckBox : I.systemElementsItems.circleBox
    }
}


extension CMTime {
    
    var durationText: String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
