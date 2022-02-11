//
//  DeepCleanStateModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.02.2022.
//

import UIKit

class DeepCleanModel {
	var objects: [PhotoMediaType : DeepCleanStateModel]
	
	init(objects: [PhotoMediaType : DeepCleanStateModel]) {
		self.objects = objects
	}
}

class DeepCleanStateModel {
	var mediaType: PhotoMediaType
	var cleanState: ProcessingProgressOperationState = .sleeping
	var deepCleanProgress: CGFloat = 0
	var handleSelectedPhassetsForMediatype: Bool = false
	var selectedAssetsCollectionID: [String] = []
	
	var mediaFlowGroup: [PhassetGroup] = []
	var contactsFlowGroup: [ContactsGroup] = []

	init(type: PhotoMediaType ) {
		self.mediaType = type
	}
	
	public func flowContentCount() -> Int {
		switch self.mediaType {
			case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
				if let assets = self.mediaFlowGroup.first {
					return assets.assets.count
				} else {
					return 0
				}
			case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarVideos, .duplicatedVideos, .similarSelfies:
				return self.mediaFlowGroup.count
			case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return self.contactsFlowGroup.count
			default:
				return 0
		}
	}
	
	public func selectedContentCount() -> Int {
		switch self.mediaType {
			case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .duplicatedVideos, .similarVideos, .similarSelfies:
				return self.selectedAssetsCollectionID.count
			case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
				return self.selectedAssetsCollectionID.count
			case .emptyContacts:
				return self.selectedAssetsCollectionID.count
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				let selectedIDS = self.selectedAssetsCollectionID
				let groups = self.contactsFlowGroup
				var selectedContactsCount = 0
				for id in selectedIDS {
					if let group = groups.first(where: {$0.groupIdentifier == id}) {
						selectedContactsCount += group.contacts.count
					}
				}
			default:
				return 0
		}
		return 0
	}
}
