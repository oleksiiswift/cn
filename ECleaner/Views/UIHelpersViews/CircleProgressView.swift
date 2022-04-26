//
//  CircleProgressView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import UIKit

enum TitlePercentLablelsPosition {
	case centered
	case customWithinset
	case centeredRightAlign
	case centeredLeftAlign
}

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
	
	public var titleLabelsPercentPosition: TitlePercentLablelsPosition = .centered {
		didSet {
			updateLabels()
		}
	}
	
	public var titleLabelMargin: CGFloat = 20 {
		didSet {
			titleLabel.rightMargin(margin: titleLabelMargin)
		}
	}
	
	public var percentLabelTextAligement: NSTextAlignment = .center {
		didSet {
			updateLabels()
		}
	}
	
		/// work only when constraint activated
	public var percentTitleLabelSpaceOffset: CGFloat = -20 {
		didSet {
			updateLabels()
		}
	}
	
	public var percentLabelYOffset: CGFloat = 0 {
		didSet {
			updateLabels()
		}
	}
		
	public var titleLabelTextAligement: NSTextAlignment = .center {
		didSet {
			updateLabels()
		}
	}

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
    public var backgroundShapeColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
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
    public var lineWidth: CGFloat = 40.0 {
        didSet {
            updateShapes()
        }
    }

    /// `Space value`
    public var spaceDegree: CGFloat = 12.0 {
        didSet {
            layoutSubviews()
            updateShapes()
        }
    }
	/// `Space value for background
	public var backgrounSpaceDegree: CGFloat = 0.0 {
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

    public var percentColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
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

    public var titleColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
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
    
	public var startColor: UIColor = .yellow {
//	UIColor().colorFromHexString("66CDFF") {
        didSet {
            setNeedsLayout()
        }
    }
    
	public var endColor:   UIColor = .blue {
//UIColor().colorFromHexString("3677FF") {
        didSet {
            setNeedsLayout()
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
	
	public var backgroundShadowColor: UIColor = .red {
		didSet {
			setNeedsLayout()
		}
	}
	
	public var backgroundShadowOffcet: CGSize = CGSize(width: 6, height: 6) {
		didSet {
			setNeedsLayout()
		}
	}
	
	public var backgroundShadwoOppacity: Float = 1.0 {
		didSet {
			setNeedsLayout()
		}
	}
	
    /// Duration for a complete animation from 0.0 to 1.0.
    open var completeDuration: Double = 2.0

    private var backgroundShape: CAShapeLayer!
    private var progressShape: CAShapeLayer!
    private var progressAnimation: CABasicAnimation!

    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
		gradientLayer.type = .conic
//        gradientLayer.locations = [0.2,0.5,0.75,1]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()

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
        layer.addSublayer(gradientLayer)
		
        progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        self.addSubview(percentLabel)
        
        percentLabel.text = String(format: "%.1f%%", progress * 100)
        titleLabel.text = title
        titleLabel.contentScaleFactor = 0.3

        titleLabel.numberOfLines = 2

        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
		
		updateLabels()
    }
	
	public func updateLabels() {
		// heigt of percent and title label is fix
		let percentTitleLabelHeight: CGFloat = 61
		let titleLabelHeight: CGFloat = 42
		
		var calculatedPercentLabelWidth: CGFloat = 0
		
		if let stringText = self.percentLabel.text, let font = self.percentLabel.font {
			calculatedPercentLabelWidth = stringText.width(withConstrainedHeight: percentTitleLabelHeight, font: font)
		}
		
		switch self.titleLabelsPercentPosition {
			case .centered:
				self.percentLabel.textAlignment = .center
				self.titleLabel.textAlignment = .center
				
				self.percentLabel.translatesAutoresizingMaskIntoConstraints = false
				self.percentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				self.percentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: percentLabelYOffset).isActive = true
				self.percentLabel.heightAnchor.constraint(equalToConstant: percentTitleLabelHeight).isActive = true
				self.percentLabel.widthAnchor.constraint(equalToConstant: self.titleLabelWidth).isActive = true
				
				self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
				self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				self.titleLabel.topAnchor.constraint(equalTo: self.percentLabel.bottomAnchor, constant: self.percentTitleLabelSpaceOffset).isActive = true
				self.titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight).isActive = true
				self.titleLabel.widthAnchor.constraint(equalToConstant: self.titleLabelWidth).isActive = true
			case .customWithinset:
				self.percentLabel.textAlignment = percentLabelTextAligement
				self.titleLabel.textAlignment = titleLabelTextAligement
				
				self.percentLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2,
												 y: self.bounds.midY - percentLabelCenterInset,
												 width: titleLabelWidth,
												 height: percentTitleLabelHeight)
				self.titleLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth) / 2,
											   y: self.percentLabel.frame.maxY,
											   width: titleLabelWidth, height: titleLabelHeight)
			case .centeredRightAlign:
				self.percentLabel.textAlignment = .center
				self.titleLabel.textAlignment = .right
				self.percentLabel.translatesAutoresizingMaskIntoConstraints = false
				self.percentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				self.percentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: percentLabelYOffset).isActive = true
				self.percentLabel.heightAnchor.constraint(equalToConstant: percentTitleLabelHeight).isActive = true
				self.percentLabel.widthAnchor.constraint(equalToConstant: calculatedPercentLabelWidth).isActive = true
				
				self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
				self.titleLabel.trailingAnchor.constraint(equalTo: percentLabel.trailingAnchor, constant: -3).isActive = true
				self.titleLabel.centerYAnchor.constraint(equalTo: self.percentLabel.bottomAnchor, constant: self.percentTitleLabelSpaceOffset).isActive = true
				self.titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight).isActive = true
				self.titleLabel.widthAnchor.constraint(equalToConstant: self.titleLabelWidth).isActive = true
			case .centeredLeftAlign:
				self.percentLabel.textAlignment = .center
				self.titleLabel.textAlignment = .left
				self.percentLabel.translatesAutoresizingMaskIntoConstraints = false
				self.percentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
				self.percentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: percentLabelYOffset).isActive = true
				self.percentLabel.heightAnchor.constraint(equalToConstant: percentTitleLabelHeight).isActive = true
				self.percentLabel.widthAnchor.constraint(equalToConstant: calculatedPercentLabelWidth).isActive = true
				
				self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
				self.titleLabel.leadingAnchor.constraint(equalTo: percentLabel.leadingAnchor, constant: 3).isActive = true
				self.titleLabel.centerYAnchor.constraint(equalTo: self.percentLabel.bottomAnchor, constant: self.percentTitleLabelSpaceOffset).isActive = true
				self.titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight).isActive = true
				self.titleLabel.widthAnchor.constraint(equalToConstant: self.titleLabelWidth).isActive = true
		}
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
		backgroundShape.path = pathForShape(rect: rect, degree: backgrounSpaceDegree).cgPath
		progressShape.path   = pathForShape(rect: rect, degree: spaceDegree).cgPath
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor, endColor].map { $0.cgColor }
		
		layer.masksToBounds = false
		layer.shadowOffset = backgroundShadowOffcet
		layer.shadowColor = backgroundShadowColor.cgColor
		layer.shadowRadius = 14
		layer.shadowOpacity = backgroundShadwoOppacity

        let path = progressShape.path
        if let mask = progressShape {
            mask.fillColor = UIColor.clear.cgColor
            mask.strokeColor = UIColor.white.cgColor
            mask.lineWidth = lineWidth
            mask.path = path
            gradientLayer.mask = mask
        }
        
        updateLabels()
        updateShapes()
    }

    private func updateShapes() {
        
        backgroundShape?.lineWidth   = lineWidth
        backgroundShape?.strokeColor = backgroundShapeColor.cgColor
        backgroundShape?.lineCap     = CAShapeLayerLineCap(rawValue: lineCap.style())
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
			
				guard let `self` = self else { return }
				self.updateLabels()
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
	private func pathForShape(rect: CGRect, degree: CGFloat) -> UIBezierPath {
        
        let startAngle: CGFloat!
        let endAngle: CGFloat!
        
        if clockwise{
            startAngle = CGFloat(degree * .pi / 180.0) + (0.5 * .pi)
            endAngle = CGFloat((360.0 - degree) * (.pi / 180.0)) + (0.5 * .pi)
        }else{
            startAngle = CGFloat((360.0 - degree) * (.pi / 180.0)) + (0.5 * .pi)
            endAngle = CGFloat(degree * .pi / 180.0) + (0.5 * .pi)
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


class MMTGradientArcView: UIView {
    
    var lineWidth: CGFloat = 47 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    var startColor = UIColor().colorFromHexString("66CDFF") {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    var endColor = UIColor().colorFromHexString("3677FF") {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    var startAngle:CGFloat = 0 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    var endAngle:CGFloat = 360 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let gradations = 360 //My School Number
        
        var startColorR:CGFloat = 0
        var startColorG:CGFloat = 0
        var startColorB:CGFloat = 0
        var startColorA:CGFloat = 0
        
        var endColorR:CGFloat = 0
        var endColorG:CGFloat = 0
        var endColorB:CGFloat = 0
        var endColorA:CGFloat = 0
        
        startColor.getRed(&startColorR, green: &startColorG, blue: &startColorB, alpha: &startColorA)
        endColor.getRed(&endColorR, green: &endColorG, blue: &endColorB, alpha: &endColorA)
        
        let startAngle:CGFloat = 90
        let endAngle:CGFloat = 360
        
            //    let startAngle = CGFloat(0 * .pi / 180.0) + (0.5 * .pi)
            //    let endAngle = CGFloat((360.0 - 0) * (.pi / 180.0)) + (0.5 * .pi)
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        var angle = startAngle
        
        for i in 1 ... gradations {
            let extraAngle = (endAngle - startAngle) / CGFloat(gradations)
            let currentStartAngle = angle
            let currentEndAngle = currentStartAngle + extraAngle
            
            let currentR = ((endColorR - startColorR) / CGFloat(gradations - 1)) * CGFloat(i - 1) + startColorR
            let currentG = ((endColorG - startColorG) / CGFloat(gradations - 1)) * CGFloat(i - 1) + startColorG
            let currentB = ((endColorB - startColorB) / CGFloat(gradations - 1)) * CGFloat(i - 1) + startColorB
            let currentA = ((endColorA - startColorA) / CGFloat(gradations - 1)) * CGFloat(i - 1) + startColorA
            
            let currentColor = UIColor.init(red: currentR, green: currentG, blue: currentB, alpha: currentA)
            
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            path.addArc(withCenter: center, radius: radius, startAngle: currentStartAngle * CGFloat(Double.pi / 180.0), endAngle: currentEndAngle * CGFloat(Double.pi / 180.0), clockwise: true)
            
            currentColor.setStroke()
            path.stroke()
            angle = currentEndAngle
        }
    }
}



