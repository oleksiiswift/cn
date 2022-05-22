//
//  ReuseShadowRoundedView.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.11.2021.
//

import UIKit

class ReuseShadowRoundedView: UIView {
    
    private let topLayer = CALayer()
    private let bottomLayer = CALayer()
    public let imageView = UIImageView()
	private let helperImageView = UIImageView()
    
    public var topShadowColor: UIColor = .red
    public var bottomShadowColor: UIColor = .black
    public var templateTintColor: UIColor = .orange
    
    private var activityIndicatorView = UIActivityIndicatorView()
	
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupShadowViews()
        setupView()
    }
	
    public func setImage(_ image: UIImage? = nil) {
        imageView.image = image
		setupImageView()
    }
	
    public func setShadowColor(for topShadow: UIColor, and bottomShadow: UIColor) {
        topShadowColor = topShadow
        bottomShadowColor = bottomShadow
    }
    
    private func setupView() {
		self.imageView.backgroundColor = .clear
        self.backgroundColor = .clear
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.color = theme.backgroundColor
        
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: self.frame.width / 2, height: self.frame.height / 2)
        activityIndicatorView.center = self.imageView.center
        activityIndicatorView.style = .medium
		
		Screen.size == .small ? activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6) : ()
    }
    
    public func showIndicator() {
        
		guard !activityIndicatorView.isAnimating else { return }
        
        U.UI {
            self.imageView.addSubview(self.activityIndicatorView)
            self.imageView.bringSubviewToFront(self.activityIndicatorView)
            self.activityIndicatorView.startAnimating()
        }
    }
    
    public func hideIndicator() {

		guard activityIndicatorView.isAnimating else { return }
        
        U.UI {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()
        }
    }
    
    public func setTintColor(_ tintColor: UIColor) {
        imageView.tintColor = tintColor
    }
	
	public func setImageWithCustomBackground(image: UIImage, tineColor: UIColor, size: CGSize, colors: [UIColor]) {
		
		helperImageView.image = image
		helperImageView.tintColor = tineColor
		helperImageView.contentMode = .scaleToFill
		self.addSubview(helperImageView)
		helperImageView.translatesAutoresizingMaskIntoConstraints = false
		helperImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		helperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		helperImageView.heightAnchor.constraint(equalToConstant: size.width).isActive = true
		helperImageView.widthAnchor.constraint(equalToConstant: size.height).isActive = true
		
		let gradientColors = colors.compactMap({$0.cgColor})
		let gradientBaseView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
		gradientBaseView.rounded()
		self.insertSubview(gradientBaseView, belowSubview: helperImageView)
		gradientBaseView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colors: gradientColors , type: .axial)
	}
	
    private func setupImageView() {
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageView.rounded()
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
    }
	
	public func updateImagesLayout() {
		
		imageView.setNeedsUpdateConstraints()
		helperImageView.setNeedsUpdateConstraints()
		imageView.layoutIfNeeded()
		helperImageView.layoutIfNeeded()
	}
    
    private func setupShadowViews() {
        
        [topLayer, bottomLayer].forEach {
            $0.frame = layer.bounds
            layer.insertSublayer($0, at: 0)
        }
        
        topLayer.setRoundedShadow(with: topShadowColor, size: CGSize(width: -7, height: -7), alpha: 1.0, radius: 14)
        bottomLayer.setRoundedShadow(with: bottomShadowColor, size: CGSize(width: 7, height: 7), alpha: 1.0, radius: 14)
    }
}
