//
//  PrimaryShadowImageWithTextButton.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.11.2021.
//

import UIKit

class PrimaryShadowImageWithTextButton: UIButton {
    
    private let topShadowLayer = CALayer()
    private let bottomShadowLayer = CALayer()
    
    public var imageSize: CGSize = CGSize(width: 24, height: 18)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureButton()
    }

    private func configureButton() {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        bottomShadowLayer.backgroundColor = theme.primaryButtonBackgroundColor.cgColor
        bottomShadowLayer.cornerRadius = 10
        
        [bottomShadowLayer, topShadowLayer].forEach {
            $0.masksToBounds = false
            $0.frame = layer.bounds
            layer.insertSublayer($0, at: 0)
        }
        
        layer.applyShadow(color: theme.primaryButtonBottomShadowColor, alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
        topShadowLayer.applyShadow(color: theme.topShadowColor, alpha: 1.0, x: -2, y: -5, blur: 19, spread: -1)
    }
    
    public func didset(lefty image: UIImage, with title: String) {
        
        addLeftImage(image: image, size: self.imageSize, spacing: 5)
        setTitle(title, for: .normal)
    }
    
    public func didset(righty image: UIImage, with title: String) {
        
        addRightImage(image: image, size: self.imageSize, spacing: 5)
        setTitle(title, for: .normal)
    }
}
