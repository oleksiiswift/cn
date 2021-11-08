//
//  SectionShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.11.2021.
//

import UIKit

enum RoundedSectionCorners {
    
    case top
    case bottom
    case central
}



class SectionShadowView: UIView {
    
    public var sectionColorsPosition: RoundedSectionCorners = .central
    
    let topShadowView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
//        self.layer.cornerRadius = 14
        
        self.topShadowView.clipsToBounds = true
//        self.topShadowView.layer.cornerRadius = 14
        
        self.backgroundColor = UIColor().colorFromHexString("E9EFF2")
        topShadowView.backgroundColor = UIColor().colorFromHexString("E9EFF2")
        topShadowView.frame = self.bounds
        
        
        switch sectionColorsPosition {
            case .top:

                
                self.insertSubview(topShadowView, at: 0)
                
//                self.layer.setShadowAndCorners(radius: 14, corners: [.topLeft, .topRight], color: .init(hex: "D1DAE8"), alpha: 1, x: 6, y: 6, blur: 10, spread: 0)
                
                self.layer.applySketchShadowZ(
                    color: .red,
                    alpha: 1.0,
                    x: 6,
                    y: 6,
                    blur: 10,
                    spread: 0)
                
//                self.layer.setShadowAndCorners(cornersRadius: 14, corners: [.topLeft, .topRight], color: .init(hex: "D1DAE8"), alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
//                self.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 14)
//                topShadowView.layer.setShadowAndCorners(cornersRadius: 14, corners: [.topLeft, .topRight], color: .init(hex: "FFFFFF"), alpha: 1.0, x: -2, y: -3, blur: 19, spread: 0)
                topShadowView.layer.applySketchShadowZ(
                    color: .black,
                    alpha: 1.0,
                    x: -2,
                    y: -3,
                    blur: 19,
                    spread: 0)
                
                
//                self.topShadowView.layer.setShadowAndCorners(cornersRadius: 14, corners: [.topLeft, .topRight], color: UIColor().colorFromHexString("FFFFFF"), alpha: 1.0, x: -2, y: -3, blur: 19, spread: 0)
                
//                                    self.topShadowView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 14)
//                                    self.layer.setRoundedMask(corners: [.topLeft, .topRight], radius: 14)
                
            case .bottom:
//                self.topShadowView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 14)
                
//                self.layer.setRoundedMask(corners: [.bottomLeft, .bottomRight], radius: 14)
                
                self.layer.applySketchShadow(
                    color: UIColor().colorFromHexString("D1DAE8"),
                    alpha: 1.0,
                    x: 6,
                    y: 6,
                    blur: 10,
                    spread: 0)
            case .central:
                
                layer.applySketchShadow(
                    color: UIColor().colorFromHexString("D1DAE8"),
                    alpha: 1.0,
                    x: 6,
                    y: 0,
                    blur: 10,
                    spread: 0)
        }
        
     
    }
    
//    let shadowView = UIView()
//
//    public var sectionColorsPosition: RoundedSectionCorners = .central
//
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.clipsToBounds = true
//        self.shadowView.clipsToBounds = true
//
//
//        self.backgroundColor = .init(hex: "E9EFF2")
//        self.shadowView.backgroundColor = .init(hex: "E9EFF2")
//
//        self.shadowView.frame = self.bounds
//        self.shadowView.layer.cornerRadius = 14
//
//        switch sectionColorsPosition {
//        case .top:
//                self.layer.setRoundedMask(corners: [.topLeft, .topRight], radius: 14)
//
//
//                self.insertSubview(shadowView, at: 0)
//
//                self.layer.applySketchShadow(color: UIColor().colorFromHexString("D1DAE8"), alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
//                self.shadowView.layer.applySketchShadow(color: .red, alpha: 1.0, x: -2, y: -3, blur: 19, spread: 0)
//        case .bottom:
//                self.layer.setRoundedMask(corners: [.bottomLeft, .bottomRight], radius: 14)
//                self.shadowView.cornerSelectRadiusView(corners: [.bottomLeft, .bottomRight], radius: 14)
//                self.insertSubview(shadowView, at: 0)
//
//
//
//        case .central:
//                debugPrint("")
//        }
//    }
}



