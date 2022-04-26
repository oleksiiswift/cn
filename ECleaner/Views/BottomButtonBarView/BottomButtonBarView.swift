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
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    var delegate: BottomActionButtonDelegate?
    
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
	
	public func setFont(_ font: UIFont) {
		actionButton.font = font
	}
	
	public func title(_ title: String) {
		actionButton.setTitle(title)
	}
	
	public func setImage(_ image: UIImage, with size: CGSize = CGSize(width: 18, height: 22) ) {
		actionButton.setButtonImage(image: image, size: size)
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
}

//      MARK: -bottom action button -
class BottomBarButtonItem: UIButton {
	
	public var imageSpacing: CGFloat = 26
	public var imageSize: CGSize = CGSize(width: 18, height: 22)
	public var font: UIFont = .systemFont(ofSize: 16.8, weight: .bold)
	
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
}

extension BottomButtonBarView {
    
    public func addButtonShadow() {
        
        let topShadow = ReuseShadowView()
        self.insertSubview(topShadow, at: 0)
        topShadow.translatesAutoresizingMaskIntoConstraints = false
        topShadow.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor).isActive = true
        topShadow.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor).isActive = true
        topShadow.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor).isActive = true
        topShadow.topAnchor.constraint(equalTo: actionButton.topAnchor).isActive = true
    }
}

extension BottomBarButtonItem {
	
	public func animateProgress() {
		
		let animation = CABasicAnimation(keyPath: "transform.rotation")
		animation.fromValue = 0
		animation.toValue =  Double.pi * 2.0
		animation.duration = 2
		animation.repeatCount = .infinity
		animation.isRemovedOnCompletion = false
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			imageView.layer.add(animation, forKey: "spin")
		}
	}

	public func removeAnimateProgress() {
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			imageView.layer.removeAnimation(forKey: "spin")
		}
	}
}


