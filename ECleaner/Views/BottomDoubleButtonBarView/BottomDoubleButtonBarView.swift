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
    @IBOutlet weak var leftActionBottomButton: BottomSmallerBarButtonItem!
    @IBOutlet weak var rightActionBottomButton: BottomSmallerBarButtonItem!
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

class BottomSmallerBarButtonItem: UIButton {
    
    public var imageSpacing: CGFloat = 10
    public var imageSize: CGSize = CGSize(width: 18, height: 22)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure()
    }
    
    private func configure() {
        
        self.setCorner(14)
        self.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .bold)
    }
    
    public func configureAppearance(buttonColor: UIColor, tintColor: UIColor) {
        self.backgroundColor = buttonColor
        self.tintColor = tintColor
    }

    public func setTitle(_ newTitle: String) {
        self.setTitleWithoutAnimation(title: newTitle)
    }
    
    public func setButtonImage(image: UIImage) {
        self.addLeftImage(image: image, size: imageSize, spacing: imageSpacing)
    }
}
