//
//  DeepCleanInfoTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import UIKit

class DeepCleanInfoTableViewCell: UITableViewCell {
    
	@IBOutlet weak var infoTitleTextLabel: UILabel!
	@IBOutlet weak var infoTotalFilesTextLabel: UILabel!
    @IBOutlet weak var infoTotalFilesTitleLabel: UILabel!
    @IBOutlet weak var totalSpaceTextLabel: UILabel!
    @IBOutlet weak var totalSpaceTitleLabel: UILabel!
    @IBOutlet weak var progressContainerView: UIView!
	@IBOutlet weak var progressContainerViewHeighConstraint: NSLayoutConstraint!
	@IBOutlet weak var containerLeadingContstraint: NSLayoutConstraint!
	@IBOutlet weak var circleProgressView: CircleProgressView!
	@IBOutlet var titleLabelCollection: [UILabel]!
		
	private var containerLeading: CGFloat {
		switch Screen.size {
			case .small:
				return 20
			case .medium, .plus, .large:
				return 35
			case .modern:
				return 40
			case .max:
				return 40
			case .madMax:
				return 40
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		circleProgressView.setProgress(progress: 0.0, animated: false)
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
		circleProgressView.setProgress(progress: 0.0, animated: false)
    }
}

extension DeepCleanInfoTableViewCell {
    
    func setProgress(files count: Int) {
	
        infoTotalFilesTextLabel.text = String(count)
    }
	
	func setMemmoryChecker(bytes value: Int64) {
		
		if value == 0 {
			totalSpaceTextLabel.text = "0 MB"
		} else {
			totalSpaceTextLabel.setTitleWithoutAnimation(title: U.getSpaceFromInt(value))
		}
	}
	
	func setRoundedProgress(value: CGFloat) {
		circleProgressView.setProgress(progress: value / 100, animated: false)
    }
}

extension DeepCleanInfoTableViewCell: Themeble {
    
    func setupUI() {
		
		containerLeadingContstraint.constant = containerLeading
		progressContainerViewHeighConstraint.constant = U.UIHelper.AppDimensions.circleProgressInfoDimension
		
		let startPoint = CGPoint(x: 0.0, y: 0.0)
		let endPoint = CGPoint(x: 1.0, y: 0.0)
		circleProgressView.gradientSetup(startPoint: startPoint, endPoint: endPoint, gradientType: .axial)

		circleProgressView.disableBackgrounShadow = false
		circleProgressView.titleLabelTextAligement = .center
		circleProgressView.orientation = .bottom
		circleProgressView.titleLabelsPercentPosition = .centered
		circleProgressView.lineCap = .round
		circleProgressView.clockwise = true
		circleProgressView.percentLabelFormat = "%.f%%"
		circleProgressView.percentLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanCircleProgressPercentLabelFont
		circleProgressView.lineWidth = U.UIHelper.AppDimensions.circleProgressInfoLineWidth
		
		infoTitleTextLabel.text = "All Data Analized"
		infoTotalFilesTitleLabel.text = "FILES".uppercased()
		totalSpaceTitleLabel.text = "Memmory".uppercased()
		
		infoTitleTextLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanInfoHelperTitleFont.monospacedDigitFont
		totalSpaceTextLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanInfoHelperTitleFont.monospacedDigitFont
		infoTotalFilesTextLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanInfoHelperTitleFont.monospacedDigitFont
		infoTotalFilesTitleLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanInfoHelperSubtitleFont.monospacedDigitFont
		totalSpaceTitleLabel.font = U.UIHelper.AppDefaultFontSize.deepCleanInfoHelperSubtitleFont.monospacedDigitFont
    }
    
    func updateColors() {
		
		titleLabelCollection.forEach {
			$0.textAlignment = .center
		}
		
		infoTitleTextLabel.textColor = theme.titleTextColor
        infoTotalFilesTextLabel.textColor = theme.titleTextColor
        infoTotalFilesTitleLabel.textColor = theme.subTitleTextColor
        totalSpaceTextLabel.textColor = theme.titleTextColor
        totalSpaceTitleLabel.textColor = theme.subTitleTextColor
						
		circleProgressView.progressShapeColor = theme.tintColor
		circleProgressView.backgroundShapeColor = theme.topShadowColor.withAlphaComponent(0.2)
		circleProgressView.startColor = theme.circleStarterGradientColor
		circleProgressView.endColor = theme.circleEndingGradientColor
		circleProgressView.backgroundShadowColor = theme.bottomShadowColor
		
		let titleLabelBounds = circleProgressView.percentLabel.bounds
		let titleGradient = U.UIHelper.Manager.getGradientLayer(bounds: titleLabelBounds, colors: theme.titleCircleGradientTitleColorSet)
		let color = U.UIHelper.Manager.gradientColor(bounds: titleLabelBounds, gradientLayer: titleGradient)
		circleProgressView.percentColor = color ?? theme.titleTextColor
    }
}
