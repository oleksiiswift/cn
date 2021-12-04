//
//  SingleContentSearchNotificationType.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.12.2021.
//

import Foundation

enum SingleContentSearchNotificationType {
	
	/// `photo search`
	case similarPhoto
	case duplicatedPhoto
	case similarLivePhoto
	case screenShots
	case selfies
	case livePhoto
	case recentlyDeletedPhoto
	
	/// `video search`
	case largeVideo
	case duplicatedVideo
	case similarVideo
	case screenRecordings
	case recentlyDeletedVideo
	
	///  `contacts search`
	case allContacts
	case emptyContacts
	case duplicatesNames
	case duplicatesNumbers
	case duplicatesEmails
	
	case none
	
	var dictionaryCountName: String {
		
		switch self {
				/// `photo`
			case .similarPhoto:
				return C.key.notificationDictionary.count.similarPhotoCount
			case .duplicatedPhoto:
				return C.key.notificationDictionary.count.duplicatePhotoCount
			case .similarLivePhoto:
				return C.key.notificationDictionary.count.livePhotosSimilarCount
			case .screenShots:
				return C.key.notificationDictionary.count.screenShotsCount
			case .selfies:
				return C.key.notificationDictionary.count.selfiePhotosCount
			case .livePhoto:
				return C.key.notificationDictionary.count.livePhotosSimilarCount
			case .recentlyDeletedPhoto:
				return C.key.notificationDictionary.count.recentlyDeletedPhotoCount
				/// `video`
			case .largeVideo:
				return C.key.notificationDictionary.count.largeVideoCount
			case .duplicatedVideo:
				return C.key.notificationDictionary.count.duplicateVideoCount
			case .similarVideo:
				return C.key.notificationDictionary.count.similarVideoCount
			case .screenRecordings:
				return C.key.notificationDictionary.count.screenRecordingsCount
			case .recentlyDeletedVideo:
				return C.key.notificationDictionary.count.recentlyDeletedVideoCount
				/// `contacts`
			case .allContacts:
				return C.key.notificationDictionary.count.allContactsCount
			case .emptyContacts:
				return C.key.notificationDictionary.count.emptyContactsCount
			case .duplicatesNames:
				return C.key.notificationDictionary.count.duplicateNamesContactsCount
			case .duplicatesNumbers:
				return C.key.notificationDictionary.count.duplicateNumbersContactsCount
			case .duplicatesEmails:
				return C.key.notificationDictionary.count.duplicateEmailsContactsCount
			case .none:
				return ""
		}
	}
	
	var dictioanartyIndexName: String {
		switch self {
				/// `photo`
			case .similarPhoto:
				return C.key.notificationDictionary.index.similarPhotoIndex
			case .duplicatedPhoto:
				return C.key.notificationDictionary.index.duplicatePhotoIndex
			case .similarLivePhoto:
				return C.key.notificationDictionary.index.livePhotosIndex
			case .screenShots:
				return C.key.notificationDictionary.index.screenShotsIndex
			case .selfies:
				return C.key.notificationDictionary.index.selfiePhotosIndex
			case .livePhoto:
				return C.key.notificationDictionary.index.livePhotosIndex
			case .recentlyDeletedPhoto:
				return C.key.notificationDictionary.index.recentlyDeletedPhotoIndex
				/// `video`
			case .largeVideo:
				return C.key.notificationDictionary.index.largeVideoIndex
			case .duplicatedVideo:
				return C.key.notificationDictionary.index.duplicateVideoIndex
			case .similarVideo:
				return C.key.notificationDictionary.index.similarVideoIndex
			case .screenRecordings:
				return C.key.notificationDictionary.index.screenRecordingsIndex
			case .recentlyDeletedVideo:
				return C.key.notificationDictionary.index.recentrlyDeletedVideoIndex
				/// `contacts`
			case .allContacts:
				return C.key.notificationDictionary.index.allContactsIndex
			case .emptyContacts:
				return C.key.notificationDictionary.index.emptyContactsIndex
			case .duplicatesNames:
				return C.key.notificationDictionary.index.duplicateNamesContactsIndex
			case .duplicatesNumbers:
				return C.key.notificationDictionary.index.duplicateNumbersContactsIndex
			case .duplicatesEmails:
				return C.key.notificationDictionary.index.duplicateEmailContactsIndex
			case .none:
				return ""
		}
	}
	
	var notificationName: Notification.Name {
		
		switch self {
				/// `photo`
			case .similarPhoto:
				return .singleSearchSimilarPhotoScan
			case .duplicatedPhoto:
				return .singleSearchDuplicatedPhotoScan
			case .similarLivePhoto:
				return .singleSearchSimilarLivePhotoScan
			case .screenShots:
				return .singleSearchScreenShotsPhotoScan
			case .selfies:
				return .singleSearchSelfiePhotoScan
			case .livePhoto:
				return .singleSearchLivePhotoScan
			case .recentlyDeletedPhoto:
				return .singleSearchRecentlyDeletedPhotoScan
				/// `video`
			case .largeVideo:
				return .singleSearchLargeVideoScan
			case .duplicatedVideo:
				return .singleSearchDuplicatedVideoScan
			case .similarVideo:
				return .singleSearchSimilarVideoScan
			case .screenRecordings:
				return .singleSearchScreenRecordingVideoScan
			case .recentlyDeletedVideo:
				return .singleSearchRecentlyDeletedVideoScan
				/// `contacts`
			case .allContacts:
				return .singleSearchAllContactsScan
			case .emptyContacts:
				return .singleSearchEmptyContactsScan
			case .duplicatesNames:
				return .singleSearchDuplicatesNamesContactsScan
			case .duplicatesNumbers:
				return .singleSearchDuplicatesNumbersContactsScan
			case .duplicatesEmails:
				return .singleSearchDupliatesEmailsContactsScan
			case .none:
				return Notification.Name("")

		}
	}
	
	var mediaTypeRawValue: PhotoMediaType {
		
		switch self {
			case .similarPhoto:
				return .similarPhotos
			case .duplicatedPhoto:
				return .duplicatedPhotos
			case .similarLivePhoto:
				return .similarLivePhotos
			case .screenShots:
				return .singleScreenShots
			case .selfies:
				return .singleSelfies
			case .livePhoto:
				return .singleLivePhotos
			case .recentlyDeletedPhoto:
				return .singleRecentlyDeletedPhotos
			case .largeVideo:
				return .singleLargeVideos
			case .duplicatedVideo:
				return .duplicatedVideos
			case .similarVideo:
				return .similarVideos
			case .screenRecordings:
				return .singleScreenRecordings
			case .recentlyDeletedVideo:
				return .singleRecentlyDeletedVideos
			case .allContacts:
				return .allContacts
			case .emptyContacts:
				return .emptyContacts
			case .duplicatesNames:
				return .duplicatedContacts
			case .duplicatesNumbers:
				return .duplicatedPhoneNumbers
			case .duplicatesEmails:
				return .duplicatedEmails
			case .none:
				return .none

		}
	}
}
