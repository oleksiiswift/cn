//
//  UIView+SelectedCornerRadius.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit

extension UIView {
    
    func cornerSelectRadiusView(corners: UIRectCorner, radius: CGFloat) {
     
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
