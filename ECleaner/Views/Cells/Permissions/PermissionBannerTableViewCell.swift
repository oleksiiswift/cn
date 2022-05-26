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
		
		titleTextLabel.text = "Permission Request"
		subtitleTextLabel.text = "These are the permissions the app requires to work properly. Please see description for each permission."
	}
	
	
	private func setupUI() {
		selectionStyle = .none
		titleTextLabel.font = .systemFont(ofSize: 28, weight: .black)
		subtitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
		subtitleTextLabel.textAlignment = .natural
		
		
	}
	
	func updateColors() {
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.subTitleTextColor
	}
}
