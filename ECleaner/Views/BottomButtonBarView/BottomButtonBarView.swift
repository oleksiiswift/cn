//
//  BottomButtonBarView.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.11.2021.
//

import UIKit

protocol BottomActionButtonDelegate: AnyObject {
    
    func didTapActionButton()
}

class BottomButtonBarView: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var actionButton: BottomBarButtonItem!
	@IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)

	@IBOutlet weak var actionButtonLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionButtonTrailingConstraint: NSLayoutConstraint!
	
	private var topShadow = ReuseShadowView()
	
	var delegate: BottomActionButtonDelegate?
    
	private var buttonOffset: UIEdgeInsets = .zero
	
    public var buttonColor: UIColor = .red
    public var buttonTintColor: UIColor = .white
    public var buttonTitleColor: UIColor?
    public var activityIndicatorColor: UIColor = .white
    
    public var configureShadow: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
        self.actionButtonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }

    private func commonInit() {
        
        U.mainBundle.loadNibNamed(C.identifiers.xibs.bottomButtonBarView, owner: self, options: nil)
    }
    
    private func configure() {
        
        self.addSubview(self.containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		self.setButtonHeight(AppDimensions.Subscription.Navigation.bottomBarButtonDefaultHeight)
        
		self.backgroundColor = .clear
		self.activityIndicatorView.color = activityIndicatorColor
		self.activityIndicatorView.isHidden = true
		
        let buttonBackgroundColor: UIColor = configureShadow ? .clear : self.buttonColor
        actionButton.configureAppearance(buttonColor: buttonBackgroundColor, tintColor: self.buttonTintColor)
    }

    public func updateColorsSettings() {
        
		self.backgroundColor = .clear
		
        let buttonBackgroundColor: UIColor = configureShadow ? .clear : self.buttonColor
        
        activityIndicatorView.color = activityIndicatorColor
        actionButton.configureAppearance(buttonColor: buttonBackgroundColor, tintColor: self.buttonTintColor)
        if let color = buttonTitleColor {
            actionButton.setTitleColor(color, for: .normal)
        }
    }
    
    public func setButtonProcess(_ isStarting: Bool) {
		U.UI {
			self.actionButton.processingButton(isStarting)
			self.activityIndicatorView.isHidden = !isStarting
			self.setActivityIndicator(isStarting)
		}
    }
	
	public func setLockButtonAnimate(state: SubscriptionActionProcessingState) {
		Utils.UI {
			switch state {
				case .processing:
					self.setButtonProcess(true)
					self.actionButton.isEnabled = false
					UIView.animate(withDuration: 0.3) {
						self.actionButton.alpha = 0.5
					}
				case .active:
					self.setButtonProcess(false)
					self.actionButton.isEnabled = true
					UIView.animate(withDuration: 0.3) {
						self.actionButton.alpha = 1.0
					}
				case .disabled:
					self.actionButton.isEnabled = false
					UIView.animate(withDuration: 0.3) {
						self.actionButton.alpha = 0.5
					}
			}
		}
	}
	
	private func setActivityIndicator(_ isStarting: Bool) {
		
		if isStarting {
			self.addSubview(activityIndicatorView)
			activityIndicatorView.isHidden = false
			activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
			activityIndicatorView.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor).isActive = true
			activityIndicatorView.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor).isActive = true
			activityIndicatorView.widthAnchor.constraint(equalToConstant: 20).isActive = true
			activityIndicatorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
			activityIndicatorView.startAnimating()
		} else {
			activityIndicatorView.stopAnimating()
			activityIndicatorView.removeFromSuperview()
		}
		activityIndicatorView.layoutIfNeeded()
	}

	private func actionButtonSetup() {
		
		actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
	}
	
	public func setButtonHeight(_ height: CGFloat) {
		buttonHeightConstraint.constant = height
	}
	
	public func setContainerHeight(_ height: CGFloat) {
		containerHeightConstraint.constant = height
		containerView.layoutIfNeeded()
	}
	
	public func setFont(_ font: UIFont) {
		actionButton.font = font
	}
	
	public func title(_ title: String) {
		actionButton.setTitle(title)
	}
	
	public func setImage(_ image: UIImage, with size: CGSize = CGSize(width: 18, height: 22) ) {
		actionButton.setButtonImage(image: image, size: size)
	}
	
	public func setImageRight(_ image: UIImage, with size: CGSize = CGSize(width: 18, height: 22)) {
		actionButton.setButtonImageRight(image: image, size: size)
	}
	
	@objc func didTapActionButton() {
		self.animateButtonTransform()
		delegate?.didTapActionButton()
	}
	
	public func startAnimatingButton() {
		actionButton.animateProgress()
	}
	
	public func stopAnimatingButton() {
		actionButton.removeAnimateProgress()
	}
	
	public func setButtonSideOffset(_ offset: CGFloat = 20) {
	    self.buttonOffset = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: offset)
		self.actionButtonLeadingConstraint.constant = offset
		self.actionButtonTrailingConstraint.constant = offset
	}
	
	public func setButtonGradientBackgroundColor(from startPount: CAGradientPoint, to endPoiunt: CAGradientPoint, with colors: [UIColor]) {
		
		let gradientColors = colors.compactMap({$0.cgColor})
		let gradientBaseView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
		self.actionButton.insertSubview(gradientBaseView, at: 0)
		gradientBaseView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colors: gradientColors , type: .axial)
	}
	
	public func isSetImage(_ image: UIImage) -> Bool {
		return actionButton.isSetImageSame(with: image)
	}
}

