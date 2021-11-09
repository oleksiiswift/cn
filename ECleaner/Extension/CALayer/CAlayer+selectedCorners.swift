//
//  CAlayer+selectedCorners.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.11.2021.
//

import UIKit
extension CALayer {
    
    func setRoundedMask(corners: UIRectCorner, radius: CGFloat) {
     
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        mask = shapeMask
    }
}
