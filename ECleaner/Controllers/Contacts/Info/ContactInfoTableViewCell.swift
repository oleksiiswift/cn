//
//  ContactInfoTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import UIKit

class ContactInfoTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	
	@IBOutlet weak var fieldTitleTextLabel: UILabel!
	@IBOutlet weak var fieldValueTextLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		setupUI()
		updateColors()
    }
}

extension ContactInfoTableViewCell {
	
	public func configure(model: ContactModel) {
		
		switch model {
			case .fullName(let name):
				fieldTitleTextLabel.isHidden = true
				fieldValueTextLabel.text = name
			case .phoneNumbers(let phoneNumber):
				fieldTitleTextLabel.text = phoneNumber.label ?? ""
				fieldValueTextLabel.text = phoneNumber.value.stringValue
			case .emailAddresses(let emailAddress):
				fieldTitleTextLabel.text = emailAddress.label
				fieldValueTextLabel.text = emailAddress.label ?? ""
			case .urlAddresses(let url):
				fieldTitleTextLabel.text = url.label ?? ""
				fieldValueTextLabel.text = url.value as String
			default:
				return
		}
	}
}

extension ContactInfoTableViewCell: Themeble {
	
	private func setupUI() {
		
		selectionStyle = .none
		baseView.setCorner(14)
		
		fieldValueTextLabel.font = FontManager.contentTypeFont(of: .title)
		fieldTitleTextLabel.font = FontManager.contentTypeFont(of: .subtitle)
	}
	
	func updateColors() {
		
		fieldValueTextLabel.textColor = theme.titleTextColor
		fieldTitleTextLabel.textColor = theme.subTitleTextColor
	}
}
