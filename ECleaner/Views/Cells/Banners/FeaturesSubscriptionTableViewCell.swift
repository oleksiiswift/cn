//
//  FeaturesSubscriptionTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.07.2022.
//

import UIKit

class FeaturesSubscriptionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var stackContainerView: UIView!
	@IBOutlet weak var titleContainerView: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
    }
}

extension FeaturesSubscriptionTableViewCell {
	
	public func featuresConfigure(features: [PremiumFeature]) {
		
		var featuresViews: [PremiumFeatureView] = []
		
		for feature in features {
			let featureView = PremiumFeatureView()
			featureView.configureView(from: feature, isSettingsSize: true)
			featuresViews.append(featureView)
		}
		
		let stackView = UIStackView(arrangedSubviews: featuresViews)
		stackView.frame = self.bounds
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.stackContainerView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: self.stackContainerView.topAnchor, constant: 10).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.stackContainerView.bottomAnchor, constant: -10).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.stackContainerView.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.stackContainerView.trailingAnchor).isActive = true
	}
	
	private func setupUI() {
		
		selectionStyle = .none
		
		let titleTextLabel = UILabel()
		let subtitleTextLabel = UILabel()
		
		titleTextLabel.textAlignment = .right
		subtitleTextLabel.textAlignment = .right
		
		
		let stackView = UIStackView(arrangedSubviews: [UILabel(), subtitleTextLabel, titleTextLabel])
		stackView.frame = self.bounds
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.stackContainerView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: self.titleContainerView.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.titleContainerView.bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.titleContainerView.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.titleContainerView.trailingAnchor, constant: -20).isActive = true
		
		stackView.layoutIfNeeded()
				
		let subtitle = Localization.Subscription.Main.unlockFeatures
		let title = Localization.Subscription.Main.withPremium
		let stringComponent: [String?] = title.components(separatedBy: " ")
		
		if let preTitle = stringComponent[0], let mainTitle = stringComponent[1] {
			let subTitleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: theme.titleTextColor]
			let mutableAttributedString: NSMutableAttributedString = .init(string: subtitle, attributes: subTitleAttributes)
			subtitleTextLabel.attributedText = mutableAttributedString
			
			let colors = theme.premiumCrownGradientColor.compactMap({$0.cgColor})
			let preTitleGradientLayer = Utils.Manager.getGradientLayer(bounds: titleTextLabel.bounds, colors: colors, startPoint: .topLeft, endPoint: .bottomRight)
			let preTitleGradientColor = Utils.Manager.gradientColor(bounds: titleTextLabel.bounds, gradientLayer: preTitleGradientLayer)
			let preTitleAttrributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .bold), .foregroundColor: preTitleGradientColor!]
			let preTitleAttributedString: NSMutableAttributedString = .init(string: preTitle + " ", attributes: preTitleAttrributes)
			
			
			let titleGradientLayer = Utils.Manager.getGradientLayer(bounds: titleTextLabel.bounds, colors: colors, startPoint: .topLeft, endPoint: .bottomRight)
			let titleGradientColor = Utils.Manager.gradientColor(bounds: titleTextLabel.bounds, gradientLayer: titleGradientLayer)
			let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22, weight: .bold), .foregroundColor: titleGradientColor!]
			let titleAtributedString: NSMutableAttributedString = .init(string: mainTitle, attributes: titleAttributes)
			
			preTitleAttributedString.append(titleAtributedString)
			titleTextLabel.attributedText = preTitleAttributedString
		}
		
		let imageView = UIImageView(image: Images.subsctiption.colorRocket)
		
		self.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60).isActive = true
		imageView.topAnchor.constraint(equalTo: self.titleContainerView.bottomAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		imageView.widthAnchor.constraint(equalToConstant: self.frame.height / 2).isActive = true
	}
}
