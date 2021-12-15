//
//  HorizontalProgressBar.swift
//  ECleaner
//
//  Created by alekseii sorochan on 06.10.2021.
//

import UIKit

@IBDesignable class HorizontalProgressBar: UIView {
    
    @IBInspectable var progressColor: UIColor = .gray {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var progressView = UIView()
	private let backgroundMask = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        
        self.addSubview(progressView)
		progressView.frame = self.bounds
		progressView.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
		
		let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
		let progressLayer = CALayer()
		progressLayer.name = "progress"
		progressLayer.frame = progressRect
		progressView.layer.addSublayer(progressLayer)
		progressLayer.backgroundColor = progressColor.cgColor
    }
	
	public func resetProgressLayer() {
		
		guard let sublayers = progressView.layer.sublayers else { return }
		
		for sublayer in sublayers {
			if sublayer.name == "progress" {
				sublayer.removeFromSuperlayer()
			}
		}
	}
}
