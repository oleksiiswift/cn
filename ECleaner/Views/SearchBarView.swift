//
//  SearchBarView.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.11.2021.
//

import UIKit

class SearchBarView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    
    private var shadowView = UIView()
    private var helperExtraView = UIView()

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
        shadowView.layer.setShadow(color: theme.bottomShadowColor, alpha: 1, x: 3, y: 0, blur: 10, spread: 0)
        
        let baseBackgroundImage: UIImageView = UIImageView(image: I.systemItems.backroundStatic.spreadBackground)
        
        baseBackgroundImage.setCorner(14)
        baseView.addSubview(baseBackgroundImage)
        baseBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        baseBackgroundImage.leadingAnchor.constraint(equalTo: baseView.leadingAnchor).isActive = true
        baseBackgroundImage.trailingAnchor.constraint(equalTo: baseView.trailingAnchor).isActive = true
        baseBackgroundImage.topAnchor.constraint(equalTo: baseView.topAnchor).isActive = true
        baseBackgroundImage.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
    
        baseView.layer.setShadowAndCustomCorners(backgroundColor: .clear, shadow: theme.sideShadowColor, alpha: 1.0, x: 6, y: 6, blur: 10, corners: .allCorners, radius: 14)
        
        baseView.bringSubviewToFront(searchBar)
        
        setShowCancelButton(false, animated: false)
    }
    
    private func setupCancelButton() {
        
        cancelButton.setTitle("cancel", for: .normal)
        cancelButton.setTitleColor(theme.contactsTintColor, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    @objc func didTapCancelButton() {
        
        setShowCancelButton(false, animated: true)
        
    }
    
    public func setShowCancelButton(_ showCancelButton: Bool, animated: Bool) {
        
        cancelButton.isEnabled = showCancelButton
        cancelButtonWidthConstraint.constant = showCancelButton ? 90 : 0
        cancelButton.alpha = showCancelButton ? 1.0 : 0
        
        if animated {
            self.animateLayout()
        } else {
            self.baseView.layoutIfNeeded()
            self.cancelButton.layoutIfNeeded()
        }
    }
    
    private func animateLayout() {
        
        U.animate(1.0) {
            self.baseView.layoutIfNeeded()
            self.cancelButton.layoutIfNeeded()
        }
    }
    
    
    private func setupSearchBar() {
    
//        searchBar.searchBarStyle = .minimal
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
