//
//  ContentTypeTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos

class ContentTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var reuseShadowRoundedView: ReuseShadowRoundedView!
    
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

        horizontalProgressView.progress = 0
        horizontalProgressView.setNeedsDisplay()
		reuseShadowRoundedView.setImage(nil)
		rightArrowImageView.isHidden = true
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
     - `deepCleanCellConfigure`use for default cell config
     - `setupCellSelected` use in deep cleaning part for show selected checkmark for clean
    */
	
	public func deepCleanCellConfigure(with model: DeepCleanStateModel, mediaType: PhotoMediaType = .none, indexPath: IndexPath) {
		
		let currentState = model.cleanState
		let contentType = model.mediaType
		let currentProgress = model.deepCleanProgress
		let flowContentCount = model.flowContentCount()
		
		let mainTitle = contentType.contenType.getDeepCellTitle(index: indexPath.row)
		self.contentTypeTextLabel.text = mainTitle
		
		let subTitle = currentState.getTitle(by: contentType, files: flowContentCount, selected: flowContentCount, progress: currentProgress)
		contentSubtitleTextLabel.text = subTitle
		
		let selectedImage = contentType.contenType.selectableAssetsCheckMark
		let disabledImage = contentType.contenType.unAbleImageOfRows
		let activeImage = contentType.contenType.imageOfRows
		let processingImage = contentType.contenType.processingImageOfRows
		
		switch currentState {
			case .sleeping:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.resetProgress()
			case .prepare:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(processingImage)
				self.reuseShadowRoundedView.showIndicator()
				self.resetProgress()
			case .analyzing:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(processingImage)
				self.reuseShadowRoundedView.showIndicator()
				self.resetProgress()
			case .compare:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(processingImage)
				self.reuseShadowRoundedView.showIndicator()
				self.resetProgress()
			case .progress:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(processingImage)
				self.reuseShadowRoundedView.showIndicator()
				self.setProgress(currentProgress)
			case .complete:
				self.reuseShadowRoundedView.setImage(activeImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.setProgress(100)
			case .result:
				self.handleRightArrowState(true)
				self.reuseShadowRoundedView.setImage(activeImage)
				self.reuseShadowRoundedView.hideIndicator()
			case .empty:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.resetProgress()
			case .selected:
				self.handleRightArrowState(true)
				self.reuseShadowRoundedView.setImage(selectedImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.resetProgress()
		}
	}

	/// future label nees progress
		///
		/// let percentLabelFormat: String = "%.f %%"
//	let totalPercent = CGFloat(Double(current) / Double(total)) * 100
//		  let stingFormat = String(format: percentLabelFormat, totalPercent)
	
	
    public func cellConfig(contentType: MediaContentType,
                           photoMediaType: PhotoMediaType = .none,
                           indexPath: IndexPath,
                           phasetCount: Int,
						   selectedCount: Int?,
                           presentingType: CleanProcessingPresentType,
                           progress: CGFloat,
                           isProcessingComplete: Bool = false,
						   isReadyForCleaning: Bool) {
		

		switch presentingType {
				
			case .deepCleen:
//				contentTypeTextLabel.text = contentType.getDeepCellTitle(index: indexPath.row)
				
//				self.handleSelectedDeletedPHassets(content: contentType, isCompleted: isProcessingComplete, isSelected: isReadyForCleaning)
				
				let handledProgressSubtitle = progress == 0.0 ? "-" : String("progress - \(progress.rounded().cleanValue) %")
				let progressStringText = isProcessingComplete ? "processing wait" : handledProgressSubtitle
				let updatingCountValuesDeepClean: String = progressStringText
				let updatingCountValuesContactDeepClean: String = progressStringText
				
				var selectedCleaningItemsText = ""
				
				if let selected = selectedCount, selected != 0 {
					selectedCleaningItemsText = String("(\(selectedCount ?? 0) selected)")
				}
				
				if isProcessingComplete {
					self.horizontalProgressView.progress = 0
					self.horizontalProgressView.layoutIfNeeded()
					self.resetProgress()
				} else if progress == 100.0 {
					self.resetProgress()
				} else {
					self.horizontalProgressView.progress = progress / 100
					self.horizontalProgressView.layoutIfNeeded()
				}
				
				switch contentType {
					case .userPhoto, .userVideo:
						contentSubtitleTextLabel.text = isProcessingComplete ? phasetCount != 0 ? String("\(phasetCount) \("FILES".localized()) \(selectedCleaningItemsText)") : "no files to clean" : updatingCountValuesDeepClean
					case .userContacts:
						contentSubtitleTextLabel.text = isProcessingComplete ? phasetCount != 0 ? String("\(phasetCount) \("contacts") \(selectedCleaningItemsText)") : "no contacts to clean" : updatingCountValuesContactDeepClean
					case .none:
						contentSubtitleTextLabel.text = ""
				}
				
			case .singleSearch:
				contentTypeTextLabel.text = contentType.getCellTitle(index: indexPath.row)
				
				if !isProcessingComplete || progress == 1 {
					self.horizontalProgressView.progress = progress
					self.horizontalProgressView.progress = 0
					self.reuseShadowRoundedView.setImage(contentType.imageOfRows)
					reuseShadowRoundedView.hideIndicator()
				} else {
					self.reuseShadowRoundedView.setImage(contentType.processingImageOfRows)
					reuseShadowRoundedView.showIndicator()
					horizontalProgressView.progress = progress
				}
				
				switch photoMediaType {
						
					case .similarPhotos, .duplicatedPhotos, .similarSelfies, .similarVideos, .duplicatedVideos:
						contentSubtitleTextLabel.text = phasetCount != 0 ? String("\(phasetCount) \("duplicated phasset")") : "-"
					case .singleScreenShots, .singleLivePhotos, .singleLargeVideos, .singleScreenRecordings, .singleRecentlyDeletedPhotos, .singleRecentlyDeletedVideos:
						contentSubtitleTextLabel.text = phasetCount != 0 ?  String("\(phasetCount) \("FILES".localized())") : "no files"
					case .allContacts, .emptyContacts:
						contentSubtitleTextLabel.text  = phasetCount != 0 ? String("\(phasetCount) contacts") : ""
					case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
						contentSubtitleTextLabel.text = phasetCount != 0 ? String("\(phasetCount) duplicated groups") : "-"
					case .compress:
						contentSubtitleTextLabel.text = ""
					default:
						return
				}
			case .background:
					return
		}
		
		if isProcessingComplete && phasetCount != 0 {
			rightArrowImageView.isHidden = false
		}
    }

	
	public func handleSelectedDeletedPHassets(content type: MediaContentType, isCompleted: Bool, isSelected: Bool) {
		
		let processingCellImage = isSelected ? type.selectableAssetsCheckMark : isCompleted ? type.imageOfRows : type.unAbleImageOfRows
		reuseShadowRoundedView.setImage(processingCellImage)
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
		rightArrowImageView.isHidden = true
        
        baseView.setCorner(14)
        contentTypeTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        contentSubtitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
        rightArrowImageView.image = I.systemItems.navigationBarItems.forward
    }
    
    func updateColors() {
        baseView.backgroundColor = .clear
        reuseShadowRoundedView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
        contentTypeTextLabel.textColor = theme.titleTextColor
        contentSubtitleTextLabel.textColor = theme.subTitleTextColor
        horizontalProgressView.progressColor = theme.progressBackgroundColor
    }
}

	///  `handle progress`
extension ContentTypeTableViewCell {
	
	public func resetProgress() {
		self.horizontalProgressView.resetProgressLayer()
	}
	
	private func setProgress(_ progress: CGFloat) {
		self.horizontalProgressView.progress = progress / 100
		self.horizontalProgressView.layoutIfNeeded()
	}
	
	private func completedProgress() {
		self.horizontalProgressView.progress = 0
		self.horizontalProgressView.layoutIfNeeded()
		self.resetProgress()
	}
}

extension ContentTypeTableViewCell {
	
	private func handleRightArrowState(_ show: Bool) {
		self.rightArrowImageView.isHidden = !show
	}
}
