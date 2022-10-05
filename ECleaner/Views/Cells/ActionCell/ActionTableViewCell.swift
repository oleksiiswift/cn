//
//  ActionTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.07.2022.
//

import UIKit

enum CellActionButton {
	case deleteContact
	
	var font: UIFont {
		switch self {
			case .deleteContact:
				return FontManager.contentTypeFont(of: .title)
		}
	}
	
	var title: String {
		switch self {
			case .deleteContact:
				return LocalizationService.Buttons.getButtonTitle(of: .delete)
		}
	}
	
	var tintColor: UIColor {
		switch self {
			case .deleteContact:
				return .red
		}
	}
}

protocol ActionTableCellDelegate {
	func didTapActionButton(at cell: ActionTableViewCell)
}

class ActionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var actionButton: UIButton!
	
	public var delegate: ActionTableCellDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		self.selectionStyle = .none
    }

	@IBAction func didTapActionButtoon(_ sender: Any) {
		actionButton.animateButtonTransform()
		delegate?.didTapActionButton(at: self)
	}
}

extension ActionTableViewCell {
	
	public func configureButton(with button: CellActionButton) {
		
		actionButton.titleLabel?.font = button.font
		actionButton.tintColor = button.tintColor
		actionButton.setTitle(button.title, for: .normal)
	}
}
