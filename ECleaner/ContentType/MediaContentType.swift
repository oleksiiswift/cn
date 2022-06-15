//
//  MediaContentType.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit

enum MediaContentType {
    
    case userPhoto
    case userVideo
    case userContacts
    case none
    
    var navigationTitle: String {
		return self.mediaContentTypeName.uppercased()
    }
	
	var mediaContentTypeName: String {
		switch self {
			case .userPhoto:
				return LocalizationService.Main.getNavigationTitle(for: .photoClean)
			case .userVideo:
				return LocalizationService.Main.getNavigationTitle(for: .videoClean)
			case .userContacts:
				return LocalizationService.Main.getNavigationTitle(for: .contactClean)
			case .none:
				return ""
		}
	}
	
	var mediaContenTypeImage: UIImage {
		switch self {
			case .userPhoto:
				return I.mainStaticItems.photo
			case .userVideo:
				return I.mainStaticItems.video
			case .userContacts:
				return I.mainStaticItems.contacts
			case .none:
				return UIImage()
		}
	}
    
    var screenAcentTintColor: UIColor {
        
        let theme = ThemeManager.theme
        
        switch self {
            case .userPhoto:
                return theme.photoTintColor
            case .userVideo:
                return theme.videosTintColor
            case .userContacts:
                return theme.contactsTintColor
            case .none:
                return theme.defaulTintColor
        }
    }
	
	var screeAcentGradientColorSet: [CGColor] {
		let theme = ThemeManager.theme
		
		switch self {
			case .userPhoto:
				return [theme.photoTopGradientColor.cgColor, theme.photoBottomGradientColor.cgColor]
			case .userVideo:
				return [theme.videoTopGradientColor.cgColor, theme.videoBottomGradientColor.cgColor]
			case .userContacts:
				return [theme.contactTopGradientColor.cgColor, theme.contactBottomGradientColor.cgColor]
			case .none:
				return [UIColor.clear.cgColor, UIColor.clear.cgColor]
		}
	}
	
	var screeAcentGradientUICoror: [UIColor] {
		let theme = ThemeManager.theme
		
		switch self {
			case .userPhoto:
				return theme.photoGradient
			case .userVideo:
				return theme.videoGradient
			case .userContacts:
				return theme.contactsGradient
			case .none:
				return [UIColor.clear, UIColor.clear]
		}
	}
	
	var selectableAssetsCheckMark: UIImage {
		switch self {
			case .userPhoto:
				return I.personalisation.photo.checkmark
			case .userVideo:
				return I.personalisation.video.checkmark
			case .userContacts:
				return I.personalisation.contacts.sectionSelect
			case .none:
				return UIImage()
		}
	}
	
        /// ``MAIN SCREEN CONTENT TYPE PROPERTIES``
    
    var mainScreenIndexPath: IndexPath {
        switch self {
            case .userPhoto:
                return IndexPath(row: 0, section: 0)
            case .userVideo:
                return IndexPath(row: 1, section: 0)
            case .userContacts:
                return IndexPath(row: 2, section: 0)
            case .none:
                return IndexPath()
        }
    }
    
    
    var processingImageOfRows: UIImage {
        switch self {
            case .userPhoto:
                return I.personalisation.photo.processingThumb
            case .userVideo:
                return I.personalisation.video.processingThumb
            case .userContacts:
                return I.personalisation.contacts.processingThumb
            case .none:
                return UIImage()
        }
    }
	
	var sections: [PhotoMediaType] {
		switch self {
			case .userPhoto:
				return [.similarPhotos,
						.duplicatedPhotos,
						.singleScreenShots,
						.similarSelfies,
						.singleLivePhotos]
			case .userVideo:
				return [.singleLargeVideos,
						.duplicatedVideos,
						.similarVideos,
						.singleScreenRecordings]
			case .userContacts:
				return [.allContacts,
						.emptyContacts,
						.duplicatedContacts,
						.duplicatedPhoneNumbers,
						.duplicatedEmails]
			case .none:
				return [.none] 
		}
	}
        
        /// `SECTION PROPERTIES`
    var numberOfSection: Int {
		switch self {
			case .userVideo:
				return 2
			case .userContacts:
				return 2
			default:
				return 1
		}
    }

    var imageOfRows: UIImage {
        switch self {
            case .userPhoto:
                return I.mainStaticItems.photo
            case .userVideo:
                return I.mainStaticItems.video
            case .userContacts:
                return I.mainStaticItems.contacts
            case .none:
                return UIImage()
        }
    }
    
