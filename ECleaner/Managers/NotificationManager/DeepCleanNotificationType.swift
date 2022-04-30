//
//  DeepCleanNotificationType.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.12.2021.
//

import Foundation

enum DeepCleanNotificationType {
	
	case similarPhoto
	case duplicatePhoto
	case screenshots
	case similarSelfiePhotos
	case similarLivePhoto
	
	case largeVideo
	case duplicateVideo
	case similarVideo
	case screenRecordings
	
	case emptyContacts
	case duplicateContacts
	case duplicatedPhoneNumbers
	case duplicatedEmails
	
	case photoFilesSize
	case videoFilesSize
	
	case none
	
	var dictionaryCountName: String {
		switch self {
	 
			case .similarPhoto:
				return C.key.notificationDictionary.count.similarPhotoCount
			case .duplicatePhoto:
				return C.key.notificationDictionary.count.duplicatePhotoCount
			case .screenshots:
				return C.key.notificationDictionary.count.screenShotsCount
			case .similarSelfiePhotos:
				return C.key.notificationDictionary.count.similarSelfiePhotosCount
			case .similarLivePhoto:
				return C.key.notificationDictionary.count.livePhotosSimilarCount
			case .largeVideo:
				return C.key.notificationDictionary.count.largeVideoCount
			case .duplicateVideo:
				return C.key.notificationDictionary.count.duplicateVideoCount
			case .similarVideo:
				return C.key.notificationDictionary.count.similarVideoCount
			case .screenRecordings:
				return C.key.notificationDictionary.count.screenRecordingsCount
			case .emptyContacts:
				return C.key.notificationDictionary.count.emptyContactsCount
			case .duplicateContacts:
				return C.key.notificationDictionary.count.duplicateNamesContactsCount
			case .duplicatedPhoneNumbers:
				return C.key.notificationDictionary.count.duplicateNumbersContactsCount
			case .duplicatedEmails:
				return C.key.notificationDictionary.count.duplicateEmailsContactsCount
			case .photoFilesSize:
				return C.key.notificationDictionary.count.photoProcessingCount
			case .videoFilesSize:
				return C.key.notificationDictionary.count.videoProcessingCount
			case .none:
				return ""
		}
	}
	
	var dictionaryIndexName: String {
		
		switch self {
		
			case .similarPhoto:
				return C.key.notificationDictionary.index.similarPhotoIndex
			case .duplicatePhoto:
				return C.key.notificationDictionary.index.duplicatePhotoIndex
			case .screenshots:
				return C.key.notificationDictionary.index.screenShotsIndex
			case .similarSelfiePhotos:
				return C.key.notificationDictionary.index.similarSelfiePhotoIndex
			case .similarLivePhoto:
				return C.key.notificationDictionary.index.livePhotosIndex
			case .largeVideo:
				return C.key.notificationDictionary.index.largeVideoIndex
			case .duplicateVideo:
				return C.key.notificationDictionary.index.duplicateVideoIndex
			case .similarVideo:
				return C.key.notificationDictionary.index.similarVideoIndex
			case .screenRecordings:
				return C.key.notificationDictionary.index.screenRecordingsIndex
			case .emptyContacts:
				return C.key.notificationDictionary.index.emptyContactsIndex
			case .duplicateContacts:
				return C.key.notificationDictionary.index.duplicateNamesContactsIndex
			case .duplicatedPhoneNumbers:
				return C.key.notificationDictionary.index.duplicateNumbersContactsIndex
			case .duplicatedEmails:
				return C.key.notificationDictionary.index.duplicateEmailContactsIndex
			case .photoFilesSize:
				return C.key.notificationDictionary.index.photoProcessingIndex
			case .videoFilesSize:
				return C.key.notificationDictionary.index.videoProcessingIndex
			case .none:
				return ""
		}
	}
	
