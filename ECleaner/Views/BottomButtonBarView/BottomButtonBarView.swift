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
    public var buttonTitleColor: UIColor?
    public var activityIndicatorColor: UIColor = .white
    
    public var configureShadow: Bool = false
    
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
        
        let buttonBackgroundColor: UIColor = configureShadow ? .clear : self.buttonColor
        
        actionButton.activityIndicatorConfigureAppearance(set: activityIndicatorColor)
        actionButton.configureAppearance(buttonColor: buttonBackgroundColor, tintColor: self.buttonTintColor)
    }
    
    public func updateColorsSettings() {
        
        let buttonBackgroundColor: UIColor = configureShadow ? .clear : self.buttonColor
        
        actionButton.configureAppearance(buttonColor: buttonBackgroundColor, tintColor: self.buttonTintColor)
        if let color = buttonTitleColor {
            actionButton.setTitleColor(color, for: .normal)
        }
    }
    
    public func setButtonProcess(_ isStarting: Bool) {
        actionButton.processingButton(isStarting)
    }
    
    private func actionButtonSetup() {
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    public func title(_ title: String) {
        actionButton.setTitle(title)
    }
    
    public func setImage(_ image: UIImage, with size: CGSize = CGSize(width: 18, height: 22) ) {
        actionButton.setButtonImage(image: image, size: size)
    }
    
    @objc func didTapActionButton() {
        delegate?.didTapActionButton()
    }
}

//      MARK: -bottom action button -


class BottomBarButtonItem: UIButton {
    
    public var imageSpacing: CGFloat = 26
    public var imageSize: CGSize = CGSize(width: 18, height: 22)
    public var activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure()
        activityIndicatorConfigure()
    }
    
    private func configure() {
        
        self.setCorner(14)
        self.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .bold)
    }
    
    private func activityIndicatorConfigure() {
        activityIndicatorView.isHidden = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setActivateIndicator() {
        
        self.bringSubviewToFront(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 20),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 20)
        ])
        activityIndicatorView.layoutIfNeeded()
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func setDeactivateIndicator() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
    
    public func processingButton(_ isStart: Bool) {
        
        isStart ? self.setTitleColor(.clear, for: .normal) : self.setTitleColor(tintColor, for: .normal)
        self.hideTemporaryImage(isStart)
        isStart ? setActivateIndicator() : setDeactivateIndicator()
    }
    
    public func configureAppearance(buttonColor: UIColor, tintColor: UIColor) {
        self.backgroundColor = buttonColor
        self.tintColor = tintColor
    }
    
    public func activityIndicatorConfigureAppearance(set color: UIColor) {
        self.activityIndicatorView.color = color
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

