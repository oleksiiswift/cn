//
//  GradientShadowedImageView.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.09.2022.
//

import UIKit

class GradientShadowedImageView: UIView {
	
	private var imageView = UIImageView()
	private var helperBackgroundView = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInit()
		self.updateColors()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.commonInit()
		self.updateColors()
	}
	
	private func commonInit() {
		
		let helperOffset: CGFloat = 6
		self.addSubview(helperBackgroundView)
		helperBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		helperBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: helperOffset).isActive = true
		helperBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -helperOffset).isActive = true
		helperBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: helperOffset).isActive = true
		helperBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -helperOffset).isActive = true
	
		self.backgroundColor = .clear
		self.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false

	}

	public func setThumbnail(model: PremiumFeature) {
		helperBackgroundView.isHidden = true//!model.helperBackroundNeeded
		
		let imageSize = model.thumbnail.getPreservingAspectRationScaleImageSize(from: self.frame.size)
		
		let shadowImage = UIImageView()


		self.insertSubview(shadowImage, at: 0)
		shadowImage.translatesAutoresizingMaskIntoConstraints = false
		shadowImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		shadowImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		shadowImage.heightAnchor.constraint(equalToConstant: imageSize.height - 3).isActive = true
		shadowImage.widthAnchor.constraint(equalToConstant: imageSize.width - 3).isActive = true
		shadowImage.layoutIfNeeded()
		
		let image = model.thumbnail.withTintColor(.lightGray)
		let blured = image.blur(radius: 12)
		shadowImage.tintColor = .black.withAlphaComponent(0.5)
		shadowImage.image = blured//model.thumbnail.withTintColor(.black.withAlphaComponent(0.5)).blur(radius: 6)
	
		
		

		let gradientedImage = UIImageEffects.imageByApplyingLightEffect(to: model.thumbnail)
//		model.thumbnail.tintedGradient(colors: model.thumbnailColors.compactMap({$0.cgColor}), start: .topLeft, end: .bottomRight)
//		imageView.image = gradientedImage//.setShadow(blur: 6, offset: CGSize(width: 3, height: 3), color: theme.bottomShadowColor, alpha: 0.8)
		shadowImage.image = gradientedImage
		
		
		
		imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		imageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
		imageView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
		
//
	}
	

	
	private func updateColors() {
		
		helperBackgroundView.backgroundColor = .white
		self.backgroundColor = .clear
	}
}


extension UIImage {
	/// Applies a gaussian blur to the image.
	///
	/// - Parameter radius: Blur radius.
	/// - Returns: A blurred image.
	func blur(radius: CGFloat = 6.0) -> UIImage? {
		let context = CIContext()
		guard let inputImage = CIImage(image: self) else { return nil }

		guard let clampFilter = CIFilter(name: "CIAffineClamp") else { return nil }
		clampFilter.setDefaults()
		clampFilter.setValue(inputImage, forKey: kCIInputImageKey)

		guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
		blurFilter.setDefaults()
		blurFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
		blurFilter.setValue(radius, forKey: kCIInputRadiusKey)

		guard let blurredImage = blurFilter.value(forKey: kCIOutputImageKey) as? CIImage,
			let cgImage = context.createCGImage(blurredImage, from: inputImage.extent) else { return nil }

		let resultImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
		return resultImage
	}
}
	
