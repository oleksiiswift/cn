//
//  PhotoMediaType.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import Foundation
import AVFoundation

enum PhotoMediaType: String {
    
        /// `photo section`
    case similarPhotos = 				"similarPhotos"
    case duplicatedPhotos = 			"duplicatedPhotos"
    case singleScreenShots = 			"singleScreenShots"
    case singleLivePhotos = 			"singleLivePhotos"
    case similarLivePhotos = 			"similarLivePhotos"
    case similarSelfies = 				"similarSelfies"
    case singleRecentlyDeletedPhotos = 	"singleRecentlyDeletedPhotos"
	case locationPhoto =				"locationPhotos"

        /// `video section section`
    case singleLargeVideos = 			"singleLargeVideos"
    case duplicatedVideos = 			"duplicatedVideos"
    case similarVideos = 				"similarVideos"
    case singleScreenRecordings = 		"singleScreenRecordings"
    case singleRecentlyDeletedVideos =  "singleRecentlyDeletedVideos"
    case compress = 					"compress video"
        
        /// `contacts section`
    case allContacts = 					"allContacts"
    case emptyContacts = 				"emptyContacts"
    case duplicatedContacts = 			"duplicatedContacts"
    case duplicatedPhoneNumbers = 		"duplicatedPhoneNumbers"
    case duplicatedEmails = 			"duplicatedEmails"
	case backup = 						"backup"
    
    case none = 						""
	
	var contenType: MediaContentType {
		switch self {
			case .similarPhotos, .duplicatedPhotos, .singleScreenShots, .singleLivePhotos, .similarLivePhotos, .similarSelfies, .singleRecentlyDeletedPhotos, .locationPhoto:
				return .userPhoto
			case .singleLargeVideos, .duplicatedVideos, .similarVideos, .singleScreenRecordings, .singleRecentlyDeletedVideos, .compress:
				return .userVideo
			case .allContacts, .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails, .backup:
				return .userContacts
			default:
				return .none
		}
	}
	
	var collectionType: CollectionType {
		switch self {
			case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarSelfies:
				return .grouped
			case .singleScreenShots, .singleLivePhotos:
				return .single
			case .singleLargeVideos, .singleScreenRecordings:
				return .single
			case .duplicatedVideos, .similarVideos:
				return .grouped
			case .allContacts, .emptyContacts:
				return .single
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return .grouped
			default:
				return .none
		}
	}
    
        /// `name`
    var mediaTypeName: String {
		return LocalizationService.MediaContent.getContentName(of: self)
    }
	
	var cleanOperationName: String {
		switch self {
			case .similarPhotos:
				return C.key.operation.name.similarPhotoProcessingOperation
			case .duplicatedPhotos:
				return C.key.operation.name.duplicatePhotoProcessingOperation
			case .singleScreenShots:
				return C.key.operation.name.screenShotsOperation
			case .singleLivePhotos:
				return C.key.operation.name.livePhotoOperation
			case .similarLivePhotos:
				return C.key.operation.name.similarLivePhotoProcessingOperation
			case .similarSelfies:
				return C.key.operation.name.similarSelfiesOperation
			case .singleLargeVideos:
				return C.key.operation.name.largeVideo
			case .duplicatedVideos:
				return C.key.operation.name.duplicateVideoProcessingOperation
			case .similarVideos:
				return C.key.operation.name.similarVideoProcessingOperation
			case .singleScreenRecordings:
				return C.key.operation.name.screenRecordingOperation
			default:
				return ""
		}
	}
	
	var emptyContentError: ErrorHandler.EmptyResultsError {
		switch self {
			case .similarPhotos: 			return .similarPhotoIsEmpty
			case .duplicatedPhotos: 		return .duplicatedPhotoIsEmpty
			case .singleScreenShots: 		return .screenShotsIsEmpty
			case .singleLivePhotos: 		return .livePhotoIsEmpty
			case .similarLivePhotos: 		return .similarLivePhotoIsEmpty
			case .similarSelfies: 			return .similarSelfiesIsEmpty
			case .locationPhoto:			return .photoWithLocationIsEmpty
			case .singleLargeVideos: 		return .largeVideoIsEmpty
			case .duplicatedVideos: 		return .duplicatedVideoIsEmpty
			case .similarVideos: 			return .similarVideoIsEmpty
			case .singleScreenRecordings: 	return .screenRecordingIsEmpty
			case .allContacts: 				return .contactsIsEmpty
			case .emptyContacts: 			return .emptyContactsIsEmpty
			case .duplicatedContacts: 		return .duplicatedNamesIsEmpty
			case .duplicatedPhoneNumbers: 	return .duplicatedNumbersIsEmpty
			case .duplicatedEmails: 		return .duplicatedEmailsIsEmpty
			default: 						return .photoLibrararyIsEmpty
		}
	}

