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
    private let imageView = UIImageView()
    
    public var topShadowColor: UIColor = .red
    public var bottomShadowColor: UIColor = .black
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupImageView()
        setupShadowViews()
        setupView()
    }
    
    public func setImage(_ image: UIImage? = nil) {
        imageView.image = image
    }
    
    public func setShadowColor(for topShadow: UIColor, and bottomShadow: UIColor) {
        topShadowColor = topShadow
        bottomShadowColor = bottomShadow
    }
    
    private func setupView() {
        
        self.backgroundColor = .clear
    }
    
    private func setupImageView() {
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageView.rounded()
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
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
