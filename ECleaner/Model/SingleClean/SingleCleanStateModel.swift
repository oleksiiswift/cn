//
//  SingleCleanStateModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.02.2022.
//

import UIKit
import Contacts
import Photos

class SingleCleanModel {
	var objects: [PhotoMediaType : SingleCleanStateModel]
	
	init(objects: [PhotoMediaType : SingleCleanStateModel]) {
		self.objects = objects
	}
}

class SingleCleanStateModel {
	var mediaType: PhotoMediaType
	var cleanState: ProcessingProgressOperationState = .sleeping
	var cleanProgress: CGFloat = 0
	var contactCleanType: ContactasCleaningType = .none
	
	var indexPath: IndexPath {
		return self.mediaType.singleSearchIndexPath
	}
	
	var phassets: [PHAsset] = []
	var phassetGroup: [PhassetGroup] = []
	var contacts: [CNContact] = []
	var contactsGroup: [ContactsGroup] = []
	
	var resultCount: Int {
		return self.flowContentCount()
	}
	
	var isEmpty: Bool {
		return self.resultIsEmpty()
	}
	
	init(type: PhotoMediaType) {
		self.mediaType = type
	}
	
	public func checkForCleanState() {
		self.cleanState = self.isEmpty ? .empty : .complete
	}

	private func flowContentCount() -> Int {
		switch self.mediaType {
			case .singleScreenShots, .singleLivePhotos, .singleLargeVideos, .singleScreenRecordings:
				return self.phassets.count
			case .similarPhotos, .duplicatedPhotos, .similarSelfies, .duplicatedVideos, .similarVideos:
				return self.phassetGroup.count
			case .allContacts:
				return self.contacts.count
			case .emptyContacts:
				return self.contactsGroup.flatMap({$0.contacts}).count
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return self.contactsGroup.count
			default:
				return 0
		}
	}
	
	private func resultIsEmpty() -> Bool {
		switch self.mediaType {
			case .singleScreenShots, .singleLivePhotos, .singleLargeVideos, .singleScreenRecordings:
				return self.phassets.isEmpty
			case .similarPhotos, .duplicatedPhotos, .similarSelfies, .duplicatedVideos, .similarVideos:
				return self.phassetGroup.isEmpty
			case .allContacts:
				return self.contacts.isEmpty
			case .emptyContacts:
				return self.contactsGroup.flatMap({$0.contacts}).isEmpty
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return self.contactsGroup.isEmpty
			default:
				return true
		}
	}
	
	public func resetSingleMode() {
		self.phassets = []
		self.phassetGroup = []
		self.contacts = []
		self.contactsGroup = []
		
		self.cleanProgress = 0
		self.cleanState = .sleeping
	}
}