        /// `use this only for deep clean screen section:
    var deepCleanIndexPath: IndexPath {
     
        switch self {
            case .similarPhotos:
                return IndexPath(row: 0, section: 1)
            case .duplicatedPhotos:
                return IndexPath(row: 1, section: 1)
            case .singleScreenShots:
                return IndexPath(row: 2, section: 1)
			case.similarSelfies:
				return IndexPath(row: 3, section: 1)
            case .similarLivePhotos:
                return IndexPath(row: 4, section: 1)
            case .singleLargeVideos:
                return IndexPath(row: 0, section: 2)
            case .duplicatedVideos:
                return IndexPath(row: 1, section: 2)
            case .similarVideos:
                return IndexPath(row: 2, section: 2)
            case .singleScreenRecordings:
                return IndexPath(row: 3, section: 2)
            case .emptyContacts:
                return IndexPath(row: 0, section: 3)
            case .duplicatedContacts:
                return IndexPath(row: 1, section: 3)
            case .duplicatedPhoneNumbers:
                return IndexPath(row: 2, section: 3)
            case .duplicatedEmails:
                return IndexPath(row: 3, section: 3)
            default:
                return IndexPath()
        }
    }
    
        ///  `ùse this for single search index path`
        
    var singleSearchIndexPath: IndexPath {
        switch self {
            case .similarPhotos:
                return IndexPath(row: 0, section: 0)
            case .duplicatedPhotos:
                return IndexPath(row: 1, section: 0)
            case .singleScreenShots:
                return IndexPath(row: 2, section: 0)
			case .similarSelfies:
				return IndexPath(row: 3, section: 0)
            case .singleLivePhotos:
                return IndexPath(row: 4, section: 0)
			case .singleRecentlyDeletedPhotos:
				return IndexPath(row: 5, section: 0)
            case .singleLargeVideos:
                return IndexPath(row: 0, section: 0)
            case .duplicatedVideos:
                return IndexPath(row: 1, section: 0)
            case .similarVideos:
                return IndexPath(row: 2, section: 0)
            case .singleScreenRecordings:
                return IndexPath(row: 3, section: 0)

            case .singleRecentlyDeletedVideos:
                return IndexPath(row: 4, section: 0)
                
                /// `contacts`
            case .allContacts:
                return IndexPath(row: 0, section: 0)
            case .emptyContacts:
                return IndexPath(row: 1, section: 0)
            case .duplicatedContacts:
                return IndexPath(row: 2, section: 0)
            case .duplicatedPhoneNumbers:
                return IndexPath(row: 3, section: 0)
            case .duplicatedEmails:
                return IndexPath(row: 4, section: 0)
			default:
                return IndexPath()
        }
    }
	
	var contactsCleaningType: ContactasCleaningType {
		switch self {
			case .emptyContacts:
				return .emptyContacts
			case .duplicatedContacts:
				return .duplicatedContactName
			case .duplicatedPhoneNumbers:
				return .duplicatedPhoneNumnber
			case .duplicatedEmails:
				return .duplicatedEmail
			default:
				return .none
		}
	}
    
    /// `use this only for deep clean screen section:
    public static func getDeepCleanMediaContentType(from indexPath: IndexPath) -> PhotoMediaType {
        
        switch indexPath.section {
            case 1:
                /// `photo section`
                switch indexPath.row {
                    case 0:
                        return .similarPhotos
                    case 1:
                        return .duplicatedPhotos
                    case 2:
                        return .singleScreenShots
					case 3:
						return .similarSelfies
                    case 4:
                        return .similarLivePhotos
                    default:
                        return .none
                }
            case 2:
                /// `video section`
                switch indexPath.row {
                    case 0:
                        return .singleLargeVideos
                    case 1:
                        return .duplicatedVideos
                    case 2:
                        return .similarVideos
                    case 3:
                        return .singleScreenRecordings
                    default:
                        return .none
                }
            case 3:
                /// `contats section`
                switch indexPath.row {
                    case 0:
                        return .emptyContacts
                    case 1:
                        return .duplicatedContacts
                    case 2:
                        return .duplicatedPhoneNumbers
                    case 3:
                        return .duplicatedEmails
                    default:
                        return .none
                }
            default:
                return .none
        }   
    }
    
