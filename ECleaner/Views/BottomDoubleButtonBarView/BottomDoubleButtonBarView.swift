//
//  BottomDoubleButtonBarView.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.11.2021.
//

import UIKit

protocol BottomDoubleActionButtonDelegate: AnyObject {
    
    func didTapLeftActionButton()
    func didTapRightActionButton()
}

class BottomDoubleButtonBarView: UIView {

    @IBOutlet var contantView: UIView!
    @IBOutlet weak var leftActionBottomButton: BottomPrimaryBarButtonItem!
    @IBOutlet weak var rightActionBottomButton: BottomPrimaryBarButtonItem!
    @IBOutlet weak var buttonsStackHeightConstraint: NSLayoutConstraint!
    
    var delegate: BottomDoubleActionButtonDelegate?
    
    public var leftButtonColor: UIColor = .orange
    public var rightButtonColor: UIColor = .blue
    
    public var leftButtonTintColor: UIColor = .white
    public var rightButtonTintColor: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        actionButtonsSetup()
    }
    
    private func commonInit() {
        
        U.mainBundle.loadNibNamed(C.identifiers.xibs.bottomDoubleButtonBarView, owner: self, options: nil)
    }
    
    private func configure() {
        
        self.addSubview(contantView)
        contantView.frame = self.bounds
        contantView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.backgroundColor = .clear
		self.setButtonHeight(U.UIHelper.AppDimensions.bottomBarButtonDefaultHeight)
        leftActionBottomButton.configureAppearance(buttonColor: self.leftButtonColor, tintColor: self.leftButtonTintColor)
        rightActionBottomButton.configureAppearance(buttonColor: self.rightButtonColor, tintColor: self.rightButtonTintColor)
    }
    
    public func updateColorsSettings() {
        leftActionBottomButton.configureAppearance(buttonColor: self.leftButtonColor, tintColor: self.leftButtonTintColor)
        rightActionBottomButton.configureAppearance(buttonColor: self.rightButtonColor, tintColor: self.rightButtonTintColor)
    }
    
    private func actionButtonsSetup() {
        
        leftActionBottomButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        rightActionBottomButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }
	
	public func setButtonHeight(_ height: CGFloat) {
		buttonsStackHeightConstraint.constant = height
	}
    
    public func setLeftButtonTitle(_ title: String) {
        leftActionBottomButton.setTitle(title)
    }
    
    public func setRightButtonTitle(_ title: String) {
        rightActionBottomButton.setTitle(title)
    }
    
    public func setLeftButtonImage(_ image: UIImage) {
        leftActionBottomButton.setButtonImage(image: image)
    }
    
    public func setRightButtonImage(_ image: UIImage) {
        rightActionBottomButton.setButtonImage(image: image)
    }
    
    @objc func didTapLeftButton() {
		leftActionBottomButton.animateButtonTransform()
        delegate?.didTapLeftActionButton()
    }
    
    @objc func didTapRightButton() {
		rightActionBottomButton.animateButtonTransform()
        delegate?.didTapRightActionButton()
    }
}

class BottomPrimaryBarButtonItem: UIButton {
    
	public var imageSpacing: CGFloat = U.UIHelper.AppDimensions.bottomPrimaryButtonImageSpacing
//    public var imageSize: CGSize = CGSize(width: 18, height: 22)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure()
    }
    
    private func configure() {
        
        self.setCorner(14)
        self.titleLabel?.font = FontManager.bottomButtonFont(of: .title)
    }
    
    public func configureAppearance(buttonColor: UIColor, tintColor: UIColor) {
        self.backgroundColor = buttonColor
        self.tintColor = tintColor
    }

    public func setTitle(_ newTitle: String) {
        self.setTitleWithoutAnimation(title: newTitle)
    }
    
    public func setButtonImage(image: UIImage) {
		let size = U.UIHelper.AppDimensions.bottomBarPrimaaryButtonImageSize
		let imageSize = image.getPreservingAspectRationScaleImageSize(from: CGSize(width: size, height: size))
		
		
        self.addLeftImage(image: image, size: imageSize, spacing: imageSpacing)
    }
}
