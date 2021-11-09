//
//  SectionShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.11.2021.
//

import UIKit

class SectionShadowView: UIView {
    
    public var sectionRowPosition: RowPosition = .none

    var topShadowView = UIView()
    var sideShadowView = UIView()
    var bottomShadowView = UIView()

    var topSideShadowView = UIView()
    var sidSideShadowView = UIView()
    var bottomSideShadowView = UIView()
    
    var setupShadowDone: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        
        let cellBackgroundColor: UIColor = theme.cellBackGroundColor
        let topShadowColor: UIColor = theme.topShadowColor
        let cellShadowColor: UIColor = theme.sideShadowColor
        
        self.backgroundColor = .clear
        topShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height + 15)
        sideShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height + 15)
        bottomShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        topSideShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width - 15, height: self.frame.height + 15)
        sidSideShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width - 15, height: self.frame.height + 15)
        bottomSideShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width - 15, height: self.frame.height / 2)
        
        /// `position select` according to position need check where shadow cordinates and set different shadows
        /// `top shadow view` use for top left shadow
        /// `native view layer` use for background of cell and corner radii + extra right bottom shadows
    
        switch sectionRowPosition {
            case .top:
                let cellCorners: UIRectCorner = [.topLeft, .topRight]
                
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: .clear, alpha: 1, x: 6, y: 6, blur: 10, corners: cellCorners, radius: 14)
                
                self.insertSubview(topSideShadowView, at: 0)
                self.topSideShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: cellShadowColor, alpha: 1, x: 20, y: 6, blur: 10, corners: [], radius: 14)
                
                self.insertSubview(topShadowView, at: 0)
                self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -3, y: -2, blur: 10, corners: [], radius: 14)
            case .middle:
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: .clear, alpha: 1, x: 6, y: 0, blur: 10, corners: [], radius: 14)
                
                self.insertSubview(sidSideShadowView, at: 0)
                self.sidSideShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: cellShadowColor, alpha: 1, x: 20, y: -6, blur: 10, corners: [], radius: 14)
                
                self.insertSubview(sideShadowView, at: 0)
                self.sideShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -3, y: -2, blur: 10, corners: [], radius: 14)
            case .bottom:
                let cellCorners: UIRectCorner = [.bottomLeft, .bottomRight]
                
                self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor, shadow: cellShadowColor, alpha: 1, x: 6, y: 6, blur: 10, corners: cellCorners, radius: 14)
                
                self.insertSubview(bottomSideShadowView, at: 0)
                self.bottomSideShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: cellShadowColor, alpha: 1, x: 20, y: -30, blur: 10, corners: [], radius: 14)
                
                self.insertSubview(bottomShadowView, at: 0)
                self.bottomShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: topShadowColor, alpha: 1, x: -3, y: -2, blur: 10, corners: [], radius: 14)
            case .none:

                debugPrint("none")
        }
        setupShadowDone = true
    }
    
    public func prepareForReuse() {
        
        sectionRowPosition = .none
        topShadowView.layer.removeSketchShadow()
        sideShadowView.layer.removeSketchShadow()
        bottomShadowView.layer.removeSketchShadow()

        topSideShadowView.layer.removeSketchShadow()
        sidSideShadowView.layer.removeSketchShadow()
        bottomSideShadowView.layer.removeSketchShadow()
        
        self.layer.removeCornersSublayers()
        self.layer.removeSketchShadow()
        topShadowView.removeFromSuperview()
        sideShadowView.removeFromSuperview()
        bottomShadowView.removeFromSuperview()

        topSideShadowView.removeFromSuperview()
        sidSideShadowView.removeFromSuperview()
        bottomSideShadowView.removeFromSuperview()
    }
}



