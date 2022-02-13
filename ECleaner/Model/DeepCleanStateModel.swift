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
	
	var selectedAssetsCollectionID: [String] = []
	var mediaFlowGroup: [PhassetGroup] = []
	var contactsFlowGroup: [ContactsGroup] = []

	var resultsCount: Int {
		return self.flowContentCount()
	}
	var isEmpty: Bool {
		return self.resultIsEmpty()
	}
	var handleSelected: Bool {
		return !selectedAssetsCollectionID.isEmpty
	}
	
	init(type: PhotoMediaType ) {
		self.mediaType = type
	}
	
	private func flowContentCount() -> Int {
		switch self.mediaType {
			case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
				return self.mediaFlowGroup.flatMap({$0.assets}).count
			case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarVideos, .duplicatedVideos, .similarSelfies:
				return self.mediaFlowGroup.count
			case .emptyContacts:
				return self.contactsFlowGroup.flatMap({$0.contacts}).count
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
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
				return self.selectedAssetsCollectionID.count
			default:
				return 0
		}
	}
	
	public func deepCleanIndexPath() -> IndexPath {
		return self.mediaType.deepCleanIndexPath
	}
	
	private func resultIsEmpty() -> Bool {
		switch self.mediaType {
			case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
				if let assets = self.mediaFlowGroup.first {
					return assets.assets.isEmpty
				} else {
					return true
				}
			case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarVideos, .duplicatedVideos, .similarSelfies:
				return self.mediaFlowGroup.isEmpty
			case .emptyContacts:
				let contacts = self.contactsFlowGroup.flatMap({$0.contacts})
				return contacts.isEmpty
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return self.contactsFlowGroup.isEmpty
			default:
				return true
		}
	}
	
	public func getContactsMergeGroups() -> [ContactsGroup] {
		return contactsFlowGroup.filter({selectedAssetsCollectionID.contains($0.groupIdentifier)})
	}
}

class DeepCleanTotalProgress {
	
	var totalProgress: CGFloat {
		return self.calculateTotalProgrss()
	}
	
	var progressForMediaType: [PhotoMediaType : CGFloat] = [:]
	
	private func calculateTotalProgrss() -> CGFloat {
		return progressForMediaType.map({$0.value}).sum() / 13
	}
}
