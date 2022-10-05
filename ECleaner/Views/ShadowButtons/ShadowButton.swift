//
//  ShadowButton.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.12.2021.
//

import UIKit

class ShadowButton: UIButton {
	
	let buttonImageView = UIImageView()
	
	var topShadowView = UIView()
	
	public var viewShadowOffsetOriginX: CGFloat = 3
	public var viewShadowOffsetOriginY: CGFloat = 3
	
	public var topShadowOffsetOriginX: CGFloat = -2
	public var topShadowOffsetOriginY: CGFloat = -2
	public var topBlurValue: CGFloat = 10
	public var topAlpha: Float = 0.9
	public var shadowBlurValue: CGFloat = 10
	
	public var imageViewSize: CGSize = CGSize(width: 18, height: 18)
	public var contentType: MediaContentType = .none
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.removeCornersSublayers()
		setupViews()
		initialize()
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
	}
	
	public func initialize() {

		self.addSubview(buttonImageView)
		buttonImageView.translatesAutoresizingMaskIntoConstraints = false
		
		buttonImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		buttonImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		buttonImageView.widthAnchor.constraint(equalToConstant: imageViewSize.width).isActive = true
		buttonImageView.heightAnchor.constraint(equalToConstant: imageViewSize.height).isActive = true
		
		self.bringSubviewToFront(buttonImageView)
	}
	
	public func setImage(_ image: UIImage, enabled: Bool) {
	
		let colors = contentType.screeAcentGradientColorSet
		let disableColors = [UIColor().colorFromHexString("DDDDDD").cgColor, UIColor().colorFromHexString("989898").cgColor]
		
		buttonImageView.image = image.tintedWithLinearGradientColors(colorsArr: enabled ? colors.reversed() : disableColors)

	}
	
	public func updateColors() {
		
		
		
	}
 }

