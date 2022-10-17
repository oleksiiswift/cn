//
//  InfoSpaceView.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.10.2022.
//

import UIKit

class InfoSpaceView: UIView {

	@IBOutlet var contentView: UIView!
	@IBOutlet weak var progressTitileTextLabel: UILabel!
	@IBOutlet weak var horizontalProgressView: HorizontalProgressBar!
//	@IBOutlet weak var progressView: UIView!
	@IBOutlet weak var diskIInfoStackView: UIStackView!
	@IBOutlet weak var diskSpaceImageView: UIImageView!
	@IBOutlet weak var mediaSpaceTitleTextLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	
		self.configure()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.commonInit()
	}
		
	private func commonInit() {
	
		U.mainBundle.loadNibNamed(C.identifiers.xibs.infoSpaceView, owner: self, options: nil)
	}
	
	private func configure() {
		
		horizontalProgressView.progress = 0
		horizontalProgressView.setNeedsDisplay()
		horizontalProgressView.progressColor = theme.progressBackgroundColor
		
		diskSpaceImageView.image = Images.systemItems.defaultItems.diskSpaceDark
		
		switch Screen.size {
			case .small:
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 10, weight: .medium).monospacedDigitFont
			case .medium:
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 13, weight: .medium).monospacedDigitFont
			default:
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 14, weight: .medium).monospacedDigitFont
		}
		
		mediaSpaceTitleTextLabel .textColor = theme.titleTextColor
	}
	
	public func handleSpace(_ value: Int64?) {
		mediaSpaceTitleTextLabel.text  = String("\(Utils.getSpaceFromInt(value ?? 0))")
	}
	
	public func handleProgress(_ value: CGFloat) {
		self.horizontalProgressView.progress = value / 100
		self.horizontalProgressView.layoutIfNeeded()
	}
	
	
	public func resetProgress() {
		self.horizontalProgressView.resetProgressLayer()
	}
	
	private func completedProgress() {
		self.horizontalProgressView.progress = 0
		self.horizontalProgressView.layoutIfNeeded()
		self.resetProgress()
	}
	
	public func handleState(_ state: SpaceScaningState) {
		
//		guard self.diskIInfoStackView != nil, progressView != nil else { return }
				
//		switch state {
//			case .awake:
//				self.diskIInfoStackView.isHidden = false
//				self.horizontalProgressView.isHidden = true
//			case .scaning:
//				self.horizontalProgressView.isHidden = false
//			case .complete:
//				self.horizontalProgressView.isHidden = true
//				self.diskIInfoStackView.isHidden = false
//				self.completedProgress()
//		}
	}
}



