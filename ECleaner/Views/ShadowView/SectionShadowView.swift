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
    
    private var cellBackgroundColor: UIColor = .init(hex: "ECF0F6")
    private var topShadowColor: UIColor = .init(hex: "FFFFFF")
    private var cellShadowColor: UIColor = .init(hex: "D1DAE8")
    
    let topShadowView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
        topShadowView.frame = self.bounds
        
        self.insertSubview(topShadowView, at: 0)
        
        switch sectionColorsPosition {
            case .top:
                let cellCorners: UIRectCorner = [.topLeft, .topRight]
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: .orange, alpha: 1, x: 6, y: 6, blur: 10, corners: cellCorners, radius: 14)
                self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -1, y: -2, blur: 19, corners: [], radius: 14)
            case .central:
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: .orange, alpha: 1, x: 6, y: 0, blur: 10, corners: [], radius: 14)
                self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -1, y: 1, blur: 19, corners: [], radius: 14)
            case .bottom:
                let cellCorners: UIRectCorner = [.bottomLeft, .bottomRight]
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: .orange, alpha: 1, x: 6, y: 6, blur: 10, corners: cellCorners, radius: 14)
                self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -1, y: 1, blur: 19, corners: [], radius: 14)
        }
    }
}



