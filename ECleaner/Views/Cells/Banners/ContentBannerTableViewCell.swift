//
//  ContentBannerTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.05.2022.
//

import UIKit

class ContentBannerTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseShadeoRoundedView: ReuseShadowRoundedView!
	@IBOutlet weak var titleContainerStackView: UIStackView!
	@IBOutlet weak var descriptionContainerStackView: UIStackView!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	@IBOutlet weak var descriptionTitleTextLabel: UILabel!
	@IBOutlet weak var descriptionSubtitleTextLabel: UILabel!
	@IBOutlet var descriptionTextLabelsCollection: [UILabel]!
	@IBOutlet weak var reuseShadowViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var helperImageViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var helperImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var helperImageViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var helperImageViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var helperImageView: UIImageView!

	override func awakeFromNib() {
        super.awakeFromNib()
		
		setupUI()
		updateColors()
    }
}

extension ContentBannerTableViewCell {
	
	public func configure(by content: PhotoMediaType) {
		
		let info = content.bannerInfo.info[content]!
		/// `title labels`
		let gradientColors = info.gradientColors.compactMap({$0.cgColor})

		let gradientLayer = Utils.Manager.getGradientLayer(bounds: descriptionSubtitleTextLabel.bounds,
																colors: gradientColors,
																startPoint: .topLeft, endPoint: .bottomRight)
		let gradientColor = Utils.Manager.gradientColor(bounds: descriptionSubtitleTextLabel.bounds, gradientLayer: gradientLayer)
		let firstSubtitleAttributes: [NSAttributedString.Key : Any] = [.font: FontManager.bannerFont(of: .descriptionFirstTitle),
																	   .foregroundColor: gradientColor!]
		let secondSubtitleAttributes: [NSAttributedString.Key : Any] = [.font: FontManager.bannerFont(of: .descriptionSecontTitle),
																		.foregroundColor: gradientColor!]
		let attributedString = NSMutableAttributedString(string: info.descriptionFirstPartSubtitle, attributes: firstSubtitleAttributes)
		attributedString.append(NSAttributedString(string: " ", attributes: secondSubtitleAttributes))
		attributedString.append(NSAttributedString(string: info.descriptionSecondPartSubtitle, attributes: secondSubtitleAttributes))
		
		descriptionSubtitleTextLabel.attributedText = attributedString
		
		var titleGradientStartPoint: CAGradientPoint {
			switch content {
				case .locationPhoto:
					return .topCenter
				case .compress:
					return .topLeft
				case .backup:
					return .topLeft
				default:
					return .topLeft
					
			}
		}
		
		var titleGradientEndPoint: CAGradientPoint {
			switch content {
				case .locationPhoto:
					return .bottomCenter
				case .compress:
					return .bottomRight
				case .backup:
					return .bottomRight
				default:
					return .bottomRight
					
			}
		}
		
		let gradientLayerTitle = Utils.Manager.getGradientLayer(bounds: descriptionTitleTextLabel.bounds,
																colors: gradientColors,
																startPoint: titleGradientStartPoint, endPoint: titleGradientEndPoint)
		let gradientTitleColor = Utils.Manager.gradientColor(bounds: descriptionTitleTextLabel.bounds, gradientLayer: gradientLayerTitle)
		descriptionTitleTextLabel.textColor = gradientTitleColor
		titleTextLabel.text = info.title
		subtitleTextLabel.text = info.subtitle
		descriptionTitleTextLabel.text = info.descriptionTitle
		descriptionTextLabelsCollection.forEach {
			$0.layer.applyShadow(color: theme.bottomShadowColor, alpha: 0.6, x: 6, y: 6, blur: 12, spread: 0)
		}
		
		/// `rounded view`
		
		let roundedViewSize = AppDimensions.HelperBanner.roundedImageViewSize
		reuseShadowViewWidthConstraint.constant = roundedViewSize
		let defaultSize = CGSize(width: roundedViewSize * 0.4, height: roundedViewSize * 0.4)
		let imageSize = info.infoImage.getPreservingAspectRationScaleImageSize(from: defaultSize)
		reuseShadeoRoundedView.layoutIfNeeded()
		reuseShadeoRoundedView.setImageWithCustomBackground(image: info.infoImage,
															tineColor: theme.activeTitleTextColor,
															size: imageSize,
															colors: info.gradientColors,
															startPoint: .topCenter,
															endPoint: .bottomCenter)
		helperImageView.image = info.helperImage
		helperImageView.contentMode = .scaleToFill
		
		switch content {
			case .locationPhoto:
				setHelperImageSize(from: AppDimensions.HelperBanner.offsetHelperImageSize, of: info.helperImage)
				helperImageViewTrailingConstraint.constant = 25
				helperImageViewBottomConstraint.constant = -10
			case .compress:
				setHelperImageSize(from: AppDimensions.HelperBanner.cornerHelperImageSize, of: info.helperImage)
				helperImageViewTrailingConstraint.constant = 0
			case .backup:
				setHelperImageSize(from: AppDimensions.HelperBanner.offsetHelperImageSize, of: info.helperImage)
				helperImageViewTrailingConstraint.constant = 15
			default:
				return
		}
	}
	
	private func setHelperImageSize(from target: CGFloat, of image: UIImage) {
		
		let targetSize = CGSize(width: target, height: target)
		let helperImageSize = image.getPreservingAspectRationScaleImageSize(from: targetSize)
		helperImageViewWidthConstraint.constant = helperImageSize.width
		helperImageViewHeightConstraint.constant = helperImageSize.height
	}
}

extension ContentBannerTableViewCell: Themeble {
	
	private func setupUI() {
		
		selectionStyle = .none
		baseView.setCorner(14)
		titleTextLabel.textAlignment = .left
		subtitleTextLabel.textAlignment = .left
		descriptionTitleTextLabel.textAlignment = .right
		descriptionSubtitleTextLabel.textAlignment = .right
		titleTextLabel.font = FontManager.bannerFont(of: .title)
		subtitleTextLabel.font = FontManager.bannerFont(of: .subititle)
		descriptionTitleTextLabel.font = FontManager.bannerFont(of: .descriptionTitle)
	}

	func updateColors() {
		
		baseView.backgroundColor = .clear
		reuseShadeoRoundedView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.subTitleTextColor
	}
}
