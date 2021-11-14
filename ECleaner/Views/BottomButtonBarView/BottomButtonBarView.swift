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
    
    var delegate: BottomActionButtonDelegate?
    
    public var buttonColor: UIColor = .red
    public var buttonTintColor: UIColor = .white
    
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
        
        self.configure()
        self.actionButtonSetup()
    }
    
    private func commonInit() {
        
        U.mainBundle.loadNibNamed(C.identifiers.xibs.bottomButtonBarView, owner: self, options: nil)
    }
    
    private func configure() {
        
        self.addSubview(self.containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.backgroundColor = .clear
        actionButton.configureAppearance(buttonColor: self.buttonColor, tintColor: self.buttonTintColor)
    }
    
    public func updateColorsSettings() {
        actionButton.configureAppearance(buttonColor: self.buttonColor, tintColor: self.buttonTintColor)
    }
    
    private func actionButtonSetup() {
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    public func title(_ title: String) {
        actionButton.setTitle(title)
    }
    
    public func setImage(_ image: UIImage) {
        actionButton.setButtonImage(image: image)
    }
    
    @objc func didTapActionButton() {
        delegate?.didTapActionButton()
    }
}

//      MARK: -bottom action button -


class BottomBarButtonItem: UIButton {
    
    public var imageSpacing: CGFloat = 26
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
        self.addLeftImageWithFixLeft(spacing: imageSpacing, size: imageSize, image: image)
    }
}
