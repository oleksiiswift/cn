//
//  PremiumFeaturesSubscriptionTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 07.07.2022.
//

import UIKit

class PremiumFeaturesSubscriptionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var titleStackContainerView: UIView!
	@IBOutlet weak var stackContainerView: UIView!
	
	private let leadingTitleLabel = UILabel()
	private let trailingTitleLabel = UILabel()
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		setupUI()
		setupBackroundImage()
    }
}

extension PremiumFeaturesSubscriptionTableViewCell {
		
	public func featuresConfigure(leadingFeatures: [PremiumFeature], trailingFeautures: [PremiumFeature]) {
		
		var leadingViews: [PremiumFeatureView] = []
		var trailingViews: [PremiumFeatureView] = []
		
		for feature in leadingFeatures {
			let featureView = PremiumFeatureView()
			featureView.configureView(from: feature)
			leadingViews.append(featureView)
		}
		
		for feature in trailingFeautures {
			let featureView = PremiumFeatureView()
			featureView.configureView(from: feature)
			trailingViews.append(featureView)
		}
		
		
		let leadingStackView = UIStackView(arrangedSubviews: leadingViews)
		leadingStackView.frame = self.bounds
		leadingStackView.axis = .vertical
		leadingStackView.alignment = .fill
		leadingStackView.distribution = .fillEqually
		
		self.stackContainerView.addSubview(leadingStackView)
		leadingStackView.translatesAutoresizingMaskIntoConstraints = false
		
		leadingStackView.topAnchor.constraint(equalTo: self.stackContainerView.topAnchor).isActive = true
		leadingStackView.bottomAnchor.constraint(equalTo: self.stackContainerView.bottomAnchor).isActive = true
		leadingStackView.leadingAnchor.constraint(equalTo: self.stackContainerView.leadingAnchor).isActive = true
		leadingStackView.trailingAnchor.constraint(equalTo: self.stackContainerView.centerXAnchor).isActive = true
		
		let trailingStackView = UIStackView(arrangedSubviews: trailingViews)
		trailingStackView.frame = self.bounds
		trailingStackView.axis = .vertical
		trailingStackView.alignment = .fill
		trailingStackView.distribution = .fillEqually
		
		self.stackContainerView.addSubview(trailingStackView)
		trailingStackView.translatesAutoresizingMaskIntoConstraints = false
		
		trailingStackView.topAnchor.constraint(equalTo: self.stackContainerView.topAnchor).isActive = true
		trailingStackView.bottomAnchor.constraint(equalTo: self.stackContainerView.bottomAnchor).isActive = true
		trailingStackView.trailingAnchor.constraint(equalTo: self.stackContainerView.trailingAnchor).isActive = true
		trailingStackView.leadingAnchor.constraint(equalTo: self.stackContainerView.centerXAnchor, constant: -10).isActive = true
	}
	
	private func setupUI() {

		selectionStyle = .none
		
		let stackView = UIStackView(arrangedSubviews: [leadingTitleLabel, trailingTitleLabel])
		
		stackView.frame = self.bounds
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		titleStackContainerView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: self.titleStackContainerView.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.titleStackContainerView.bottomAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.titleStackContainerView.trailingAnchor, constant: -25).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.titleStackContainerView.leadingAnchor, constant: 25).isActive = true
		
		stackView.layoutIfNeeded()
		leadingTitleLabel.layoutIfNeeded()
		trailingTitleLabel.layoutIfNeeded()
	
		leadingTitleLabel.textAlignment = .left
		leadingTitleLabel.numberOfLines = 2
		trailingTitleLabel.textAlignment = .right
		trailingTitleLabel.numberOfLines = 2
		
		let leadingTitle = Localization.Subscription.Main.getPremium.components(separatedBy: " ")
		
		if let topRow = leadingTitle.first, let bottomRow = leadingTitle.last {
			let colors = theme.premiumCrownGradientColor.compactMap({$0.cgColor})
			setCustomLabelText(topRow: topRow,
							   bottomRow: bottomRow,
							   firstRowColors: colors,
							   secondRowColor: theme.titleTextColor,
							   label: leadingTitleLabel,
							   topFont: FontManager.subscriptionFont(of: .premiumFeatureBannerTitle),
							   bottomFont: FontManager.subscriptionFont(of: .premiumFeatureBannerTitle))
		}
	
		let trailingTitle: [String?] = Localization.Subscription.Main.unlockFeatures.components(separatedBy: " ")

		if let topRowOne = trailingTitle[0], let topRowTwo = trailingTitle[1], let bottomRow = trailingTitle[2] {
			let topRow = topRowOne + " " + topRowTwo
			let colors = theme.premiumCrownGradientColor.compactMap({$0.cgColor})
			setCustomLabelText(topRow: topRow,
							   bottomRow: bottomRow,
							   firstRowColors: colors,
							   secondRowColor: theme.titleTextColor,
							   label: trailingTitleLabel,
							   topFont: FontManager.subscriptionFont(of: .premiumFeatureBannerSubtitleTitle),
							   bottomFont: FontManager.subscriptionFont(of: .premiumFeatureBannerSubtitle))
		}
	}
	
	private func setCustomLabelText(topRow: String, bottomRow: String, firstRowColors: [CGColor], secondRowColor: UIColor, label: UILabel, topFont: UIFont, bottomFont: UIFont) {
		
		let gradientLayer = Utils.Manager.getGradientLayer(bounds: leadingTitleLabel.bounds, colors: firstRowColors, startPoint: .topLeft, endPoint: .bottomRight)
		let gradientColors = Utils.Manager.gradientColor(bounds: leadingTitleLabel.bounds, gradientLayer: gradientLayer)
		let attributes: [NSAttributedString.Key: Any] = [.font: topFont, .foregroundColor: gradientColors!]
		let partAttributes: [NSAttributedString.Key: Any] = [.font: bottomFont, .foregroundColor: secondRowColor]
		let attrubutedString: NSMutableAttributedString = .init(string: topRow, attributes: attributes)
		attrubutedString.append(NSAttributedString(string: "\n"))
		attrubutedString.append(NSAttributedString(string: bottomRow, attributes: partAttributes))
		label.attributedText = attrubutedString
	}
	
	private func setupBackroundImage() {
		
		let imageViewContainerView = UIView()
		imageViewContainerView.setCorner(12)
		let image = Images.subsctiption.rocketPocket?.resize(withSize: CGSize(width: 350, height: 350), contentMode: .contentAspectFit)
		let rotateImage = image?.rotated(by: 15)
		let imageView = UIImageView(image: rotateImage)
		
		baseView.insertSubview(imageViewContainerView, at: 0)
		imageViewContainerView.translatesAutoresizingMaskIntoConstraints = false
		imageViewContainerView.topAnchor.constraint(equalTo: baseView.topAnchor).isActive = true
		imageViewContainerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0).isActive = true
		imageViewContainerView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
		imageViewContainerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor).isActive = true

		imageViewContainerView.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.leadingAnchor.constraint(equalTo: imageViewContainerView.leadingAnchor, constant: 0).isActive = true
		imageView.trailingAnchor.constraint(equalTo: imageViewContainerView.trailingAnchor, constant: 0).isActive = true
		imageView.topAnchor.constraint(equalTo: imageViewContainerView.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: imageViewContainerView.bottomAnchor).isActive = true
		
		imageView.clipsToBounds = true
		imageView.contentMode = .left
	}
}








