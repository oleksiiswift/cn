//
//  UIView+Radius.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

extension UIView {
    
    func setCorner(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func rounded() {
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
    }
}
