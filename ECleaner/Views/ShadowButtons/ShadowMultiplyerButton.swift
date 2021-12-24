//
//  ShadowMultiplyerButton.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.12.2021.
//

import Foundation
import UIKit

class ShadowMultiplyerButton: UIButton {
	
	let helperRightView = UIView()
	let helperTextLabel = UILabel()
	var topShadowView = UIView()
	
	public var viewShadowOffsetOriginX: CGFloat = 3
	public var viewShadowOffsetOriginY: CGFloat = 3
	
	public var topShadowOffsetOriginX: CGFloat = -2
	public var topShadowOffsetOriginY: CGFloat = -2
	public var topBlurValue: CGFloat = 10
	public var topAlpha: Float = 0.9
	public var shadowBlurValue: CGFloat = 10
	
	public var sideHelperSize: CGSize = CGSize(width: 20, height: 20)
	public var helperRightSpacing: CGFloat = 10
	public var contentType: MediaContentType = .none
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.removeCornersSublayers()
		setupViews()
		initialize()
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

		self.addSubview(helperRightView)
		helperRightView.translatesAutoresizingMaskIntoConstraints = false
		
		titleEdgeInsets.right += sideHelperSize.width
		helperRightView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: helperRightSpacing).isActive = true
		helperRightView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -helperRightSpacing).isActive = true
		helperRightView.widthAnchor.constraint(equalToConstant: sideHelperSize.width).isActive = true
		helperRightView.heightAnchor.constraint(equalToConstant: sideHelperSize.height).isActive = true
		helperRightView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
		
		helperRightView.addSubview(helperTextLabel)
		helperTextLabel.translatesAutoresizingMaskIntoConstraints = false
		
		helperTextLabel.leadingAnchor.constraint(equalTo: helperRightView.leadingAnchor, constant: 0).isActive = true
		helperTextLabel.trailingAnchor.constraint(equalTo: helperRightView.trailingAnchor, constant: 0).isActive = true
		helperTextLabel.topAnchor.constraint(equalTo: helperRightView.topAnchor, constant: 0).isActive = true
		helperTextLabel.bottomAnchor.constraint(equalTo: helperRightView.bottomAnchor, constant: 0).isActive = true
		
		if let label = self.titleLabel {
			self.bringSubviewToFront(label)
		}
		helperTextLabel.layoutIfNeeded()
		helperRightView.layoutIfNeeded()
		
		let roundedGradientMask: CAGradientLayer = CAGradientLayer()
		roundedGradientMask.frame = CGRect(x: 0, y: 0, width: helperRightView.frame.width, height: helperRightView.frame.height)
		roundedGradientMask.colors = contentType.screeAcentGradientColorSet
		roundedGradientMask.startPoint = CGPoint(x: 0.0, y: 0.0)
		roundedGradientMask.endPoint = CGPoint(x: 0.0, y: 1.0)
		
		helperRightView.layer.addSublayer(roundedGradientMask)
		helperRightView.bringSubviewToFront(helperTextLabel)
		helperRightView.rounded()
		self.bringSubviewToFront(helperRightView)
	}
	
	public func setMainButton(text: String, with color: UIColor, tintColor: UIColor) {
		
		self.titleLabel?.font = .systemFont(ofSize: 12, weight: .black)
		self.setTitle(text, for: .normal)
		self.sizeToFit()
		helperTextLabel.textColor = tintColor
	}
	
	public func setHelperText(_ text: String?) {
		
		helperTextLabel.text = text
		helperTextLabel.textAlignment = .center
		helperTextLabel.font = .systemFont(ofSize: 10, weight: .black)
	}
	
	public func updateColors() {
	
		self.setTitleColor(contentType.screenAcentTintColor, for: .normal)
		self.helperTextLabel.textColor = theme.primaryButtonBackgroundColor
	}
 }
