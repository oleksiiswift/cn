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
    }
    
    override func draw(_ rect: CGRect) {
        
        let progressFrame: CGRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
        progressView.backgroundColor = progressColor
        progressView.frame = progressFrame
    }
}