	var dictionaryProcessingState: String {
		switch self {
			case .similarPhoto:
				return C.key.notificationDictionary.state.similarPhotoState
			case .duplicatePhoto:
				return C.key.notificationDictionary.state.duplicatePhotoState
			case .screenshots:
				return C.key.notificationDictionary.state.screenShotsState
			case .similarSelfiePhotos:
				return C.key.notificationDictionary.state.similarSelfieState
			case .similarLivePhoto:
				return C.key.notificationDictionary.state.livePhotosState
			case .largeVideo:
				return C.key.notificationDictionary.state.largeVideoState
			case .duplicateVideo:
				return C.key.notificationDictionary.state.duplicateVideoState
			case .similarVideo:
				return C.key.notificationDictionary.state.similarVideoState
			case .screenRecordings:
				return C.key.notificationDictionary.state.screenRecordingsState
			case .emptyContacts:
				return C.key.notificationDictionary.state.emptyContactsState
			case .duplicateContacts:
				return C.key.notificationDictionary.state.duplicateNamesContactsState
			case .duplicatedPhoneNumbers:
				return C.key.notificationDictionary.state.duplicateNumbersContactsState
			case .duplicatedEmails:
				return C.key.notificationDictionary.state.duplicateEmailContactsState
			case .none:
				return ""
			default:
				return ""
		}
	}
	
	var dictionaryProcessingSizeValue: String {
		switch self {
			case .photoFilesSize:
				return C.key.notificationDictionary.value.photoFilesSizeValue
			case .videoFilesSize:
				return C.key.notificationDictionary.value.videoFileSizeValue
			default:
				return ""
		}
	}
	
	var notificationName: NSNotification.Name {
		switch self {
			case .similarPhoto:
				return .deepCleanSimilarPhotoPhassetScan
			case .duplicatePhoto:
				return .deepCleanDuplicatedPhotoPhassetScan
			case .screenshots:
				return .deepCleanScreenShotsPhassetScan
			case .similarSelfiePhotos:
				return .deepCleanSimilarSelfiesPhassetScan
			case .similarLivePhoto:
				return .deepCleanSimilarLivePhotosPhaassetScan
			case .largeVideo:
				return .deepCleanLargeVideoPhassetScan
			case .duplicateVideo:
				return .deepCleanDuplicateVideoPhassetScan
			case .similarVideo:
				return .deepCleanSimilarVideoPhassetScan
			case .screenRecordings:
				return .deepCleanScreenRecordingsPhassetScan
			case .emptyContacts:
				return .deepCleanEmptyContactsScan
			case .duplicateContacts:
				return .deepCleanDuplicatedContactsScan
			case .duplicatedPhoneNumbers:
				return .deepCleanDuplicatedPhoneNumbersScan
			case .duplicatedEmails:
				return .deepCleanDupLicatedMailsScan
			case .photoFilesSize:
				return .deepCleanPhotoFilesScan
			case  .videoFilesSize:
				return .deepCleanVideoFilesScan
			case .none:
				return NSNotification.Name("")
		}
	}
	
	var mediaTypeRawValue: PhotoMediaType {
		switch self {
			case .similarPhoto:
				return .similarPhotos
			case .duplicatePhoto:
				return .duplicatedPhotos
			case .screenshots:
				return .singleScreenShots
			case .similarSelfiePhotos:
				return .similarSelfies
			case .similarLivePhoto:
				return .similarLivePhotos
			case .largeVideo:
				return .singleLargeVideos
			case .duplicateVideo:
				return .duplicatedVideos
			case .similarVideo:
				return .similarVideos
			case .screenRecordings:
				return .singleScreenRecordings
			case .emptyContacts:
				return .emptyContacts
			case .duplicateContacts:
				return .duplicatedContacts
			case .duplicatedPhoneNumbers:
				return .duplicatedPhoneNumbers
			case .duplicatedEmails:
				return .duplicatedEmails
			case .none:
				return .none
			default:
				return .none
		}
	}
	
	var positionInDeepCleanRowValue: Int {
		switch self {
			case .similarPhoto:
				return 0
			case .duplicatePhoto:
				return 1
			case .screenshots:
				return 2
			case .similarSelfiePhotos:
				return 3
			case .similarLivePhoto:
				return 4
			case .largeVideo:
				return 5
			case .duplicateVideo:
				return 6
			case .similarVideo:
				return 7
			case .screenRecordings:
				return 8
			case .emptyContacts:
				return 9
			case .duplicateContacts:
				return 10
			case .duplicatedPhoneNumbers:
				return 11
			case .duplicatedEmails:
				return 12
			case .none:
				return 0
			default:
				return 0
		}
	}
}