    var unAbleImageOfRows: UIImage {
        switch self {
            case .userPhoto:
                return I.personalisation.photo.unavailibleThumb
            case .userVideo:
                return I.personalisation.video.unavailibleThumb
            case .userContacts:
                return I.personalisation.contacts.unavailibleThumb
            case .none:
                return UIImage()
        }
    }
	
	var checkedImageOfRows: UIImage {
		switch self {
			case .userPhoto:
				return I.personalisation.photo.checkmark
			case .userVideo:
				return I.personalisation.video.checkmark
			case .userContacts:
				return I.personalisation.contacts.sectionSelect
			case .none:
				return UIImage()
		}
	}
    
    public func getCellTitle(index: Int) -> String {
        switch self {
            case .userPhoto:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .similarPhotos)
                    case 1:
                        return LocalizationService.MediaContent.getContentName(of: .duplicatedPhotos)
                    case 2:
                        return LocalizationService.MediaContent.getContentName(of: .singleScreenShots)
                    case 3:
						return LocalizationService.MediaContent.getContentName(of: .similarSelfies)
                    case 4:
                        return LocalizationService.MediaContent.getContentName(of: .singleLivePhotos)
                    default:
                        return ""
                }
            case .userVideo:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .singleLargeVideos)
                    case 1:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedVideos)
                    case 2:
						return LocalizationService.MediaContent.getContentName(of: .similarVideos)
                    case 3:
						return LocalizationService.MediaContent.getContentName(of: .singleScreenRecordings)
                    default:
                        return ""
                }
            case .userContacts:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .allContacts)
                    case 1:
						return LocalizationService.MediaContent.getContentName(of: .emptyContacts)
                    case 2:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedContacts)
                    case 3:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedPhoneNumbers)
                    case 4:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedEmails)
                    default:
                        return ""
                }
            case .none:
                return ""
        }
    }
	
	public func getNumbersOfRows(for section: Int) -> Int {
		switch section {
			case 1:
				return 1
			default:
				switch self {
					case .userPhoto:
						return 5
					case .userVideo:
						return 4
					case .userContacts:
						return 5
					case .none:
						return 0
				}
		}
	}
	
	public func getRowHeight(for section: Int) -> CGFloat {
		switch self {
			case .userVideo, .userContacts:
				switch section {
					case 1:
						return U.UIHelper.AppDimensions.ContenTypeCells.heightOfBottomHelperCellBanner
					default:
						return U.UIHelper.AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType
				}
			default:
				return U.UIHelper.AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType
		}
	}
    
        /// ``DEEP CLEAN PROPERTIES``
    
    var deepCleanNumbersOfRows: Int {
        switch self {
            case .userPhoto:
                return 5
            case .userVideo:
                return 4
            case .userContacts:
                return 4
            default:
                return 0
        }
    }

    public func getDeepCellTitle(index: Int) -> String {
        switch self {
            case .userPhoto:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .similarPhotos)
                    case 1:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedPhotos)
                    case 2:
						return LocalizationService.MediaContent.getContentName(of: .singleScreenShots)
					case 3:
						return LocalizationService.MediaContent.getContentName(of: .similarSelfies)
                    case 4:
						return LocalizationService.MediaContent.getContentName(of: .similarLivePhotos)
                    default:
                        return ""
                }
            case .userVideo:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .singleLargeVideos)
                    case 1:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedVideos)
                    case 2:
						return LocalizationService.MediaContent.getContentName(of: .similarVideos)
                    case 3:
						return LocalizationService.MediaContent.getContentName(of: .singleScreenRecordings)
                    default:
                        return ""
                }
            case .userContacts:
                switch index {
                    case 0:
						return LocalizationService.MediaContent.getContentName(of: .emptyContacts)
                    case 1:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedContacts)
                    case 2:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedPhoneNumbers)
                    case 3:
						return LocalizationService.MediaContent.getContentName(of: .duplicatedEmails)
                    default:
                        return ""
                }
            case .none:
                return ""
        }
    }
    
    public static func getDeepCleanSectionType(indexPath: IndexPath) -> MediaContentType {
        
        switch indexPath.section {
            case 1:
                return .userPhoto
            case 2:
                return .userVideo
            case 3:
                return .userContacts
            default:
                return .none
        }
    }
    
    public static func getMediaContentType(at section: Int) -> MediaContentType {
        
        switch section {
            case 1:
                return .userPhoto
            case 2:
                return .userVideo
            case 3:
                return .userContacts
            default:
                return .none
        }
    }
}
