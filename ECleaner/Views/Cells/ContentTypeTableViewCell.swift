//
//  ContentTypeTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos

class ContentTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseView: ShadowView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    @IBOutlet weak var shadowImageView: ShadowRoundedView!
//    @IBOutlet weak var selectedAssetsContainerView: UIView!
//    @IBOutlet weak var selectedAssetsImageView: UIImageView!
    
    @IBOutlet weak var contentTypeTextLabel: UILabel!
    @IBOutlet weak var contentSubtitleTextLabel: UILabel!
//    @IBOutlet weak var selectedContainerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var horizontalProgressView: HorizontalProgressBar!
    
    var tempAddTextLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentTypeTextLabel.text = nil
        contentSubtitleTextLabel.text = nil
//        selectedAssetsImageView.image = nil
        
        horizontalProgressView.progress = 0
        horizontalProgressView.setNeedsDisplay()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellUI()
        updateColors()
        
        addSubview(tempAddTextLabel)
        tempAddTextLabel.translatesAutoresizingMaskIntoConstraints = false
        tempAddTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 100).isActive = true
        tempAddTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        tempAddTextLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tempAddTextLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          //set the values for top,left,bottom,right margins
          let margins = UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
          contentView.frame = contentView.frame.inset(by: margins)
//          contentView.layer.cornerRadius = 8
    }
}

extension ContentTypeTableViewCell {
    
    /**
     - `cellConfig`use for default cell config
     - `setupCellSelected` use in deep cleaning part for show selected checkmark for clean
    */
    
    public func cellConfig(contentType: MediaContentType, indexPath: IndexPath, phasetCount: Int, isDeepCleanController: Bool = false, progress: CGFloat, isProcessingComplete: Bool = false) {
        
        let progressStringText = isProcessingComplete ? "processing wait" : String("progress - \(progress.rounded().cleanValue) %")
        let updatingCountValuesDeepClean: String = isDeepCleanController ? progressStringText : "0 \("FILES".localized())"
        let updatingCountValuesContactDeepClean: String = isDeepCleanController ?  progressStringText : "0 contacts"
        
        contentTypeTextLabel.text = isDeepCleanController ? contentType.getDeepCellTitle(index: indexPath.row) : contentType.getCellTitle(index: indexPath.row)
        horizontalProgressView.progress = progress / 100

        switch contentType {
            case .userPhoto, .userVideo:
                contentSubtitleTextLabel.text = isProcessingComplete ? phasetCount != 0 ? String("\(phasetCount) \("FILES".localized())") : "no files to clean" : updatingCountValuesDeepClean
            case .userContacts:
                if isDeepCleanController {
                    contentSubtitleTextLabel.text = isProcessingComplete ? phasetCount != 0 ? String("\(phasetCount) \("contacts")") : "no contacts to clean" : updatingCountValuesContactDeepClean
                } else {
                    contentSubtitleTextLabel.text  = phasetCount != 0 ? String("\(phasetCount) contacts") : ""
                }
            case .none:
                contentSubtitleTextLabel.text = ""
        }
        
        shadowImageView.imageView.image = contentType.imageOfRows
    }

    public func setupCellSelected(at indexPath: IndexPath, isSelected: Bool) {
        
//        selectedAssetsContainerView.isHidden = false
//        selectedContainerWidthConstraint.constant = 36
//        selectedAssetsImageView.image = isSelected ? I.systemElementsItems.circleCheckBox : I.systemElementsItems.circleBox
    }
}

extension ContentTypeTableViewCell: Themeble {
    
    func setupCellUI() {
        
        selectionStyle = .none
        
        baseView.setCorner(14)
        contentTypeTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        contentSubtitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
        rightArrowImageView.image = I.navigationItems.rightShevronBack
    }
    
    func updateColors() {
        baseView.backgroundColor = theme.contentBackgroundColor
        contentTypeTextLabel.textColor = theme.titleTextColor
        contentSubtitleTextLabel.textColor = theme.subTitleTextColor
        horizontalProgressView.progressColor = theme.progressBackgroundColor
    }
}
