//
//  CALAyer+Extension+SL.swift
//  ECleaner
//
//  Created by alexey sorochan on 05.11.2021.
//

import UIKit

extension CALayer {
    
    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func removeSketchShadow() {
        shadowColor = nil
        shadowOpacity = 0
        shadowOffset = CGSize(width: 0, height: 0)
        shadowRadius = 0
        shadowPath = nil
    }
}
 
//  MARK: - main shadow setups -

extension CALayer {
    
    func setShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func removeShadow() {
        shadowColor = nil
        shadowOpacity = 0
        shadowOffset = CGSize(width: 0, height: 0)
        shadowRadius = 0
        shadowPath = nil
    }
    
    func setShadowAndCustomCorners(backgroundColor: UIColor = .black, shadow: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat, corners: UIRectCorner, radius: CGFloat = 12) {
    
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let layerMask = CAShapeLayer()
		layerMask.frame = self.bounds
        layerMask.path = path.cgPath
        layerMask.fillColor = backgroundColor.cgColor
        layerMask.name = "corners"
        masksToBounds = false
        shadowColor = shadow.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        shadowPath = path.cgPath
        self.addSublayer(layerMask)
    }
    
    func setRoundedShadow(with color: UIColor, size offset: CGSize, alpha opacity: Float, radius: CGFloat) {
        
        name = "rounded"
        masksToBounds = false
        cornerRadius = frame.height / 2
        shadowColor = color.cgColor
        shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shadowOffset = offset
        shadowOpacity = opacity
        shadowRadius = radius
    }
    
    func removeCornersSublayers() {
        
        guard let sublayers = sublayers else { return }
        
        for sublayer in sublayers {
            if sublayer.name == "corners" {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func removeRoundedSublayers() {
        
        guard let sublayers = sublayers else { return }
        
        for sublayer in sublayers {
            if sublayer.name == "rounded" {
                sublayer.removeFromSuperlayer()
            }
        }
    }
}