//      MARK: -bottom action button -
class BottomBarButtonItem: UIButton {
	
	public var imageSpacing: CGFloat = 26
	public var imageSize: CGSize = CGSize(width: 18, height: 22)
	public var font: UIFont = FontManager.bottomButtonFont(of: .title)
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			UIView.animate(withDuration: 0.1) {
				imageView.alpha = 0.3
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			UIView.animate(withDuration: 0.1) {
				imageView.alpha = 1
			}
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		
		configure()
	}
	
	private func configure() {
		
		self.setCorner(14)
		self.setFont()
	}
	
	public func processingButton(_ isStart: Bool) {
		
		isStart ? self.setTitleColor(.clear, for: .normal) : self.setTitleColor(tintColor, for: .normal)
		self.hideTemporaryImage(isStart)
	}
	
	public func configureAppearance(buttonColor: UIColor, tintColor: UIColor) {
		self.backgroundColor = buttonColor
		self.tintColor = tintColor
	}
	
	public func setFont() {
		self.titleLabel?.font = font
	}
	
	public func setTitle(_ newTitle: String) {
		self.setTitleWithoutAnimation(title: newTitle)
	}
	
	public func setButtonImage(image: UIImage, size: CGSize = CGSize(width: 18, height: 22)) {
		self.addLeftImageWithFixLeft(spacing: imageSpacing, size: size, image: image)
	}
	
	public func setButtonImageRight(image: UIImage, size: CGSize = CGSize(width: 19, height: 22)) {
		self.addRighttImageWithFixRight(spacing: imageSpacing, size: size, image: image)
	}
	
	public func setbuttonAvailible(_ availible: Bool) {
		self.isEnabled = availible
		self.alpha = availible ? 1.0 : 0.6
	}
	
	public func isSetImageSame(with image: UIImage) -> Bool {
		if let settingImage = self.subviews.first(where: {$0.tag == 66613}) as? UIImageView {
			return settingImage.image == image
		} else {
			return false
		}
	}
}

extension BottomButtonBarView {
    
    public func addButtonShadow() {
        
        self.insertSubview(topShadow, at: 0)
        topShadow.translatesAutoresizingMaskIntoConstraints = false
        topShadow.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor).isActive = true
        topShadow.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor).isActive = true
        topShadow.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor).isActive = true
        topShadow.topAnchor.constraint(equalTo: actionButton.topAnchor).isActive = true
    }
	
	public func addButtonShadhowIfLayoutError() {
		
		actionButton.removeFromSuperview()
		
		self.addSubview(actionButton)
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		actionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: buttonOffset.left).isActive = true
		actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -buttonOffset.right).isActive = true
		actionButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
		actionButton.heightAnchor.constraint(equalToConstant: AppDimensions.Subscription.Navigation.bottomBarButtonDefaultHeight).isActive = true
		addButtonShadow()
		actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
	}
	
	public func addButtonGradientBackground(colors: [UIColor]) {
		let gradientColors = colors.compactMap({$0.cgColor})
		actionButton.layerGradient(startPoint: .centerLeft, endPoint: .centerRight, colors: gradientColors , type: .axial)
	}
}

extension BottomBarButtonItem {
	
	public func animateShakeHello() {
		
		U.delay(10) {
			self.shakeWith(duration: 4, angle: 45, yOffset: 0)
			self.animateShakeHello()
		}
	}
	
	private func shakeWith(duration: Double, angle: CGFloat, yOffset: CGFloat) {
		   
		guard let imageView = self.subviews.first(where: {$0.tag == 66613})  else { return }
		   
		   let numberOfFrames: Double = 6
		   let frameDuration = Double(1/numberOfFrames)
		
		   UIView.animateKeyframes(withDuration: duration, delay: 0, options: [],
			 animations: {
			   UIView.addKeyframe(withRelativeStartTime: 0.0,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform(rotationAngle: -angle)
			   }
			   UIView.addKeyframe(withRelativeStartTime: frameDuration,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform(rotationAngle: +angle)
			   }
			   UIView.addKeyframe(withRelativeStartTime: frameDuration*2,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform(rotationAngle: -angle)
			   }
			   UIView.addKeyframe(withRelativeStartTime: frameDuration*3,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform(rotationAngle: +angle)
			   }
			   UIView.addKeyframe(withRelativeStartTime: frameDuration*4,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform(rotationAngle: -angle)
			   }
			   UIView.addKeyframe(withRelativeStartTime: frameDuration*5,
								  relativeDuration: frameDuration) {
				   imageView.transform = CGAffineTransform.identity
			   }
			 },
			 completion: nil
		   )
	}
}


