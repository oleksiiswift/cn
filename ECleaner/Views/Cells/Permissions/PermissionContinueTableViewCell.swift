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
		titleTextLabel.text = Localization.Main.Descriptions.permissionInfo
		
		titleTextLabel.font = FontManager.permissionFont(of: .desctiption)
		titleTextLabel.textAlignment = .natural
		bottomButtonBarView.delegate = self
		
		bottomButtonBarView.title(LocalizationService.Buttons.getButtonTitle(of: .continue).uppercased())
		let image = I.getPermissionImage(for: .blank)
		bottomButtonBarView.setButtonSideOffset(20)
		bottomButtonBarView.setImageRight(image, with: CGSize(width: 25, height: 25))
		let font = FontManager.bottomButtonFont(of: .title)
		bottomButtonBarView.setFont(font)
		if Screen.size == .small {
			bottomButtonBarView.setButtonHeight(50)
		}
	}
	
	func updateColors() {
		
		titleTextLabel.textColor = theme.subTitleTextColor
		
		let colors: [UIColor] = theme.onboardingButtonColors
		bottomButtonBarView.configureShadow = true
		bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonBarView.buttonTitleColor = theme.activeTitleTextColor
		bottomButtonBarView.layoutIfNeeded()
		
		bottomButtonBarView.addButtonShadow()
		bottomButtonBarView.addButtonGradientBackground(colors: colors)
		bottomButtonBarView.updateColorsSettings()
		bottomButtonBarView.actionButton.animateShakeHello()
	}
}

extension PermissionContinueTableViewCell: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		self.delegate?.didTapContinueButton()
	}
}
