//
//  FontManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.05.2022.
//

import UIKit

class FontManager {
	
	static var screenSize = Screen.size
	
	static func modalSettingsFont(of type: ModalSettingsFontType) -> UIFont {
		switch type {
			case .mainTitle:
				return Self.ModalSettings.mainTitleFont
			case .title:
				return Self.ModalSettings.titleFont
			case .subTitle:
				return Self.ModalSettings.subTitleFont
			case .butttons:
				return Self.ModalSettings.buttonsFont
			case .switchButtons:
				return Self.ModalSettings.switchButtonsFont
		}
	}
	
	static func navigationBarFont(of type: NavigationBarFontType) -> UIFont {
		switch type {
			case .title:
				return DefaultFonts.navigationTitleFont
			case .barButtonTitle:
				return DefaultFonts.navigationBarButtonItemFont
		}
	}
	
	static func drooDownMenuFont(of type: DromDownMenuFontType) -> UIFont {
		switch type {
			case .title:
				return DropDownMenu.titleFont
			case .subtitle:
				return DropDownMenu.subtitleFont
		}
	}
	
	static func contentTypeFont(of type: ContentFontType) -> UIFont {
		switch type {
			case .title:
				return ContentTypeCell.titleFont
			case .subtitle:
				return ContentTypeCell.subTitleFont
		}
	}
	
	static func collectionElementsFont(of type: CollectionElementsFontType, collectionType: CollectionType = .none) -> UIFont {
		switch type {
			case .title:
				return CollectionElements.grouppedHeaderTitleFont
			case .buttons:
				return CollectionElements.grouppedHeaderButtonFont
			case .sutitle:
				return CollectionElements.getVideoDurationFontSize(of: collectionType)
		}
	}
	
	static func pickerFont(of type: PickerTypeFont) -> UIFont {
		switch type {
			case .title:
				return PickerController.pickerFontSize
			case .subtitle:
				return PickerController.buttonSubTitleFontSize
		}
	}
	
	static func bannerFont(of type: ContentBannerFontType) -> UIFont {
		switch type {
			case .title:
				return ContentBunnerFontSize.titleFont
			case .subititle:
				return ContentBunnerFontSize.titleSubtitleFont
			case .descriptionTitle:
				return ContentBunnerFontSize.descriptionTitleFont
			case .descriptionFirstTitle:
				return ContentBunnerFontSize.descriptionFirstSubtitleFont
			case .descriptionSecontTitle:
				return ContentBunnerFontSize.descriptionSecondSubtitleFont
		}
	}
	
	static func bottomButtonFont(of type: BottomButtonFontType) -> UIFont {
		switch type {
			case .title:
				return BottomButton.bottomBarButtonTitleFont
			case .subtitle:
				return BottomButton.bottomBarButtonTitleFont
		}
	}
	
	static func deepCleanScreenFont(of type: DeepCleanFontType) -> UIFont {
		switch type {
			case .progress:
				return DeepClean.deepCleanCircleProgressPercentLabelFont
			case .title:
				return DeepClean.deepCleanInfoHelperTitleFont
			case .subtitle:
				return DeepClean.deepCleanInfoHelperSubtitleFont
			case .headerTitle:
				return DeepClean.deepClentSectionHeaderTitleFont
		}
	}
	
	static func contactsFont(of type: ContactsCleanFontType) -> UIFont {
		switch type {
			case .cellTitle:
				return Contacts.cellTitleFont
			case .cellSubtitle:
				return Contacts.cellSubtitleFont
			case .cellGroupCellHeaderTitle:
				return Contacts.cellGroupCellHeaderTitleFont
			case .headetTitle:
				return Contacts.headerTitleFont
			case .missingTitle:
				return Contacts.missingTitleFont
			case .missongSubtitle:
				return Contacts.missingSubTitleFont
			case .headerButonFont:
				return Contacts.headerButtonFont
			case .searchBarFont:
				return Contacts.searchBarFont
			case .cancelButtonTitle:
				return Contacts.cancelButtonFont
		}
	}
	
	static func exportModalFont(of type: ExportScreenFontType) -> UIFont {
		switch type {
			case .title:
				return ExportModal.navigationTitleFont
			case .buttons:
				return ExportModal.buttonTitle
		}
	}
	
	static func permissionFont(of type: PermissionFontType) -> UIFont {
		switch type {
			case .mainTitle:
				return PermissionFont.mainTitleFont
			case .mainSubtitle:
				return PermissionFont.mainSubtitleFont
			case .title:
				return PermissionFont.titleFont
			case .subtitle:
				return PermissionFont.subtitleFont
			case .permissionButton:
				return PermissionFont.permissionButton
			case .desctiption:
				return PermissionFont.descriptioFont
		}
	}
}
