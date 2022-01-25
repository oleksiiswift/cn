//
//  CommonOperationSearchType.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.12.2021.
//

import Foundation

typealias COT = CommonOperationSearchType
enum CommonOperationSearchType: CaseIterable {
	case similarPhotoAssetsOperaton
	case utitlityDuplicatedPhotoTuplesOperation
	case duplicatedPhotoAssetsOperation
	case screenShotsAssetsOperation
	case similarSelfiesAssetsOperation
	case livePhotoAssetsOperation
	case recentlyDeletedOperation
	
	case largeVideoContentOperation
	case duplicatedVideoAssetOperation
	case similarVideoAssetsOperation
	case screenRecordingsVideoOperation
	
	case emptyContactOperation
	case duplicatedNameOperation
	case duplicatedPhoneNumbersOperation
	case duplicatedEmailsOperation
	
	case none

	var rawValue: String {
		switch self {
			case .similarPhotoAssetsOperaton:
				return C.key.operation.name.similarPhotoProcessingOperation
			case .utitlityDuplicatedPhotoTuplesOperation:
				return C.key.operation.name.duplicatedTuplesOperation
			case .duplicatedPhotoAssetsOperation:
				return C.key.operation.name.duplicatePhotoProcessingOperation
			case .screenShotsAssetsOperation:
				return C.key.operation.name.screenShotsOperation
			case .similarSelfiesAssetsOperation:
				return C.key.operation.name.similarSelfiesOperation
			case .livePhotoAssetsOperation:
				return C.key.operation.name.livePhotoOperation
			case .recentlyDeletedOperation:
				return C.key.operation.name.recentlyDeletedSortedAlbums
			case .largeVideoContentOperation:
				return C.key.operation.name.largeVideo
			case .duplicatedVideoAssetOperation:
				return C.key.operation.name.duplicateVideoProcessingOperation
			case .similarVideoAssetsOperation:
				return C.key.operation.name.similarVideoProcessingOperation
			case .screenRecordingsVideoOperation:
				return C.key.operation.name.screenRecordingOperation
			case .emptyContactOperation:
				return C.key.operation.name.emptyContacts
			case .duplicatedNameOperation:
				return C.key.operation.name.duplicatedContacts
			case .duplicatedPhoneNumbersOperation:
				return C.key.operation.name.phoneDuplicated
			case .duplicatedEmailsOperation:
				return C.key.operation.name.emailDuplicated
			case .none:
				return ""
		}
	}
	
	static func getOperationType(from rawValue: String) -> CommonOperationSearchType? {
		for type in CommonOperationSearchType.allCases {
			if type.rawValue == rawValue {
				return type
			}
		}
		return nil
	}
}
