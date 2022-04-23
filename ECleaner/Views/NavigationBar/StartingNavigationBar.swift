//
//  StartingNavigationBar.swift
//  StartingNavigationBar
//
//  Created by iMac_1 on 18.10.2021.
//

import UIKit

class StartingNavigationBar: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftBarButton: PrimaryButton!
    @IBOutlet weak var rightBarButton: PrimaryButton!
    @IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var leftShadowView: ReuseShadowView!
	@IBOutlet weak var rightShadowView: ReuseShadowView!
	
    var delegate: StartingNavigationBarDelegate?
    
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
        
        U.mainBundle.loadNibNamed(C.identifiers.navigation.main, owner: self, options: nil)
    }
   
    private func configure() {
        
        containerView.backgroundColor = .clear
        backgroundColor = .clear
        addSubview(self.containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
		leftBarButton.primaryShadowsIsActive = false
		rightBarButton.primaryShadowsIsActive = false
		
        leftBarButton.clipsToBounds = true
        leftBarButton.layer.cornerRadius = 10
        
        rightBarButton.clipsToBounds = true
        rightBarButton.layer.cornerRadius = 10
		
		titleLabel.textColor = theme.titleTextColor
		
		leftShadowView.topShadowOffsetOriginX = -2
		leftShadowView.topShadowOffsetOriginY = -5
		
		rightShadowView.topShadowOffsetOriginY = -2
		rightShadowView.topShadowOffsetOriginX = -5
    }
    
    public func setUpNavigation(title: String?, leftImage: UIImage?, rightImage: UIImage?) {
        
        if let title = title {
            titleLabel.isHidden = false
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }
        
        if let rightImage = rightImage {
			rightShadowView.isHidden = false
            rightBarButton.isHidden = false
            rightBarButton.setImage(rightImage, for: .normal)
        } else {
            rightBarButton.isHidden = true
			rightShadowView.isHidden = true
        }
        
        if let leftImage = leftImage {
			leftShadowView.isHidden = false
            leftBarButton.isHidden = false
            leftBarButton.setImage(leftImage, for: .normal)
        } else {
            leftBarButton.isHidden = true
			leftShadowView.isHidden = true
        }
    }
    
    private func actionButtonsSetup() {
        
        leftBarButton.addTarget(self, action: #selector(didTapLeftBarButton(sender:)), for: .touchUpInside)
        rightBarButton.addTarget(self, action: #selector(didTapRightBarButton(sender:)), for: .touchUpInside)
    }
    
    @objc func didTapLeftBarButton(sender: UIButton) {
		self.leftBarButton.animateButtonTransform()
        delegate?.didTapLeftBarButton(_sender: sender)
    }
    
    @objc func didTapRightBarButton(sender: UIButton) {
		self.rightBarButton.animateButtonTransform()
        delegate?.didTapRightBarButton(_sender: sender)
    }
    
}
