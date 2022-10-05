//
//  ContentTypeTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos

protocol ContentTypeCellDelegate {
	func setCancelProcessOperaion(for cell: ContentTypeTableViewCell)
}

class ContentTypeTableViewCell: UITableViewCell {
    
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var reuseShadowRoundedView: ReuseShadowRoundedView!
    @IBOutlet weak var contentTypeTextLabel: UILabel!
    @IBOutlet weak var contentSubtitleTextLabel: UILabel!
    @IBOutlet weak var horizontalProgressView: HorizontalProgressBar!
	@IBOutlet weak var reuseShadowHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var operationActionButton: UIButton!
	
	public var delegate: ContentTypeCellDelegate?
	
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
		
		let margins = AppDimensions.ContenTypeCells.mediaContentTypeCellIEdgeInset
          contentView.frame = contentView.frame.inset(by: margins)
    }
	@IBAction func stopOperationActionButton(_ sender: Any) {
		delegate?.setCancelProcessOperaion(for: self)
	}
}

extension ContentTypeTableViewCell {
    
    /**
     - `deepCleanCellConfigure`use for default cell config
     - `handleDeepCellState` use in deep cleaning part for show selected checkmark for clean or state
    */
	
	public func singleCleanCellConfigure(with model: SingleCleanStateModel, mediaType: PhotoMediaType = .none, indexPath: IndexPath, for groupProcessing: Bool) {
		
		let mainTitle = model.mediaType.contenType.getCellTitle(index: indexPath.row)
		self.contentTypeTextLabel.text = mainTitle
		
		let subTitle = model.cleanState.getTitle(by: model.mediaType, files: model.resultCount, selected: 0, progress: model.cleanProgress)
		contentSubtitleTextLabel.text = subTitle
		
		self.handleSingleCellState(with: model.cleanState, model: model, for: groupProcessing)
	}
	
	public func deepCleanCellConfigure(with model: DeepCleanStateModel, mediaType: PhotoMediaType = .none, indexPath: IndexPath) {
	
		let mainTitle = model.mediaType.contenType.getDeepCellTitle(index: indexPath.row)
		self.contentTypeTextLabel.text = mainTitle
		
		let subTitle = model.cleanState.getTitle(by: model.mediaType, files: model.resultsCount, selected: model.selectedContentCount(), progress: model.deepCleanProgress)
		contentSubtitleTextLabel.text = subTitle
		
		self.handleDeepCellState(with: model.cleanState, model: model)
	}
	
	private func handleDeepCellState(with state: ProcessingProgressOperationState, model: DeepCleanStateModel) {
		
		let selectedImage = model.mediaType.contenType.selectableAssetsCheckMark
		let disabledImage = model.mediaType.contenType.unAbleImageOfRows
		let activeImage = model.mediaType.contenType.imageOfRows
		let processingImage = model.mediaType.contenType.processingImageOfRows
		
		self.horizontalProgressView.state = model.cleanState
		
		switch model.cleanState {
			case .sleeping:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.resetProgress()
			case .prepare:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.resetProgress()
			case .analyzing:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.resetProgress()
			case .compare:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.setProgress(model.deepCleanProgress)
			case .progress:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.setProgress(model.deepCleanProgress)
			case .result:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(activeImage)
				self.setProgress(100)
			case .complete:
				self.handleRightArrowState(!model.isEmpty)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(model.isEmpty ? disabledImage : activeImage)
				self.resetProgress()
			case .empty:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.resetProgress()
			case .selected:
				self.handleRightArrowState(model.isEmpty)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(selectedImage)
				self.resetProgress()
		}
	}
	
