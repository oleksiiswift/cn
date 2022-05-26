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
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		
        
    }
}


extension PermissionContinueTableViewCell: Themeble {
	
	public func setupUI() {
		
		selectionStyle = .none
		titleTextLabel.text = "Permissions are necessary for the application to work and perform correctly."
		
		titleTextLabel.font = .systemFont(ofSize: 13, weight: .bold)
		titleTextLabel.textAlignment = .natural
		bottomButtonBarView.delegate = self
		
		bottomButtonBarView.title("Continue")
		bottomButtonBarView.actionButton.imageSize = CGSize(width: 25, height: 25)
		let image = I().getPermissionImage(for: .blank)
		bottomButtonBarView.setImage(image)
		
		if Screen.size == .small {
			bottomButtonBarView.setFont(.systemFont(ofSize: 14, weight: .bold))
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
	}
}

extension PermissionContinueTableViewCell: BottomActionButtonDelegate {
	
	
	func didTapActionButton() {
		
	}
}
