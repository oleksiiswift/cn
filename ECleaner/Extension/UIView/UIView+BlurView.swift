//
//  UIView+BlurView.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

extension UIView {
    
    func setupForShadow(shadowColor: UIColor = .black,
                        cornerRadius: CGFloat = 6,
                        shadowOffcet: CGSize = CGSize(width: 7, height: 7),
                        shadowOpacity: Float = 0.2,
                        shadowRadius: CGFloat = 5) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity =  shadowOpacity
        self.layer.shadowOffset = shadowOffcet
        self.layer.shadowRadius = shadowRadius
        self.isOpaque = true
    }
    
    func setupForBlurViewVsShadow(style: UIBlurEffect.Style,
                                  blurCornerRadius: CGFloat = 12,
                                  blurViewAlpha: CGFloat = 1,
                                  isShadowActive: Bool = false,
                                  shadowCornerRadius: CGFloat = 6,
                                  shadowColor: UIColor = .black,
                                  shadowOffcet: CGSize = CGSize(width: 7, height: 7),
                                  shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 5) {
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = blurCornerRadius
        blurView.alpha = blurViewAlpha
        blurView.clipsToBounds = true
        self.insertSubview(blurView, at: 0)
        self.clipsToBounds = true
        
        if isShadowActive {
            self.layer.cornerRadius = shadowCornerRadius
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity =  shadowOpacity
            self.layer.shadowOffset = shadowOffcet
            self.layer.shadowRadius = shadowRadius
            self.isOpaque = true
        }
        NSLayoutConstraint.activate([blurView.heightAnchor.constraint(equalTo: self.heightAnchor), blurView.widthAnchor.constraint(equalTo: self.widthAnchor)])
    }
    
    func setupForSimpleBlurView(blur style: UIBlurEffect.Style) {
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurEffectView, at: 0)
    }
    
    func setupRadiiBlurView(style: UIBlurEffect.Style, radius: CGFloat, alphaComponent: CGFloat = 1.0) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.masksToBounds = false
        blurEffectView.layer.cornerRadius = radius
        blurEffectView.alpha = alphaComponent
        self.insertSubview(blurEffectView, at: 0)
    }
}