    public static func getSingleSearchMediaContentType(from indexPath: IndexPath, type: MediaContentType) -> PhotoMediaType {
        
        switch type {
            case .userPhoto:
				switch indexPath.section {
					case 0:
						switch indexPath.row {
							case 0:
								return .similarPhotos
							case 1:
								return .duplicatedPhotos
							case 2:
								return .singleScreenShots
							case 3:
								return .similarSelfies
							case 4:
								return .singleLivePhotos
							default:
								return .none
						}
					case 1:
						return .locationPhoto
					default:
						return .none
				}
            case .userVideo:
				switch indexPath.section {
					case 0:
						switch indexPath.row {
							case 0:
								return .singleLargeVideos
							case 1:
								return .duplicatedVideos
							case 2:
								return .similarVideos
							case 3:
								return .singleScreenRecordings
							default:
								return .none
						}
					case 1:
						return .compress
					default:
						return .none
				}
            case .userContacts:
				switch indexPath.section {
					case 0:
						switch indexPath.row {
							case 0:
								return .allContacts
							case 1:
								return .emptyContacts
							case 2:
								return .duplicatedContacts
							case 3:
								return .duplicatedPhoneNumbers
							case 4:
								return .duplicatedEmails
							default:
								return .none
						}
					case 1:
						return .backup
					default:
						return .none
				}
            case .none:
                return .none
        }
    }
	
	var bannerInfo: ContentBannerInfoModel {
		
		var info: [PhotoMediaType: BannerInfo] = [:]
		
		let locationBannerInfo: BannerInfo = BannerInfo(infoImage: I.systemItems.defaultItems.compress,
														title: Localization.Main.BannerHelpers.Title.videoTitle,
														subtitle: Localization.Main.BannerHelpers.Subtitle.videoSubtitle,
														descriptionTitle: Localization.Main.BannerHelpers.Description.videoDescription,
														descriptitionFirstPartSubtitle: Localization.Main.BannerHelpers.Description.videoDescriptionOne,
														descriptionSecondPartSubtitle: Localization.Main.BannerHelpers.Description.videoDescriptionTwo,
														helperImage: I.personalisation.video.bannerHelperImage,
														gradientColors: ThemeManager.theme.compressionGradient)
		
		let compressionBannerInfo: BannerInfo = BannerInfo(infoImage: I.systemItems.defaultItems.compress,
														   title: Localization.Main.BannerHelpers.Title.videoTitle,
														   subtitle: Localization.Main.BannerHelpers.Subtitle.videoSubtitle,
														   descriptionTitle: Localization.Main.BannerHelpers.Description.videoDescription,
														   descriptitionFirstPartSubtitle: Localization.Main.BannerHelpers.Description.videoDescriptionOne,
														   descriptionSecondPartSubtitle: Localization.Main.BannerHelpers.Description.videoDescriptionTwo,
														   helperImage: I.personalisation.video.bannerHelperImage,
														   gradientColors: ThemeManager.theme.compressionGradient)
		
		let syncContactsBannerInfo: BannerInfo = BannerInfo(infoImage: I.systemItems.defaultItems.compress,
															title: Localization.Main.BannerHelpers.Title.contactTitle,
															subtitle: Localization.Main.BannerHelpers.Subtitle.contactsSubtitle,
															descriptionTitle: Localization.Main.BannerHelpers.Description.contactsDescription,
															descriptitionFirstPartSubtitle: Localization.Main.BannerHelpers.Description.contactsDescriptionOne,
															descriptionSecondPartSubtitle: Localization.Main.BannerHelpers.Description.contactsDescriptionTwo,
															helperImage: I.personalisation.contacts.bannerHelperImage,
															gradientColors: ThemeManager.theme.backupGradient)
		info[.locationPhoto] = locationBannerInfo
		info[.compress] = compressionBannerInfo
		info[.backup] = syncContactsBannerInfo
		return ContentBannerInfoModel(info: info)
	}
}





