//
//  PermissionContinueTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import UIKit

class PermissionContinueTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
	
	public var delegate: PermissionsActionsDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setContinueButton(availible: true)
	}
}

extension PermissionContinueTableViewCell: Themeble {
	
	public func setContinueButton(availible: Bool) {
		
		bottomButtonBarView.actionButton.setbuttonAvailible(availible)
	}
	
	public func setupUI() {
		
		selectionStyle = .none
		titleTextLabel.text = "Permissions are necessary for the application to work and perform correctly."
		
		titleTextLabel.font = FontManager.permissionFont(of: .desctiption)
		titleTextLabel.textAlignment = .natural
		bottomButtonBarView.delegate = self
		
		bottomButtonBarView.title("Continue")
		bottomButtonBarView.actionButton.imageSize = CGSize(width: 25, height: 25)
		let image = I().getPermissionImage(for: .blank)
		bottomButtonBarView.setImage(image)
		
		let font = FontManager.bottomButtonFont(of: .title)
		bottomButtonBarView.setFont(font)
		if Screen.size == .small {
			bottomButtonBarView.setButtonHeight(50)
		}
	}
	
	func updateColors() {
		
		titleTextLabel.textColor = theme.subTitleTextColor
		bottomButtonBarView.buttonColor = theme.cellBackGroundColor
		bottomButtonBarView.buttonTintColor = theme.secondaryTintColor
		bottomButtonBarView.buttonTitleColor = theme.activeLinkTitleTextColor
		bottomButtonBarView.configureShadow = true
		bottomButtonBarView.addButtonShadow()
		bottomButtonBarView.updateColorsSettings()
		bottomButtonBarView.actionButton.animateShakeHello()
	}
}

extension PermissionContinueTableViewCell: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		self.delegate?.didTapContinueButton()
	}
}
