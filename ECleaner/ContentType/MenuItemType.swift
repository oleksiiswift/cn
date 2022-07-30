//
//  MenuItemType.swift
//  ECleaner
//
//  Created by alekseii sorochan on 05.07.2021.
//

import UIKit

enum MenuItemType {
	case select
	case deselect
	case layout
	case share
	case edit
	case delete
	case export
	
	case sortByDate
	case sortBySize
	case sortByDimension
	case sortByEdit
	case duration
	
	var rawValue: String {
		switch self {
			case .select:
				return LocalizationService.Buttons.getButtonTitle(of: .selectAll)
			case .deselect:
				return LocalizationService.Buttons.getButtonTitle(of: .deselectAll)
			case .layout:
				return LocalizationService.Buttons.getButtonTitle(of: .layout)
			case .share:
				return LocalizationService.Buttons.getButtonTitle(of: .share)
			case .edit:
				return LocalizationService.Buttons.getButtonTitle(of: .edit)
			case .delete:
				return LocalizationService.Buttons.getButtonTitle(of: .delete)
			case .export:
				return LocalizationService.Buttons.getButtonTitle(of: .export)
			case .sortByDate:
				return LocalizationService.Menu.getSortingTitle(of: .date)
			case .sortBySize:
				return LocalizationService.Menu.getSortingTitle(of: .size)
			case .sortByDimension:
				return LocalizationService.Menu.getSortingTitle(of: .dimension)
			case .sortByEdit:
				return LocalizationService.Menu.getSortingTitle(of: .edit)
			case .duration:
				return LocalizationService.Menu.getSortingTitle(of: .duration)
		}
	}
	
	var thumbnail: UIImage {
		return Images.getMenuItemImages(self)
	}
	
	var withCheckmark: Bool {
		switch self {
			case .sortByDate, .sortBySize, .sortByDimension, .edit, .duration:
				return true
			default:
				return false
		}
	}
}

struct MenuItem {
	var title: String
	var thumbnail: UIImage
	var selected: Bool
	var type: MenuItemType
	var isChecked: Bool
	
	var titleFont: UIFont = FontManager.drooDownMenuFont(of: .title)
	
	init(type: MenuItemType, selected: Bool, checkmark: Bool = false) {
		self.title = type.rawValue
		self.thumbnail = type.thumbnail
		self.selected = selected
		self.type = type
		self.isChecked = checkmark
	}
}

extension MenuItem {
	
	func sizeForFutureText() -> CGSize {
		return title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
	}
}
