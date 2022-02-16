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
    @IBOutlet weak var contentTypeTextLabel: UILabel!
    @IBOutlet weak var contentSubtitleTextLabel: UILabel!
    @IBOutlet weak var horizontalProgressView: HorizontalProgressBar!

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
          //set the values for top,left,bottom,right margins
          let margins = UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
          contentView.frame = contentView.frame.inset(by: margins)
//          contentView.layer.cornerRadius = 8
    }
}

extension ContentTypeTableViewCell {
    
    /**
     - `deepCleanCellConfigure`use for default cell config
     - `handleDeepCellState` use in deep cleaning part for show selected checkmark for clean or state
    */
	
	public func singleCleanCellConfigure(with model: SingleCleanStateModel, mediaType: PhotoMediaType = .none, indexPath: IndexPath) {
		
		let mainTitle = model.mediaType.contenType.getCellTitle(index: indexPath.row)
		self.contentTypeTextLabel.text = mainTitle
		
		let subTitle = model.cleanState.getTitle(by: model.mediaType, files: model.resultCount, selected: 0, progress: model.cleanProgress)
		contentSubtitleTextLabel.text = subTitle
		
		self.handleSingleCellState(with: model.cleanState, model: model)
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
				self.resetProgress()
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
	
	private func handleSingleCellState(with state: ProcessingProgressOperationState, model: SingleCleanStateModel) {
		
		let selectedImage = model.mediaType.contenType.selectableAssetsCheckMark
		let disabledImage = model.mediaType.contenType.unAbleImageOfRows
		let activeImage = model.mediaType.contenType.imageOfRows
		let processingImage = model.mediaType.contenType.processingImageOfRows
		
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
				self.resetProgress()
			case .progress:
				self.handleRightArrowState(false)
				self.reuseShadowRoundedView.showIndicator()
				self.reuseShadowRoundedView.setImage(processingImage)
				self.setProgress(model.cleanProgress)
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
	
extension ContentTypeTableViewCell {

	public func handleSelectedDeletedPHassets(content type: MediaContentType, isCompleted: Bool, isSelected: Bool) {
		
		let processingCellImage = isSelected ? type.selectableAssetsCheckMark : isCompleted ? type.imageOfRows : type.unAbleImageOfRows
		reuseShadowRoundedView.setImage(processingCellImage)
	}
}
