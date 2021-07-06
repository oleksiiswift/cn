//
//  CircleProgressView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import UIKit

/// `line cap` style setup
public enum LineCap : Int{
    case round, butt, square

    public func style() -> String {
        switch self {
        case .round:
            return CAShapeLayerLineCap.round.rawValue
        case .butt:
            return CAShapeLayerLineCap.butt.rawValue
        case .square:
            return CAShapeLayerLineCap.square.rawValue
        }
    }
}

/// `orientation`
public enum ProgressBarOrientation: Int {
    case left
    case top
    case right
    case bottom
}

class CircleProgressView: UIView {

    // MARK: - Variables
    
    public var titleLabelWidth: CGFloat = 140
    public let percentLabel = UILabel(frame: .zero)
    
    public var titleLabel = UILabel(frame: .zero)

    /// `Stroke background color`
    public var clockwise: Bool = true {
        didSet {
            layoutSubviews()
        }
    }
    
    /// `inset` of label for small device
    public var titleLabelBottomInset: CGFloat = 50 {
        didSet {
            layoutSubviews()
        }
    }
    
    public var percentLabelCenterInset: CGFloat = 20 {
        didSet {
            layoutSubviews()
        }
    }

    /// `Stroke background color`
    public var backgroundShapeColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            updateShapes()
        }
    }

    /// `Progress stroke color`
    public var progressShapeColor: UIColor   = .blue {
        didSet {
            updateShapes()
        }
    }

    /// `Line width`
    public var lineWidth: CGFloat = 8.0 {
        didSet {
            updateShapes()
        }
    }

    /// `Space value`
    public var spaceDegree: CGFloat = 45.0 {
        didSet {
            layoutSubviews()
            updateShapes()
        }
    }

    /// The progress shapes line width will be the `line width` minus the `inset`.
    public var inset: CGFloat = 0.0 {
        didSet {
            updateShapes()
        }
    }

    // The progress percentage label(center label) format
    public var percentLabelFormat: String = "%.f %%" {
        didSet {
            percentLabel.text = String(format: percentLabelFormat, progress * 100)
        }
    }

    public var percentColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            percentLabel.textColor = percentColor
        }
    }


    /// progress text (progress bottom label)
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    public var titleColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            titleLabel.textColor = titleColor
        }
    }


    // progress text (progress bottom label)
    public var font: UIFont = .systemFont(ofSize: 13) {
        didSet {
            titleLabel.font = font
            percentLabel.font = font
        }
    }


    // progress Orientation
    public var orientation: ProgressBarOrientation = .bottom {
        didSet {
            updateShapes()
        }
    }

    /// Progress shapes line cap.
    public var lineCap: LineCap = .round {
        didSet {
            updateShapes()
        }
    }

    /// Returns the current progress.
    private(set) var progress: CGFloat {
        set {
            progressShape?.strokeEnd = newValue
        }
        get {
            return progressShape.strokeEnd
        }
    }

    /// Duration for a complete animation from 0.0 to 1.0.
    open var completeDuration: Double = 2.0

    private var backgroundShape: CAShapeLayer!
    private var progressShape: CAShapeLayer!
    private var progressAnimation: CABasicAnimation!

    // MARK: - Init

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {

        backgroundShape = CAShapeLayer()
        backgroundShape.fillColor = nil
        backgroundShape.strokeColor = backgroundShapeColor.cgColor
        layer.addSublayer(backgroundShape)

        progressShape = CAShapeLayer()
        progressShape.fillColor   = nil
        progressShape.strokeStart = 0.0
        progressShape.strokeEnd   = 0.1
        layer.addSublayer(progressShape)

        progressAnimation = CABasicAnimation(keyPath: "strokeEnd")

        percentLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2, y: self.bounds.midY - percentLabelCenterInset, width: titleLabelWidth, height: 21)

        percentLabel.textAlignment = .center
        
        self.addSubview(percentLabel)
        
        percentLabel.text = String(format: "%.1f%%", progress * 100)


        titleLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2, y: self.bounds.size.height - 10, width: titleLabelWidth, height: 21)

        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.contentScaleFactor = 0.3

        titleLabel.numberOfLines = 2

        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
    }

    // MARK: - Progress Animation
    
    public func setProgress(progress: CGFloat, animated: Bool = true) {

        if progress > 1.0 {
            return
        }

        var start = progressShape.strokeEnd
        if let presentationLayer = progressShape.presentation(){
            if let count = progressShape.animationKeys()?.count, count > 0  {
            start = presentationLayer.strokeEnd
            }
        }

        let duration = abs(Double(progress - start)) * completeDuration        
        percentLabel.text = String(format: percentLabelFormat, progress * 100)
        progressShape.strokeEnd = progress

        if animated {
            progressAnimation.fromValue = start
            progressAnimation.toValue   = progress
            progressAnimation.duration  = duration
            progressShape.add(progressAnimation, forKey: progressAnimation.keyPath)
        }
    }

    // MARK: - Layout

    open override func layoutSubviews() {

        super.layoutSubviews()

        backgroundShape.frame = bounds
        progressShape.frame   = bounds

        let rect = rectForShape()
        backgroundShape.path = pathForShape(rect: rect).cgPath
        progressShape.path   = pathForShape(rect: rect).cgPath

        self.titleLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2, y: self.bounds.size.height - titleLabelBottomInset, width: titleLabelWidth, height: 42)

        updateShapes()

        percentLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2, y: self.bounds.midY - percentLabelCenterInset, width: titleLabelWidth, height: 21)
    }

    private func updateShapes() {
        
        backgroundShape?.lineWidth   = lineWidth
        backgroundShape?.strokeColor = backgroundShapeColor.cgColor
        backgroundShape?.lineCap     = CAShapeLayerLineCap(rawValue: lineCap.style())

        progressShape?.strokeColor = progressShapeColor.cgColor
        progressShape?.lineWidth   = lineWidth - inset
        progressShape?.lineCap     = CAShapeLayerLineCap(rawValue: lineCap.style())

        switch orientation {
            
        case .left:
            
            titleLabel.isHidden = true
            
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi / 2, 0, 0, 1.0)
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1.0)
        case .right:
            
            titleLabel.isHidden = true
            
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi * 1.5, 0, 0, 1.0)
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi * 1.5, 0, 0, 1.0)
        case .bottom:
            
            titleLabel.isHidden = false
            
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: { [weak self] in
                if let temp = self{
                    temp.titleLabel.frame = CGRect(x: (temp.bounds.size.width - temp.titleLabelWidth) / 2, y: temp.bounds.size.height - self!.titleLabelBottomInset, width: temp.titleLabelWidth, height: 42)
                }

            }, completion: nil)
            
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi * 2, 0, 0, 1.0)
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi * 2, 0, 0, 1.0)
        case .top:
            
            titleLabel.isHidden = false
            
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: { [weak self] in
                if let temp = self{
                    temp.titleLabel.frame = CGRect(x: (temp.bounds.size.width - temp.titleLabelWidth) / 2, y: 0, width: temp.titleLabelWidth, height: 42)
                }

                }, completion: nil)
            
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi, 0, 0, 1.0)
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1.0)
        }
    }

    // MARK: - Helper

    private func rectForShape() -> CGRect {
        return bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
    }
    private func pathForShape(rect: CGRect) -> UIBezierPath {
        
        let startAngle: CGFloat!
        let endAngle: CGFloat!
        
        if clockwise{
            startAngle = CGFloat(spaceDegree * .pi / 180.0) + (0.5 * .pi)
            endAngle = CGFloat((360.0 - spaceDegree) * (.pi / 180.0)) + (0.5 * .pi)
        }else{
            startAngle = CGFloat((360.0 - spaceDegree) * (.pi / 180.0)) + (0.5 * .pi)
            endAngle = CGFloat(spaceDegree * .pi / 180.0) + (0.5 * .pi)
        }
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX,
                                                   y: rect.midY),
                                radius: rect.size.width / 2.0,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: clockwise)
        return path
    }
}

