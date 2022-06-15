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
	@IBOutlet weak var cancelButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var trailingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingButtonConstraint: NSLayoutConstraint!
	@IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
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
        
		cancelButtonHeightConstraint.constant = U.UIHelper.AppDimensions.Contacts.SearchBar.searchBarHeight
		searchBarBottomConstraint.constant = U.UIHelper.AppDimensions.Contacts.SearchBar.searchBarBottomInset
		
        self.addSubview(containerView)
        containerView.frame = self.bounds
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        /// setup extra view for shadow
        helperExtraView.frame = self.bounds
        
        self.insertSubview(helperExtraView, at: 0)
        
        /// setup shadow
        let halfSize = self.frame.height / 2
		self.layoutIfNeeded()
        shadowView.frame = CGRect(x: 0, y: halfSize, width: U.screenWidth, height: halfSize)
        
        self.insertSubview(shadowView, at: 0)
	
        shadowView.layer.setShadow(color: theme.bottomShadowColor, alpha: 1, x: 3, y: 0, blur: 10, spread: 0)
		
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
        
		cancelButton.setTitle(LocalizationService.Buttons.getButtonTitle(of: .cancel), for: .normal)
        cancelButton.setTitleColor(theme.contactsTintColor, for: .normal)
		cancelButton.titleLabel?.font = FontManager.contactsFont(of: .cancelButtonTitle)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
		cancelButtonWidthConstraint.constant = U.UIHelper.AppDimensions.Contacts.SearchBar.cancelButtonWidth
    }
    
    @objc func didTapCancelButton() {
        searchBar.text = nil
        searchBar.endEditing(true)
        setShowCancelButton(false, animated: true)
        U.notificationCenter.post(name: .searchBarDidCancel, object: nil)
    }
    
    public func setShowCancelButton(_ showCancelButton: Bool, animated: Bool) {
        
		searchBarLeadingConstraint.constant = 20
		cancelButton.isEnabled = false
		U.delay(0.5) {
			self.cancelButton.isEnabled = showCancelButton
		}
		
        cancelButton.alpha = showCancelButton ? 1.0 : 0
        leadingButtonConstraint.constant = showCancelButton ? 0 : 20
		trailingButtonConstraint.constant = showCancelButton ? 5 : -U.UIHelper.AppDimensions.Contacts.SearchBar.cancelButtonWidth
        
        if animated {
            U.animate(0.3) {
                self.cancelButton.layoutIfNeeded()
				self.baseView.layoutIfNeeded()
				self.reuseShadowView.layoutSubviews()
				self.containerView.layoutIfNeeded()
            }
        } else {
            self.cancelButton.layoutIfNeeded()
			self.baseView.layoutIfNeeded()
			self.reuseShadowView.layoutSubviews()
			self.containerView.layoutIfNeeded()
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

		searchBar.placeholder = Localization.Main.Subtitles.searchHere
        searchBar.barTintColor = theme.innerBackgroundColor
        searchBar.showsCancelButton = false
                
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            
            textField.backgroundColor = .clear
            textField.textColor = theme.titleTextColor.withAlphaComponent(0.7)
			textField.font = FontManager.contactsFont(of: .searchBarFont)
            
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
