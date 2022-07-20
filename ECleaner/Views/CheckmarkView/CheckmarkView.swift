//
//  CheckmarkView.swift
//  ECleaner
//
//  Created by alexey sorochan on 20.07.2022.
//

import UIKit

enum AnimationType: Int {
	case opacity = 0
	case stroke = 1
}

class CheckmarkView: UIView {
	
	enum AnimationCurve: Int {
		case linear = 0
		case easeInEaseOut = 1
	}

	public private (set) var checked: Bool = false
	public var animationCurve: AnimationCurve = .linear
	public var checkmarkWidth: CGFloat = 10
	public var animationDuration = 1.0
	public var checkmarkGradient: [UIColor] = [.green, .red]
	public var removeprogressBar: (() -> Void)?
	
	private var checkMarkrShape: CAShapeLayer!
	
	private let gradientLayer: CAGradientLayer = {
		let gradientLayer = CAGradientLayer()
		gradientLayer.type = .axial
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
		return gradientLayer
	}()

	@objc override dynamic class var layerClass: AnyClass {
	get {
			return CAShapeLayer.self
		}
	}
	
	override required init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configure()
	}
	
	public func animateCheckmarkStrokeEnd(_ show: Bool) {
		
		guard let layer = layer as? CAShapeLayer else { return }
		
		let newStrokeEnd: CGFloat = show ? 1.0 : 0.0
		let oldStrokeEnd: CGFloat = show ? 0.0 : 1.0

		let keyPath = "strokeEnd"
		let animation = CABasicAnimation(keyPath: keyPath)
		animation.delegate = self
		animation.fromValue = oldStrokeEnd
		animation.toValue = newStrokeEnd
		animation.duration = animationDuration
		
		let timingFunction: CAMediaTimingFunction
		if animationCurve == .linear {
			timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		} else {
			timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		}
		animation.timingFunction = timingFunction
		layer.add(animation, forKey: nil)
		DispatchQueue.main.async {
			layer.strokeEnd = newStrokeEnd
		}
		self.checked = show
	}

	public func animateCheckmarkAlpha(_ checked: Bool) {
		var animationOptions: UIView.AnimationOptions
		if animationCurve == .linear {
			animationOptions = .curveLinear
		} else {
			animationOptions = .curveEaseInOut
		}
		UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
			let newAlpha: CGFloat = checked ? 1.0 : 0.0
			self.alpha = newAlpha
		}
	}

	public func showCheckmark(_ checked: Bool, animated: Bool, animationType: AnimationType) {
		guard let layer = layer as? CAShapeLayer else { return }
		let newStrokeEnd: CGFloat = checked ?  1.0 : 0.0
		
		let oldStrokeEnd: CGFloat = checked ? 0.0 : 1.0

		switch animationType {
		case .opacity:
			layer.strokeEnd = 1.0
			alpha = oldStrokeEnd
		case .stroke:
			alpha = 1.0
			layer.strokeEnd = oldStrokeEnd
		}
		
		if !animated {
			alpha = newStrokeEnd
			layer.strokeEnd = newStrokeEnd
		} else {
			if animationType == .stroke {
				animateCheckmarkStrokeEnd(checked)
			} else {

				animateCheckmarkAlpha(checked)
			}
		}
	}

	private func checkmarkPath() -> UIBezierPath {
		
		let scale = frame.width / 100
		let centerX = frame.size.width / 2
		let centerY = frame.size.height / 2

		let path = UIBezierPath()
		
		path.move(to: CGPoint(x: centerX - 23 * scale, y: centerY - 1 * scale))
		path.addLine(to: CGPoint(x: centerX - 6 * scale, y: centerY + 15.9 * scale))
		path.addLine(to: CGPoint(x: centerX + 22.8 * scale, y: centerY - 13.4 * scale))

		return path
	}
	
	public func gradientSetup(startPoint: CGPoint, endPoint: CGPoint, gradientType: CAGradientLayerType) {
		
		self.gradientLayer.startPoint = startPoint
		self.gradientLayer.endPoint = endPoint
		self.gradientLayer.type = gradientType
	}

	func configure() {
		
		guard let layer = layer as? CAShapeLayer, bounds.size.height >= 50, bounds.size.width >= 50 else { return }
		layer.lineWidth = checkmarkWidth
		layer.fillColor = UIColor.clear.cgColor
		layer.strokeColor = theme.contactsGradientStarterColor.cgColor
		layer.lineCap = .round
		layer.path = checkmarkPath().cgPath
		
		gradientLayer.frame = layer.bounds
		gradientLayer.bounds = layer.bounds
	}
	
	func updateGradient() {
//		not working as is with path and animation
		gradientLayer.colors = checkmarkGradient.map { $0.cgColor }
		let shapeMask = CAShapeLayer()
		shapeMask.fillColor = UIColor.clear.cgColor
		shapeMask.strokeColor = UIColor.white.cgColor
		shapeMask.lineWidth = checkmarkWidth
		shapeMask.path = checkmarkPath().cgPath
		gradientLayer.mask = shapeMask
//		layer.addSublayer(gradientLayer)
	}
}

extension CheckmarkView: CAAnimationDelegate {
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		debugPrint("animation stop")
		removeprogressBar?()
	}
}
