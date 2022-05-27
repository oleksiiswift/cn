//
//  PermissionTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import UIKit

class PermissionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseRoundedShadowView: ReuseShadowRoundedView!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	@IBOutlet weak var permissionButton: UIButton!
	@IBOutlet weak var shadowButtonView: ReuseShadowView!
	@IBOutlet weak var roundedShadowViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var shadowButtonWidthConstraint: NSLayoutConstraint!
	private var subtitleCustomLabel = UILabel()
	
	public var permission: Permission?
	public var delegate: PermissionsActionsDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		subtitleTextLabel.isHidden = true
		subtitleCustomLabel.text = nil
		subtitleTextLabel.text = nil
    }
    
	@IBAction func didTapChangePermissionActionButton(_ sender: Any) {
		
		shadowButtonView.animateButtonTransform()
		permissionButton.animateButtonTransform()
		delegate?.permissionActionChange(at: self)
	}
}

extension PermissionTableViewCell {
	
	public func configure(with permission: Permission) {
		
		setupUI()
		updateColors()
		
		roundedShadowViewWidthConstraint.constant = AppDimensions.PermissionsCell.thumbnailDimensions
		reuseRoundedShadowView.layoutIfNeeded()
		reuseRoundedShadowView.updateImagesLayout()
		
		self.permission = permission
		self.setButtonState(for: permission)
		let imageSizeWidth = AppDimensions.PermissionsCell.thumbnailDimensions / 1.8
		let roundedShadowImageSize = CGSize(width: imageSizeWidth, height: imageSizeWidth)
		reuseRoundedShadowView.setImageWithCustomBackground(image: permission.permissionImage,
															tineColor: .white,
															size: roundedShadowImageSize,
															colors: permission.permissionAccentColors)
		titleTextLabel.font = FontManager.permissionFont(of: .title)
		titleTextLabel.text = permission.permissionName
		
		subtitleTextLabel.lineBreakMode = .byWordWrapping
	
		if Screen.size == .small {
			subtitleTextLabel.isHidden = true
			subtitleCustomLabel.text = permission.permissionDescription
			subtitleCustomLabel.numberOfLines = 0
			subtitleTextLabel.textAlignment = .justified
			baseView.addSubview(subtitleCustomLabel)
			subtitleCustomLabel.translatesAutoresizingMaskIntoConstraints = false
			subtitleCustomLabel.leadingAnchor.constraint(equalTo: titleTextLabel.leadingAnchor).isActive = true
			subtitleCustomLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20).isActive = true
			subtitleCustomLabel.topAnchor.constraint(equalTo: titleTextLabel.bottomAnchor, constant: -20).isActive = true
			subtitleCustomLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 10).isActive = true
			
			subtitleCustomLabel.layoutIfNeeded()
			shadowButtonView.removeConstraints(shadowButtonView.constraints)
			
			shadowButtonView.translatesAutoresizingMaskIntoConstraints = false
			shadowButtonView.widthAnchor.constraint(equalToConstant: AppDimensions.PermissionsCell.buttonWidth).isActive = true
			shadowButtonView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 15).isActive = true
			shadowButtonView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20).isActive = true
			shadowButtonView.heightAnchor.constraint(equalToConstant: 25).isActive = true
			permissionButton.translatesAutoresizingMaskIntoConstraints = false
			
			permissionButton.leadingAnchor.constraint(equalTo: shadowButtonView.leadingAnchor).isActive = true
			permissionButton.trailingAnchor.constraint(equalTo: shadowButtonView.trailingAnchor).isActive = true
			permissionButton.topAnchor.constraint(equalTo: shadowButtonView.topAnchor).isActive = true
			permissionButton.bottomAnchor.constraint(equalTo: shadowButtonView.bottomAnchor).isActive = true
			permissionButton.updateConstraints()
			permissionButton.layoutIfNeeded()
			shadowButtonView.layoutIfNeeded()
			shadowButtonView.layoutSubviews()
		} else {
			subtitleTextLabel.isHidden = false
			subtitleTextLabel.text = permission.permissionDescription
		}
	}
	
	public func setButtonState(for permission: Permission) {
		
		permissionButton.setTitle(permission.buttonTitle, for: .normal)
		permissionButton.setTitleColor(permission.buttonTitleColor, for: .normal)
	}
}

extension PermissionTableViewCell: Themeble {

	private func setupUI() {
		
		shadowButtonView.cornerRadius = 8
		selectionStyle = .none
		baseView.setCorner(14)
		subtitleTextLabel.font = FontManager.permissionFont(of: .subtitle)
		subtitleCustomLabel.font = FontManager.permissionFont(of: .subtitle)
		permissionButton.titleLabel?.font = FontManager.permissionFont(of: .permissionButton)
		subtitleTextLabel.sizeToFit()
	}
	
	func updateColors() {
		baseView.backgroundColor = .clear
		reuseRoundedShadowView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.subTitleTextColor
		subtitleCustomLabel.textColor = theme.subTitleTextColor
	}
}


