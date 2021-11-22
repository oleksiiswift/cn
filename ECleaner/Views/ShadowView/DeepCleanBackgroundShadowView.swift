//
//  DeepCleanBackgroundShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 05.11.2021.
//

import UIKit

class DeepCleanBackgroundShadowView: UIView {
    
    let topShadowView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        self.clipsToBounds = true
        self.layer.cornerRadius = 14
        
        self.topShadowView.clipsToBounds = true
        self.topShadowView.layer.cornerRadius = 14
        
        self.backgroundColor = UIColor().colorFromHexString("E7EDF4")
        topShadowView.backgroundColor = UIColor().colorFromHexString("E7EDF4")
        topShadowView.frame = self.bounds
        self.insertSubview(topShadowView, at: 0)
        
        layer.applySketchShadow(
            color: UIColor().colorFromHexString("A4B5C4"),
            alpha: 1.0,
            x: 3,
            y: 3,
            blur: 10,
            spread: 0)
        
        topShadowView.layer.applySketchShadow(
            color: UIColor().colorFromHexString("FFFFFF"),
            alpha: 1.0,
            x: -3,
            y: -3,
            blur: 15,
            spread: 0)
    }
}
