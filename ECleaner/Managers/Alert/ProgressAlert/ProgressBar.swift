//
//  ProgressBar.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.04.2022.
//

import UIKit

class ProgressAlertBar: UIView {
	
	private var progressView = UIView()
	
	var progressColor: UIColor = .green {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var mainBackgroundColor: UIColor = .gray {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var progressCorner: CGFloat = 6 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var borderColor: UIColor = .orange {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var borderWidth: CGFloat = 1.5 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var progress: CGFloat = 0 {
		didSet {
			setNeedsDisplay()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupView()
		updateColors()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		setupView()
	}
	
	private func setupView() {
		
		self.addSubview(progressView)
	}
	
	public func updateColors() {
		self.backgroundColor = mainBackgroundColor
		self.setCorner(progressCorner)
		self.layer.borderWidth = borderWidth
		self.layer.borderColor = borderColor.cgColor
	}
	
	override func draw(_ rect: CGRect) {
		
		let progressFrame: CGRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
		progressView.setCorner(progressCorner)
		progressView.backgroundColor = progressColor
		progressView.frame = progressFrame
	}
}
