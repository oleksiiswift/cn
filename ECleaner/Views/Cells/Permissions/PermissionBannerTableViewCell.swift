//
//  PermissionBannerTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import UIKit

class PermissionBannerTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
	
		setupUI()
		updateColors()
    }
}

extension PermissionBannerTableViewCell: Themeble {
	
	public func configureCell() {
		
		titleTextLabel.text = Localization.Main.HeaderTitle.permissionRequest
		subtitleTextLabel.text = Localization.Main.Descriptions.permissionDescription
	}
	
	private func setupUI() {
		selectionStyle = .none
		titleTextLabel.font = FontManager.permissionFont(of: .mainTitle)
		subtitleTextLabel.font = FontManager.permissionFont(of: .mainSubtitle)
		subtitleTextLabel.textAlignment = .natural
	}
	
	func updateColors() {
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.subTitleTextColor
	}
}
