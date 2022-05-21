//
//  SearchBarView.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.11.2021.
//

import UIKit

class SearchBarView: UIView {

	@IBOutlet var containerView: UIView!
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var trailingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingButtonConstraint: NSLayoutConstraint!
    
    private var shadowView = UIView()
    private var helperExtraView = UIView()
    
    public var searchBarIsActive: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
        self.setupSearchBar()
        self.updateColors()
        self.setupCancelButton()
        
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
        
        U.mainBundle.loadNibNamed(C.identifiers.views.searchBar, owner: self, options: nil)
    }
    
    
    private func configure() {
        
        self.addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        /// setup extra view for shadow
        helperExtraView.frame = self.bounds
        
        self.insertSubview(helperExtraView, at: 0)
        
        /// setup shadow
        let halfSize = self.frame.height / 2
        shadowView.frame = CGRect(x: 0, y: halfSize, width: U.screenWidth, height: halfSize)
        
        self.insertSubview(shadowView, at: 0)
        shadowView.layer.setShadow(color: theme.bottomShadowColor, alpha: 1, x: 2, y: 2, blur: 10, spread: 0)
        
        let baseBackgroundImage: UIImageView = UIImageView(image: I.systemItems.backroundStaticItems.spreadBackground)
        
        baseBackgroundImage.setCorner(14)
        baseView.addSubview(baseBackgroundImage)
        baseBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        baseBackgroundImage.leadingAnchor.constraint(equalTo: baseView.leadingAnchor).isActive = true
        baseBackgroundImage.trailingAnchor.constraint(equalTo: baseView.trailingAnchor).isActive = true
        baseBackgroundImage.topAnchor.constraint(equalTo: baseView.topAnchor).isActive = true
        baseBackgroundImage.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
    
        baseView.bringSubviewToFront(searchBar)
		
		reuseShadowView.isHidden = true
//		baseView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: .red, alpha: 1.0, x: 26, y: 3, blur: 10, corners: .allCorners, radius: 14)
		baseView.layer.applySketchShadow(color: UIColor().colorFromHexString("D8DFEB"), alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
        setShowCancelButton(false, animated: false)
		
		if let searchBar = self.searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchBar.value(forKey: "_clearButton") as? UIButton {
			clearButton.addTarget(self, action: #selector(didTapClearSearchTextFieldActionButton), for: .touchUpInside)
		}
    }
	
	@objc func didTapClearSearchTextFieldActionButton() {
		U.notificationCenter.post(name: .searchBarClearButtonClicked, object: nil)
	}
    
    private func setupCancelButton() {
        
        cancelButton.setTitle("cancel", for: .normal)
        cancelButton.setTitleColor(theme.contactsTintColor, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    @objc func didTapCancelButton() {
        searchBar.text = nil
        searchBar.endEditing(true)
        setShowCancelButton(false, animated: true)
        U.notificationCenter.post(name: .searchBarDidCancel, object: nil)
    }
    
    public func setShowCancelButton(_ showCancelButton: Bool, animated: Bool) {
        
        cancelButton.isEnabled = showCancelButton
        cancelButton.alpha = showCancelButton ? 1.0 : 0
		#warning("set for small screen other 90")
        leadingButtonConstraint.constant = showCancelButton ? 10 : 20
		trailingButtonConstraint.constant = showCancelButton ? 0 : -90
        
        if animated {
            U.animate(0.3) {
                self.cancelButton.layoutIfNeeded()
				self.baseView.layoutIfNeeded()
				self.reuseShadowView.layoutSubviews()
            }
        } else {
            self.cancelButton.layoutIfNeeded()
			self.baseView.layoutIfNeeded()
			self.reuseShadowView.layoutSubviews()
        }
    }
    
//    public func showCancelButtonProgress(_ offset: CGFloat) {
//        
//        let defaultHidenButtonConstraintValue: CGFloat = -90
//        let defaultSpaceValue: CGFloat = 20
//        
//        if offset <= 60 {
//            cancelButton.alpha = (offset * 1.68) / 100
//            trailingButtonConstraint.constant = defaultHidenButtonConstraintValue + offset * 1.5
//            leadingButtonConstraint.constant = defaultSpaceValue - offset * 0.4
//        } else if offset > 0 {
//            trailingButtonConstraint.constant = defaultHidenButtonConstraintValue - offset * 1.5
//            leadingButtonConstraint.constant = defaultSpaceValue + offset * 0.4
//            cancelButton.alpha = 1.0 - (offset * 1.68) / 100
//        }
//    }

    private func setupSearchBar() {

        searchBar.placeholder = "  search contacts here..."
        searchBar.barTintColor = theme.innerBackgroundColor
        searchBar.showsCancelButton = false
                
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            
            textField.backgroundColor = .clear
            textField.textColor = theme.titleTextColor.withAlphaComponent(0.7)
            textField.font = .systemFont(ofSize: 14, weight: .medium)
            
            if let leftView = textField.leftView as? UIImageView {
                
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = theme.titleTextColor.withAlphaComponent(0.7)
            }
        }
    }
    
    private func updateColors() {
        
        self.backgroundColor = theme.navigationBarBackgroundColor
        helperExtraView.backgroundColor = theme.navigationBarBackgroundColor
        shadowView.backgroundColor = theme.navigationBarBackgroundColor
    }
}
