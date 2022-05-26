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
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subtitle: UILabel!
	@IBOutlet weak var reuseShadowbuttonView: ReuseShadowView!
	
	@IBOutlet weak var permissionButton: UIButton!
	@IBOutlet weak var shadowButtonView: ReuseShadowView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
    }
    
	@IBAction func didTapChangePermissionActionButton(_ sender: Any) {
		
		shadowButtonView.animateButtonTransform()
		permissionButton.animateButtonTransform()
		
	}
}

extension PermissionTableViewCell {
	
	public func configure(with permission: Permission) {
	
		title.text = permission.permissionName
		subtitle.text = permission.permissionDescription
	
		self.setButtonState(for: permission)
		reuseRoundedShadowView.setImageWithCustomBackground(image: permission.permissionImage,
															tineColor: .white,
															size: CGSize(width: 25, height: 25),
															colors: permission.permissionAccentColors)
	}
	
	private func setButtonState(for permission: Permission) {
		
		permissionButton.setTitle(permission.buttonTitle, for: .normal)
		permissionButton.setTitleColor(permission.buttonTitleColor, for: .normal)
	}
}


extension PermissionTableViewCell: Themeble {
	
	
	private func setupUI() {
		
		selectionStyle = .none
		baseView.setCorner(14)
		shadowButtonView.cornerRadius = 8
		title.font = FontManager.contentTypeFont(of: .title)
		subtitle.font = FontManager.contentTypeFont(of: .subtitle)
		permissionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
	}
	
	func updateColors() {
		baseView.backgroundColor = .clear
		reuseRoundedShadowView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
		title.textColor = theme.titleTextColor
		subtitle.textColor = theme.subTitleTextColor
	}
}


