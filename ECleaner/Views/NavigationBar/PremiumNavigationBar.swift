//
//  PremiumNavigationBar.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.07.2022.
//

import Foundation
import SwiftUI

enum AnimationStatus {
	case start
	case stop
}

enum NavigationButtonState {
	case notAvailible
	case imageWithoutTitle
	case titleWithoutImagge
	case imageWithTitle
}

class NavigationButton {
	
	var title: String?
	var image: UIImage?
	
	var state: NavigationButtonState
	
	init(title: String?, image: UIImage?) {
		self.title = title
		self.image = image
		
		if title == nil && image == nil {
			self.state = .notAvailible
		} else if title != nil && image != nil {
			self.state = .imageWithTitle
		} else if title == nil && image != nil {
			self.state = .imageWithoutTitle
		} else if title != nil && image == nil {
			self.state = .titleWithoutImagge
		} else {
			self.state = .notAvailible
		}
	}
}


class PremiumNavigationBar: UIView {
	
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var leftBarButton: PrimaryButton!
	@IBOutlet weak var rightBarButton: PrimaryButton!

	@IBOutlet weak var leftShadowView: ReuseShadowView!
	@IBOutlet weak var rightShadowView: ReuseShadowView!

	@IBOutlet weak var leftButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var leftButtonHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var rightButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var rightButtonHeightConstraint: NSLayoutConstraint!
	
	var delegate: PremiumNavigationBarDelegate?
	
	private var leftButtonSize: CGSize = AppDimensions.Subscription.Navigation.leftNavigationButton
	private var rightButtonSize: CGSize = AppDimensions.Subscription.Navigation.rightNavigationButton

	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.configure()
		self.actionButtonsSetup()
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
		
		U.mainBundle.loadNibNamed(C.identifiers.navigation.subscription, owner: self, options: nil)
	}
   
	private func configure() {
		
		setLeftButton(size: rightButtonSize)
		setRightButton(size: leftButtonSize)
		
		containerView.backgroundColor = .clear
		backgroundColor = .clear
		addSubview(self.containerView)
		containerView.frame = self.bounds
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		leftBarButton.primaryShadowsIsActive = false
		rightBarButton.primaryShadowsIsActive = false
		
		leftBarButton.clipsToBounds = true
		leftBarButton.layer.cornerRadius = 10
		
		rightBarButton.clipsToBounds = true
		rightBarButton.layer.cornerRadius = 10
		
		leftShadowView.topShadowOffsetOriginX = -2
		leftShadowView.topShadowOffsetOriginY = -5
		
		rightShadowView.topShadowOffsetOriginY = -2
		rightShadowView.topShadowOffsetOriginX = -5
	}

	public func setUpNavigation(lefTitle: String? = nil, leftImage: UIImage? = nil, rightTitle: String? = nil, rightImage: UIImage? = nil, targetImageScaleFactor: CGFloat = 0.5) {
		
		
		let targetLeftImageSize = CGSize(width: leftButtonSize.width * targetImageScaleFactor, height: leftButtonSize.height * targetImageScaleFactor)
		let targetRightImageSize = CGSize(width: rightButtonSize.width * targetImageScaleFactor, height: rightButtonSize.height * targetImageScaleFactor)
		
		var leftImageSize: CGSize {
			if let leftImage = leftImage {
				return leftImage.getPreservingAspectRationScaleImageSize(from: targetLeftImageSize)
			} else {
				return .zero
			}
		}
		
		var rightImageSzie: CGSize {
			if let rightImage = rightImage {
				return rightImage.getPreservingAspectRationScaleImageSize(from: targetRightImageSize)
			} else {
				return .zero
			}
		}
		
		let leftButton = NavigationButton(title: lefTitle, image: leftImage)
		let rightButton = NavigationButton(title: rightTitle, image: rightImage)
		
		switch leftButton.state {
				
			case .notAvailible:
				leftBarButton.isHidden = true
				leftShadowView.isHidden = true
			case .imageWithoutTitle:
				if let leftImage = leftImage {
					leftBarButton.addCenterImage(image: leftImage, imageWidth: leftImageSize.width, imageHeight: leftImageSize.height)
				}
			case .titleWithoutImagge:
				if let lefTitle = lefTitle {
					leftBarButton.setTitle(lefTitle, for: .normal)
				}
			case .imageWithTitle:
				if let image = leftImage, let title = lefTitle {
					leftBarButton.setTitle(title, for: .normal)
					leftBarButton.addRightImage(image: image, size: leftImageSize, spacing: 5)
				}
		}
		
		switch rightButton.state {
				
			case .notAvailible:
				rightBarButton.isHidden = true
				rightShadowView.isHidden = true
			case .imageWithoutTitle:
				if let rightImage = rightImage {
					rightBarButton.addCenterImage(image: rightImage, imageWidth: rightImageSzie.width, imageHeight: rightImageSzie.height)
				}
			case .titleWithoutImagge:
				if let rightTitle = rightTitle {
					rightBarButton.setTitle(rightTitle, for: .normal)
				}
			case .imageWithTitle:
				if let image = rightImage, let title = rightTitle {
					rightBarButton.setTitle(title, for: .normal)
					rightBarButton.addRightImage(image: image, size: rightImageSzie, spacing: 12)
				}
		}
	}
	
	public func configureLeftButtonAppearance(tintColor: UIColor, textColor: UIColor? = nil, font: UIFont? = nil) {
		leftBarButton.tintColor = tintColor
		leftBarButton.setTitleColor(textColor, for: .normal)
		leftBarButton.titleLabel?.font = font
	}
	
	public func configureRightButtonAppearance(tintColor: UIColor, textColor: UIColor? = nil, font: UIFont? = nil) {
		rightBarButton.tintColor = tintColor
		rightBarButton.setTitleColor(textColor, for: .normal)
		rightBarButton.titleLabel?.font = font
	}

	public func setLeftButton(size: CGSize) {
		leftButtonWidthConstraint.constant = size.width
		leftButtonHeightConstraint.constant = size.height
	}
	
	public func setRightButton(size: CGSize) {
		rightButtonWidthConstraint.constant = size.width
		rightButtonHeightConstraint.constant = size.height
	}
	
	private func actionButtonsSetup() {
		
		leftBarButton.addTarget(self, action: #selector(didTapLeftBarButton(sender:)), for: .touchUpInside)
		rightBarButton.addTarget(self, action: #selector(didTapRightBarButton(sender:)), for: .touchUpInside)
	}
	
	@objc func didTapLeftBarButton(sender: UIButton) {
		self.leftBarButton.animateButtonTransform()
		delegate?.didTapLeftBarButton(sender)
	}
	
	@objc func didTapRightBarButton(sender: UIButton) {
		self.rightBarButton.animateButtonTransform()
		delegate?.didTapRightBarButton(sender)
	}
}


extension PremiumNavigationBar {
	
	public func setLeftButton(animation: AnimationStatus) {
		
		Utils.UI {
			switch animation {
				case .start:
					self.leftBarButton.animateProgress()
				case .stop:
					self.leftBarButton.removeAnimateProgress()
			}
		}
	}
	
	public func setRightButton(animation: AnimationStatus) {
		Utils.UI {
			switch animation {
				case .start:
					self.rightBarButton.animateProgress()
				case .stop:
					self.rightBarButton.removeAnimateProgress()
			}
		}
	}
}