	private func handleSingleCellState(with state: ProcessingProgressOperationState, model: SingleCleanStateModel, for groupProcessing: Bool) {
		
		let selectedImage = model.mediaType.contenType.selectableAssetsCheckMark
		let disabledImage = model.mediaType.contenType.unAbleImageOfRows
		let activeImage = model.mediaType.contenType.imageOfRows
		let processingImage = model.mediaType.contenType.processingImageOfRows
		
		self.horizontalProgressView.state = model.cleanState
		self.handleTouchOperationCell(for: model, contentType: model.mediaType.contenType, for: groupProcessing)
		switch model.cleanState {
			case .sleeping:
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.resetProgress()
			case .prepare:
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.resetProgress()
			case .analyzing:
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.resetProgress()
			case .compare:
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.setProgress(model.cleanProgress)
			case .progress:
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.setProgress(model.cleanProgress)
			case .result:
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(activeImage)
				self.setProgress(100)
			case .complete:
				self.handleRightArrowState(!model.isEmpty)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(model.isEmpty ? disabledImage : activeImage)
				self.resetProgress()
			case .empty:
				self.reuseShadowRoundedView.setImage(disabledImage)
				self.reuseShadowRoundedView.hideIndicator()
				self.resetProgress()
			case .selected:
				self.handleRightArrowState(model.isEmpty)
				self.reuseShadowRoundedView.hideIndicator()
				self.reuseShadowRoundedView.setImage(selectedImage)
				self.resetProgress()
		}
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
	
	private func handleRightArrowState(_ show: Bool) {
		self.rightArrowImageView.isHidden = !show
	}
	
	private func handleTouchOperationCell(for model: SingleCleanStateModel, contentType: MediaContentType, for groupProcessing: Bool) {
		let state = model.cleanState
		switch state {
			case .complete, .selected:
				self.rightArrowImageView.isHidden = model.isEmpty
				self.rightArrowImageView.image = I.systemItems.navigationBarItems.forward
				self.operationActionButton.isEnabled = false
				self.rightArrowImageView.transform = .identity
			case .sleeping, .empty, .compare:
				self.rightArrowImageView.isHidden = true
				self.rightArrowImageView.image = nil
				self.operationActionButton.isEnabled = false
				self.rightArrowImageView.transform = .identity
			case .prepare, .analyzing, .progress:
				guard !groupProcessing else { return}
				self.operationActionButton.isEnabled = true
				self.rightArrowImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
				self.rightArrowImageView.isHidden = false
				self.rightArrowImageView.image = I.systemItems.navigationBarItems.stopMagic
				self.rightArrowImageView.tintColor = contentType.screenAcentTintColor
			case .result:
				self.rightArrowImageView.transform = .identity
				self.operationActionButton.isEnabled = false
				self.rightArrowImageView.isHidden = false
				self.rightArrowImageView.image = I.systemItems.navigationBarItems.forward
				self.rightArrowImageView.tintColor = nil
		}
	}
}

extension ContentTypeTableViewCell: Themeble {
	
	func setupCellUI() {
		selectionStyle = .none
		rightArrowImageView.isHidden = true
		self.operationActionButton.isEnabled = false
		baseView.setCorner(14)
		
		reuseShadowHeightConstraint.constant = AppDimensions.ContenTypeCells.helperImageViewWidth
		reuseShadowRoundedView.layoutIfNeeded()
		reuseShadowRoundedView.updateImagesLayout()
		contentTypeTextLabel.font = FontManager.contentTypeFont(of: .title)
		contentSubtitleTextLabel.font = FontManager.contentTypeFont(of: .subtitle)
	}
	
	func updateColors() {
		baseView.backgroundColor = .clear
		reuseShadowRoundedView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
		contentTypeTextLabel.textColor = theme.titleTextColor
		contentSubtitleTextLabel.textColor = theme.subTitleTextColor
		horizontalProgressView.progressColor = theme.progressBackgroundColor
	}
}
	
extension ContentTypeTableViewCell {

	public func handleSelectedDeletedPHassets(content type: MediaContentType, isCompleted: Bool, isSelected: Bool) {
		
		let processingCellImage = isSelected ? type.selectableAssetsCheckMark : isCompleted ? type.imageOfRows : type.unAbleImageOfRows
		self.reuseShadowRoundedView.setImage(processingCellImage)
	}
}

extension ContentTypeTableViewCell {
	
	public func settingsCellConfigure(with settings: SettingsModel) {
		
		reuseShadowView.topShadowOffsetOriginY = -2
		reuseShadowView.topShadowOffsetOriginX = -2
		reuseShadowView.viewShadowOffsetOriginX = 6
		reuseShadowView.viewShadowOffsetOriginY = 6
		reuseShadowView.topBlurValue = 15
		reuseShadowView.shadowBlurValue = 5
		
		self.contentTypeTextLabel.text = settings.settingsTitle
		let imageSizeWidth = reuseShadowRoundedView.frame.size.width / 1.8
		let roundedShadowImageSize = CGSize(width: imageSizeWidth, height: imageSizeWidth)
		reuseShadowRoundedView.setImageWithCustomBackground(image: settings.settingsImages,
															tineColor: .white,
															size: roundedShadowImageSize,
															colors: settings.gradientColorsForSettings)
		reuseShadowRoundedView.updateImagesLayout()
		self.contentSubtitleTextLabel.isHidden = true
	}
}


