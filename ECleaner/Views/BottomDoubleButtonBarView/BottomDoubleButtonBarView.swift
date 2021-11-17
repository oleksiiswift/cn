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
    @IBOutlet weak var leftActionBottomButton: BottomBarButtonItem!
    @IBOutlet weak var rightActionBottomButton: BottomBarButtonItem!
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
        leftActionBottomButton.setTitle(title, for: .normal)
    }
    
    public func setRightButtonTitle(_ title: String) {
        rightActionBottomButton.setTitle(title, for: .normal)
    }
    
    public func setLeftButtonImage(_ image: UIImage) {
        leftActionBottomButton.setImage(image, for: .normal)
    }
    
    public func setRightButtonImage(_ image: UIImage) {
        rightActionBottomButton.setImage(image, for: .normal)
    }
    
    @objc func didTapLeftButton() {
        delegate?.didTapLeftActionButton()
    }
    
    @objc func didTapRightButton() {
        delegate?.didTapRightActionButton()
    }
}
