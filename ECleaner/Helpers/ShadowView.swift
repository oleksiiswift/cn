//
//  ShadowView.swift
//  ShadowView
//
//  Created by iMac_1 on 20.10.2021.
//

import Foundation
import UIKit

class ShadowView: UIView {
  
  let topShadowView = UIView()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.clipsToBounds = true
    self.layer.cornerRadius = 14
    
    self.topShadowView.clipsToBounds = true
    self.topShadowView.layer.cornerRadius = 14
    
    self.backgroundColor = UIColor().colorFromHexString("E9EFF2")
    topShadowView.backgroundColor = UIColor().colorFromHexString("E9EFF2")
    topShadowView.frame = self.bounds
    self.insertSubview(topShadowView, at: 0)
    
    layer.applySketchShadow(
      color: UIColor().colorFromHexString("D1DAE8"),
      alpha: 1.0,
      x: 6,
      y: 6,
      blur: 10,
      spread: 0)
    
    topShadowView.layer.applySketchShadow(
      color: UIColor().colorFromHexString("FFFFFF"),
      alpha: 1.0,
      x: -2,
      y: -5,
      blur: 19,
      spread: 0)
  }
}


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
}
