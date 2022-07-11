//
//  CurrentSubscriptionTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 07.07.2022.
//

import UIKit

protocol CurrentSubscriptionChangeDelegate {
	func didTapChangeSubscription()
}

class CurrentSubscriptionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var thumbnailView: GradientShadowView!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var thumnailHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionButton: GradientButton!
	
	var delegate: CurrentSubscriptionChangeDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		setupTitle()
		updateColors()
    }
	
	@IBAction func didTapActionButton(_ sender: Any) {
		delegate?.didTapChangeSubscription()
	}
}

extension CurrentSubscriptionTableViewCell {
	
	public func configure(model: CurrentSubscriptionModel) {
	
		if model.expireDate.isEmpty {
			if SettingsManager.subscripton.currentSubscriptionName == Subscriptions.lifeTime.rawValue {
				setupExpireDateSubtitle(with: Localization.Settings.Title.lifeTime)
			}
		} else {
			setupExpireDateSubtitle(with: model.expireDate)
		}
	}
}

extension CurrentSubscriptionTableViewCell: Themeble {
	
	private func setupUI() {
		
		self.selectionStyle = .none
		
		setupExpireDateSubtitle(with: SettingsManager.subscripton.currentExprireSubscriptionDate)
		
		thumbnailView.layoutIfNeeded()
		thumbnailView.setImageWithCustomBackground(image: Images.subsctiption.crown!,
												   tintColor: .white,
												   size: CGSize(width: thumbnailView.frame.height / 2,
																height: thumbnailView.frame.height / 2),
												   colors: theme.premiumCrownGradientColor)
		
		actionButton.buttonTitle = LocalizationService.Buttons.getButtonTitle(of: .changePlan)
		actionButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
		actionButton.buttonImage = I.systemItems.defaultItems.refresh
		actionButton.primaryShadowsIsActive = false
		actionButton.setupGradientActive = true
		actionButton.gradientColors = theme.changeSubscriptionbuttonGradientColors
	}
	
	private func setupTitle() {
		
		guard titleLabel.bounds != .zero else { return }
		
		let titleString = Localization.Subscription.Premium.alreadyPremium.components(separatedBy: " ")
		let firstPartTitle = titleString.first
		let secondPartTitle = titleString.last
		let colors = theme.bunneTitleGradienColors.compactMap({$0.cgColor})
		if let firstPartTitle = firstPartTitle, let secondPartTitle = secondPartTitle {
			let gradientLayer = Utils.Manager.getGradientLayer(bounds: titleLabel.bounds, colors: colors, startPoint: .topLeft, endPoint: .bottomRight)
			let gradientColors = Utils.Manager.gradientColor(bounds: titleLabel.bounds, gradientLayer: gradientLayer)
			let attributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .premimBannerTitle), .foregroundColor: gradientColors!]
			let partAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .premimBannerTitle), .foregroundColor: theme.titleTextColor]
			let attrubutedString: NSMutableAttributedString = .init(string: firstPartTitle, attributes: attributes)
			attrubutedString.append(NSAttributedString(string: " "))
			attrubutedString.append(NSAttributedString(string: secondPartTitle, attributes: partAttributes))
			titleLabel.attributedText = attrubutedString
		}
	}
	
	private func setupExpireDateSubtitle(with text: String) {
		
		let date = text.replacingOccurrences(of: "\\", with: "/")
		
		let dateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .premiumBannerDateSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		let expireDateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .permiumBannerSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		
		let attributedString = NSMutableAttributedString(string: Localization.Subscription.Premium.expireSubscription, attributes: expireDateAttributes)
		attributedString.append(NSAttributedString(string: " "))
		attributedString.append(NSAttributedString(string: date, attributes: dateAttributes))
		subtitleTextLabel.attributedText = attributedString
	}

	func updateColors() {
		actionButton.setTitleColor(theme.activeTitleTextColor, for: .normal)
		actionButton.buttonTintColor = theme.activeTitleTextColor
		thumbnailView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
	}
}




