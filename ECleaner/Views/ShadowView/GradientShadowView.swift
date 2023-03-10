//
//  GradientShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import UIKit


class GradientShadowView: UIView {
	
	private let topLayer = CALayer()
	private let bottomLayer = CALayer()
	public let helperImageView = UIImageView()
	
	public var topShadowColor: UIColor = .red
	public var bottomShadowColor: UIColor = .black
	public var templateTintColor: UIColor = .orange
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		setupShadowViews()
		setupView()
	}
		
	public func setShadowColor(for topShadow: UIColor, and bottomShadow: UIColor) {
		topShadowColor = topShadow
		bottomShadowColor = bottomShadow
	}
	
	private func setupView() {

		self.backgroundColor = .clear
	}

	public func setImageWithCustomBackground(image: UIImage, tintColor: UIColor, size: CGSize, colors: [UIColor], imageViewSize: CGSize? = nil) {
		
		helperImageView.image = image
		helperImageView.tintColor = tintColor
		helperImageView.contentMode = .scaleToFill
		self.addSubview(helperImageView)
		helperImageView.translatesAutoresizingMaskIntoConstraints = false
		helperImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		helperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		if let imageViewSize = imageViewSize {
			helperImageView.heightAnchor.constraint(equalToConstant: imageViewSize.height).isActive = true
			helperImageView.widthAnchor.constraint(equalToConstant: imageViewSize.width).isActive = true
		} else {
			helperImageView.heightAnchor.constraint(equalToConstant: size.width).isActive = true
			helperImageView.widthAnchor.constraint(equalToConstant: size.height).isActive = true
		}

		self.layoutIfNeeded()
		let gradientColors = colors.compactMap({$0.cgColor})
		let gradientBaseView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
		gradientBaseView.setCorner(8)
		self.insertSubview(gradientBaseView, belowSubview: helperImageView)
		gradientBaseView.translatesAutoresizingMaskIntoConstraints = false
		gradientBaseView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		gradientBaseView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		gradientBaseView.widthAnchor.constraint(equalToConstant: size.width * 2).isActive = true
		gradientBaseView.heightAnchor.constraint(equalToConstant: size.height * 2).isActive = true
		gradientBaseView.layoutIfNeeded()
		gradientBaseView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colors: gradientColors , type: .axial)
	}
		
	public func updateImagesLayout() {
		helperImageView.setNeedsUpdateConstraints()
		helperImageView.layoutIfNeeded()
	}
	
	private func setupShadowViews() {
		
		[topLayer, bottomLayer].forEach {
			$0.frame = layer.bounds
			layer.insertSublayer($0, at: 0)
		}
		
		topLayer.setRoundedShadow(with: topShadowColor, size: CGSize(width: -1, height: -1), alpha: 1.0, radius: 6)
		bottomLayer.setRoundedShadow(with: bottomShadowColor, size: CGSize(width: 1, height: 1), alpha: 1.0, radius: 6)
	}
}
