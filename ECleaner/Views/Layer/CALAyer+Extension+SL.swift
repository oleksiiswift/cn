//
//  CALAyer+Extension+SL.swift
//  ECleaner
//
//  Created by alexey sorochan on 05.11.2021.
//

import UIKit

extension CALayer {
    
    func applySketchShadow(
        
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        
        spread: CGFloat = 0) {
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
    
    
    
    func applySketchShadowZ(
        
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        
        spread: CGFloat = 0) {
            
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 14, height: 14))
            let layerMask = CAShapeLayer()
            layerMask.path = path.cgPath
            
            masksToBounds = false
            shadowColor = color.cgColor
            shadowOpacity = alpha
            shadowOffset = CGSize(width: x, height: y)
            shadowRadius = blur / 2.0
            
            shadowPath = path.cgPath
//            UIBezierPath(roundedRect: bounds.insetBy(dx: 0, dy: 0), cornerRadius: 12).cgPath
            
            self.addSublayer(layerMask)
//            if spread == 0 {
//                shadowPath = nil
//            } else {
//                let dx = -spread
//                let rect = bounds.insetBy(dx: dx, dy: dx)
//                shadowPath = UIBezierPath(rect: rect).cgPath
//            }
        }
    
}


extension CALayer {
    
    func setShadowAndCorners(radius: CGFloat = 12, corners: UIRectCorner = [.allCorners], color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let layerMask = CAShapeLayer()
//        mask.path = path.cgPath
//
        layerMask.path = path.cgPath
//        shapeLayer.fillColor = color.cgColor
//        shapeLayer.shadowOpacity = alpha
//        shapeLayer.shadowOffset = CGSize(width: x, height: y)
//        shapeLayer.shadowRadius = blur / 2.0
        
        
//        self.addSublayer(layerMask)
        
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
//
}

//
//func cornerSelectRadiusView(corners: UIRectCorner, radius: CGFloat) {
//
//    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//    let mask = CAShapeLayer()
//    mask.path = path.cgPath
//    layer.mask = mask
//}
