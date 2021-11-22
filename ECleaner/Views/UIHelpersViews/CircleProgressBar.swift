//
//  CircleProgressBar.swift
//  ECleaner
//
//  Created by alekseii sorochan on 07.10.2021.
//

import UIKit

public class CircularProgressBar: CALayer {
    
    private var circularPath: UIBezierPath!
    private var innerTrackShapeLayer: CAShapeLayer!
    private var outerTrackShapeLayer: CAShapeLayer!
    private let rotateTransformation = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
    private var completedLabel: UILabel!
    public var progressLabel: UILabel!
    public var isUsingAnimation: Bool!
    
    public var progress: CGFloat = 0 {
        didSet {
            progressLabel.text = "\(progress.cleanValue)%"
            innerTrackShapeLayer.strokeEnd = progress / 100
            if progress > 100 {
                progressLabel.text = "100%"
            }
        }
    }
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
            //    gradientLayer.locations = [0.2,0.5,0.75,1]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        return gradientLayer
    }()
    
    var startColor: UIColor = UIColor().colorFromHexString("66CDFF") { didSet { setNeedsLayout() } }
    var endColor:   UIColor = UIColor().colorFromHexString("3677FF")  { didSet { setNeedsLayout() } }
    
    public init(radius: CGFloat, position: CGPoint, innerTrackColor: UIColor, outerTrackColor: UIColor, lineWidth: CGFloat) {
        super.init()
        
        circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerTrackShapeLayer = CAShapeLayer()
        outerTrackShapeLayer.path = circularPath.cgPath
        outerTrackShapeLayer.position = position
        outerTrackShapeLayer.strokeColor = outerTrackColor.cgColor
        outerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        outerTrackShapeLayer.lineWidth = lineWidth
        outerTrackShapeLayer.strokeEnd = 1
        outerTrackShapeLayer.lineCap = CAShapeLayerLineCap.round
        outerTrackShapeLayer.transform = rotateTransformation
        addSublayer(outerTrackShapeLayer)
        
        innerTrackShapeLayer = CAShapeLayer()
        innerTrackShapeLayer.strokeColor = innerTrackColor.cgColor
        innerTrackShapeLayer.position = position
        innerTrackShapeLayer.strokeEnd = progress
        innerTrackShapeLayer.lineWidth = lineWidth
        innerTrackShapeLayer.lineCap = CAShapeLayerLineCap.round
        innerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        innerTrackShapeLayer.path = circularPath.cgPath
        innerTrackShapeLayer.transform = rotateTransformation
        addSublayer(innerTrackShapeLayer)
        
//        addSublayer(gradientLayer)
//
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [startColor, endColor].map { $0.cgColor }
////
//        let path = innerTrackShapeLayer.path
//        if let mask = innerTrackShapeLayer {
//            mask.fillColor = UIColor.clear.cgColor
//            mask.strokeColor = UIColor.white.cgColor
//            mask.lineWidth = lineWidth
//            mask.path = path
//            gradientLayer.mask = mask
//        }
        
        progressLabel = UILabel()
        let size = CGSize(width: radius, height: radius)
        let origin = CGPoint(x: position.x, y: position.y)
        progressLabel.frame = CGRect(origin: origin, size: size)
        progressLabel.center = position
        progressLabel.center.y = position.y - 10
        progressLabel.font = UIFont.boldSystemFont(ofSize: radius * 0.27)
        progressLabel.text = "0%"
        progressLabel.textColor = .red
        progressLabel.textAlignment = .center
        insertSublayer(progressLabel.layer, at: 0)
        
//        completedLabel = UILabel()
//        let completedLabelOrigin = CGPoint(x: position.x , y: position.y)
//        completedLabel.frame = CGRect(origin: completedLabelOrigin, size: CGSize.init(width: radius, height: radius * 0.6))
//        completedLabel.font = UIFont.systemFont(ofSize: radius * 0.2, weight: UIFont.Weight.light)
//        completedLabel.textAlignment = .center
//        completedLabel.center = position
//        completedLabel.center.y = position.y + 20
//        completedLabel.textColor = .red
//        completedLabel.text = "Completed"
//        insertSublayer(completedLabel.layer, at: 0)
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

