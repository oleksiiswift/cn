//
//  NavigationBar.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.11.2021.
//

import UIKit

class NavigationBar: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var leftBarButtonItem: UIButton!
    @IBOutlet weak var rightBarButtonItem: UIButton!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var leftButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButtonWidthConstraint: NSLayoutConstraint!
	
    var delegate: NavigationBarDelegate?

    public var setIsDropShadow: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
        self.actionButtonsSetup()
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
        
        U.mainBundle.loadNibNamed(C.identifiers.navigation.navigationBar, owner: self, options: nil)
    }
    
    private func configure() {
        
        containerView.backgroundColor = theme.navigationBarBackgroundColor
        
        backgroundColor = .clear
        addSubview(self.containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        leftBarButtonItem.backgroundColor = .clear
        rightBarButtonItem.backgroundColor = .clear
        
		rightBarButtonItem.titleLabel?.font = U.UIHelper.AppDefaultFontSize.NavigationBar.navigationBarButtonItemsFont.monospacedDigitFont
		leftBarButtonItem.titleLabel?.font = U.UIHelper.AppDefaultFontSize.NavigationBar.navigationBarButtonItemsFont.monospacedDigitFont
    }

    public func setupNavigation(title: String?, leftBarButtonImage: UIImage?, rightBarButtonImage: UIImage?, contentType: MediaContentType, leftButtonTitle: String? = nil, rightButtonTitle: String? = nil) {
        
        self.setAccentColorFor(buttonsTintColor: contentType.screenAcentTintColor, title: theme.tintColor)
        setDropShadow(visible: setIsDropShadow)
		
		var leftTargetSize: CGSize {
			if let leftBarButtonImage = leftBarButtonImage {
				return self.getProportionalSize(of: leftBarButtonImage, targetImageScaleFactor: 0.4)
			} else {
				return .zero
			}
		}
		
		var rigthTargetSize: CGSize {
			if let rightBarButtonImage = rightBarButtonImage {
				return self.getProportionalSize(of: rightBarButtonImage, targetImageScaleFactor: 0.5)
			} else {
				return .zero
			}
		}
		
        if let title = title {
            titleTextLabel.text = title
            titleTextLabel.isHidden = false
        } else {
            titleTextLabel.isHidden = true
        }
        
        if let leftBarButtonImage = leftBarButtonImage {
            leftButtonLeadingConstraint.constant = 5
            leftBarButtonItem.setTitle(nil, for: .normal)
			leftBarButtonItem.addCenterImage(image: leftBarButtonImage, imageWidth: leftTargetSize.width, imageHeight: leftTargetSize.height)
            leftBarButtonItem.isHidden = false
			leftBarButtonItem.contentHorizontalAlignment = .center
        } else if let leftTitle = leftButtonTitle {
            leftButtonLeadingConstraint.constant = 20
            leftBarButtonItem.setImage(nil, for: .normal)
            leftBarButtonItem.setTitleWithoutAnimation(title: leftTitle)
            leftBarButtonItem.isHidden = false
			leftBarButtonItem.contentHorizontalAlignment = .left
        } else {
            leftBarButtonItem.isHidden = true
        }
        
        if let rightBarButtonImage = rightBarButtonImage {
            rightButtonWidthConstraint.constant = 50
            rightButtonTrailingConstraint.constant = 10
            rightBarButtonItem.setTitle(nil, for: .normal)
			rightBarButtonItem.addCenterImage(image: rightBarButtonImage, imageWidth: rigthTargetSize.width, imageHeight: rigthTargetSize.height)
            rightBarButtonItem.isHidden = false
			rightBarButtonItem.contentHorizontalAlignment = .center
        } else if let rightTitle = rightButtonTitle {
			rightButtonWidthConstraint.constant = 80
            rightButtonTrailingConstraint.constant = 20
            rightBarButtonItem.setImage(nil, for: .normal)
            rightBarButtonItem.setTitleWithoutAnimation(title: rightTitle)
            rightBarButtonItem.isHidden = false
			rightBarButtonItem.contentHorizontalAlignment = .right
        } else {
            rightBarButtonItem.isHidden = true
        }
		
			leftBarButtonItem.layoutIfNeeded()
			rightBarButtonItem.layoutIfNeeded()
    }
    
    public func setDropShadow(visible: Bool) {
        
        visible ? layer.setShadow(color: theme.bottomShadowColor, alpha: 1, x: 3, y: 0, blur: 10, spread: 0) : ()
    }
    
    public func changeHotLeftTitle(newTitle: String) {
        leftBarButtonItem.setImage(nil, for: .normal)
        leftBarButtonItem.sizeToFit()
        leftBarButtonItem.setTitleWithoutAnimation(title: newTitle)
    }
    
    public func changeHotRightTitle(newTitle: String) {
        rightBarButtonItem.setImage(nil, for: .normal)
        rightBarButtonItem.setTitleWithoutAnimation(title: newTitle)
    }
	
	public func changeHotLeftTitleWithImage(newTitle: String, image: UIImage) {
		
		let imageSize = self.getProportionalSize(of: image, targetImageScaleFactor: 0.4)
		
		if newTitle.isEmpty {
			leftButtonLeadingConstraint.constant = 5
			leftBarButtonItem.addCenterImage(image: image, imageWidth: imageSize.width, imageHeight: imageSize.height)
			leftBarButtonItem.setTitleWithoutAnimation(title: "")
		} else {
			leftBarButtonItem.addLeftImage(image: image, size: imageSize, spacing: 0.3)
			leftBarButtonItem.setTitleWithoutAnimation(title: newTitle)
			leftButtonLeadingConstraint.constant = 17
		}
		leftBarButtonItem.layoutIfNeeded()
	}
	
	public func changeHotRightButton(with newImage: UIImage) {
		U.UI {
			let imageSize = self.getProportionalSize(of: newImage)
			self.rightBarButtonItem.addCenterImage(image: newImage, imageWidth: imageSize.height, imageHeight: imageSize.height)
		}
	}
	
	private func getProportionalSize(of image: UIImage, targetImageScaleFactor: CGFloat = 0.5) -> CGSize {
		let buttonSize = U.UIHelper.AppDimensions.NavigationBar.navigationBarButtonSize
		let targetSize: CGSize = CGSize(width: buttonSize * targetImageScaleFactor, height: buttonSize * targetImageScaleFactor)
		return image.getPreservingAspectRationScaleImageSize(from: targetSize)
	}

    private func setAccentColorFor(buttonsTintColor: UIColor, title: UIColor) {
        
        leftBarButtonItem.tintColor = buttonsTintColor
        rightBarButtonItem.tintColor = buttonsTintColor
        titleTextLabel.textColor = title
		titleTextLabel.font = U.UIHelper.AppDefaultFontSize.NavigationBar.navigationBarTitleFont
    }
    
    private func actionButtonsSetup() {
        
        leftBarButtonItem.addTarget(self, action: #selector(didTapLeftBarButtonItem(_:)), for: .touchUpInside)
        rightBarButtonItem.addTarget(self, action: #selector(didTapRightBarButtonItem(_:)), for: .touchUpInside)
    }

    @objc func didTapLeftBarButtonItem(_ sender: UIButton) {
        delegate?.didTapLeftBarButton(sender)
    }
    
    @objc func didTapRightBarButtonItem(_ sender: UIButton) {
        delegate?.didTapRightBarButton(sender)
    }
}

extension NavigationBar {
	
	public func temporaryLockLeftButton(_ isLock: Bool) {
		U.UI {
			self.leftBarButtonItem.isEnabled = !isLock
		}
	}
	
	public func temporaryLockRightButton(_ isLock: Bool) {
		U.UI {
			self.rightBarButtonItem.isEnabled = !isLock			
		}
	}
}

extension NavigationBar {
    
    public func handleChangeRightButtonSelectState(selectAll: Bool) {
        
        let newtitle: String = !selectAll ? "select all" : "deselectAll"
        
        changeHotRightTitle(newTitle: newtitle)
    }
}


