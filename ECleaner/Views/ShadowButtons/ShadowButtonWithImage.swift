//
//  ShadowButtonWithImage.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.12.2021.
//

import UIKit

class ShadowButtonWithImage: UIButton {
	
	var buttonImageView = UIImageView()
	var topShadowView = UIView()
	
	public var viewShadowOffsetOriginX: CGFloat = 3
	public var viewShadowOffsetOriginY: CGFloat = 3
	
	public var topShadowOffsetOriginX: CGFloat = -2
	public var topShadowOffsetOriginY: CGFloat = -2
	public var topBlurValue: CGFloat = 10
	public var topAlpha: Float = 0.9
	public var shadowBlurValue: CGFloat = 10
	
	public var buttonImageSize: CGSize = CGSize(width: 20, height: 24)
	public var helperRightSpacing: CGFloat = 5
	public var contentType: MediaContentType = .none
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.removeCornersSublayers()
		setupViews()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		self.sendActions(for: UIControl.Event.touchUpInside)
	}
	
	private func setupViews() {
		
		let cellBackgroundColor: UIColor = theme.primaryButtonBackgroundColor
		let topShadowColor: UIColor = theme.topShadowColor
		let cellShadowColor: UIColor = theme.sideShadowColor
		
		self.backgroundColor = .clear
		
		self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor,
											 shadow: cellShadowColor,
											 alpha: 1, x: viewShadowOffsetOriginX,
											 y: viewShadowOffsetOriginY,
											 blur: shadowBlurValue,
											 corners: [.allCorners],
											 radius: 5)
		
		topShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.insertSubview(topShadowView, at: 0)
		self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear,
														   shadow: topShadowColor,
														   alpha: topAlpha,
														   x: topShadowOffsetOriginX,
														   y: topShadowOffsetOriginY,
														   blur: topBlurValue,
														   corners: [],
														   radius: 5)
		
		self.addSubview(buttonImageView)
		buttonImageView.translatesAutoresizingMaskIntoConstraints = false
		
		buttonImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -helperRightSpacing).isActive = true
		self.titleEdgeInsets.right += buttonImageSize.width
		buttonImageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: helperRightSpacing).isActive = true
		buttonImageView.widthAnchor.constraint(equalToConstant: buttonImageSize.width).isActive = true
		buttonImageView.heightAnchor.constraint(equalToConstant: buttonImageSize.height).isActive = true
		buttonImageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor).isActive = true
		
		if let buttonTiteTextLabel = self.titleLabel {
			self.bringSubviewToFront(buttonTiteTextLabel)
		}
		
		self.bringSubviewToFront(buttonImageView)
	}
	
	
	public func setMainButton(text: String, image: UIImage) {
		
		buttonImageView.image = image	
		self.setTitle(text, for: .normal)
		self.sizeToFit()
	}
	
	public func setButtonFont(_ uiFont: UIFont?) {
		if let font = uiFont {
			self.titleLabel?.font = font
		} else {
			self.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
		}
	}
	
	
	public func updateColors(for enabled: Bool) {
		let colors = contentType.screeAcentGradientColorSet
		let disableColors = [UIColor().colorFromHexString("DDDDDD").cgColor, UIColor().colorFromHexString("989898").cgColor]
		
		let gradient = U.UIHelper.Manager.getGradientLayer(bounds: self.bounds, colors: enabled ? colors: disableColors.reversed())
		self.setTitleColor(U.UIHelper.Manager.gradientColor(bounds: self.bounds, gradientLayer: gradient), for: .normal)
		
		if let image = buttonImageView.image {
			buttonImageView.image = image.tintedWithLinearGradientColors(colorsArr: enabled ? colors.reversed() : disableColors)
		}
	}
}


