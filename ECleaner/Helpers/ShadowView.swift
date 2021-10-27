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

class ShadowRoundedView: UIView {
  
  let imageView = UIImageView()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.clipsToBounds = true
    self.layer.cornerRadius = self.frame.size.height / 2

    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = self.frame.size.height / 2

    imageView.backgroundColor = .white
    imageView.frame = self.bounds
    
    self.addSubview(imageView)
    
    imageView.contentMode = .scaleAspectFill
    
    layer.applySketchShadow(
      color: UIColor().colorFromHexString("FFFFFF"),
      alpha: 1.0,
      x: -9,
      y: -9,
      blur: 27,
      spread: 0)

    imageView.layer.applySketchShadow(
      color: UIColor().colorFromHexString("A4B5C4"),
      alpha: 1.0,
      x: 9,
      y: 9,
      blur: 32,
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

public class InnerShadowLayer: CAGradientLayer {
    
    public enum Edge {
        case Top
        case Left
        case Bottom
        case Right
    }
    
    public init(forView view: UIView,
                edge: Edge = Edge.Top,
                shadowRadius radius: CGFloat = 20.0,
                toColor: UIColor = UIColor.white,
                fromColor: UIColor = UIColor.black) {
        super.init()
        self.colors = [fromColor.cgColor, toColor.cgColor]
        self.shadowRadius = radius
        
        let viewFrame = view.frame
        
        switch edge {
            case .Top:
                startPoint = CGPoint(x: 0.5, y: 0.0)
                endPoint = CGPoint(x: 0.5, y: 1.0)
                self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
            case .Bottom:
                startPoint = CGPoint(x: 0.5, y: 1.0)
                endPoint = CGPoint(x: 0.5, y: 0.0)
                self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
            case .Left:
                startPoint = CGPoint(x: 0.0, y: 0.5)
                endPoint = CGPoint(x: 1.0, y: 0.5)
                self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
            case .Right:
                startPoint = CGPoint(x: 1.0, y: 0.5)
                endPoint = CGPoint(x: 0.0, y: 0.5)
                self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
