//
//  ProcessingProgressOperationState.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.02.2022.
//

import UIKit

enum ProcessingProgressOperationState {
	case sleeping
	case prepare
	case analyzing
	case compare
	case progress
	case complete
	case result
	case empty
	case selected
		
	func getTitle(by mediaType: PhotoMediaType, files: Int, selected: Int, progress: CGFloat) -> String {
		switch self {
			case .sleeping:
				return "-"
			case .prepare:
				return "prepare for scanning"
			case .analyzing:
				return "analyzing, please wait"
			case .compare:
				return "compare results"
			case .progress:
				return "\(progress.rounded().cleanValue)% - completed"
			case .complete:
				return "analyzing complete"
			case .result:
				return ProcessingResultComplete.instance.resultProcessingComplete(mediaType, files: files)
			case .empty:
				return ProcessingResultComplete.instance.emptyResultProcessingComplete(mediaType)
			case .selected:
				return ProcessingResultComplete.instance.selectedVsResultProcessing(mediaType, files: files, selected: selected)
		}
	}
}

struct ProcessingResultComplete {
	
	static let instance = ProcessingResultComplete()
	
	func selectedVsResultProcessing(_ mediaType: PhotoMediaType, files: Int, selected: Int) -> String {
		switch mediaType {
			case .similarPhotos:
				return String("\(files) ") + "similar groups" + "(\(selected) selected photos)"
			case .duplicatedPhotos:
				return String("\(files) ") + "duplicated groups" + "(\(selected) selected photos)"
			case .singleScreenShots:
				return String("\(files) ") + "files" + "(\(selected) selected photos)"
			case .singleLivePhotos:
				return String("\(files) ") + "files" + "(\(selected) selected photos)"
			case .similarLivePhotos:
				return String("\(files) ") + "similar groups" + "(\(selected) selected photos)"
			case .similarSelfies:
				return String("\(files) ") + "similar groups" + "(\(selected) selected photos)"
			case .singleLargeVideos:
				return String("\(files) ") + "files" + "(\(selected) selected videos)"
			case .duplicatedVideos:
				return String("\(files) ") + "duplicated groups" + "(\(selected) selected videos)"
			case .similarVideos:
				return String("\(files) ") + "similar groups" + "(\(selected) selected videos)"
			case .singleScreenRecordings:
				return String("\(files) ") + "files" + "(\(selected) selected videos)"
			case .allContacts:
				return String("\(files) ") + "contacts" + "(\(selected) selected contacts)"
			case .emptyContacts:
				return String("\(files) ") + "contacts" + "(\(selected) selected contacts)"
			case .duplicatedContacts:
				return String("\(files) ") + "duplicated contacts group" + "(\(selected) selected contacts)"
			case .duplicatedPhoneNumbers:
				return String("\(files) ") + "duplicated contacts group" + "(\(selected) selected contacts)"
			case .duplicatedEmails:
				return String("\(files) ") + "duplicated contacts group" + "(\(selected) selected contacts)"
			default:
				return "none"
		}
	}
	
	func resultProcessingComplete(_ mediaType: PhotoMediaType, files: Int) -> String {
		switch mediaType {
			case .similarPhotos:
				return String("\(files) ") + "similar groups"
			case .duplicatedPhotos:
				return String("\(files) ") + "duplicated groups"
			case .singleScreenShots:
				return String("\(files) ") + "files"
			case .singleLivePhotos:
				return String("\(files) ") + "files"
			case .similarLivePhotos:
				return String("\(files) ") + "similar groups"
			case .similarSelfies:
				return String("\(files) ") + "similar groups"
			case .singleLargeVideos:
				return String("\(files) ") + "files"
			case .duplicatedVideos:
				return String("\(files) ") + "duplicated groups"
			case .similarVideos:
				return String("\(files) ") + "similar groups"
			case .singleScreenRecordings:
				return String("\(files) ") + "files"
			case .allContacts:
				return String("\(files) ") + "contacts"
			case .emptyContacts:
				return String("\(files) ") + "contacts"
			case .duplicatedContacts:
				return String("\(files) ") + "duplicated contacts group"
			case .duplicatedPhoneNumbers:
				return String("\(files) ") + "duplicated contacts group"
			case .duplicatedEmails:
				return String("\(files) ") + "duplicated contacts group"
			default:
				return "none"
		}
	}
	
	func emptyResultProcessingComplete(_ mediaType: PhotoMediaType) -> String {
		switch mediaType {
			case .similarPhotos:
				return "no similiar photos"
			case .duplicatedPhotos:
				return "no duplicated photos"
			case .singleScreenShots:
				return "np screen shots"
			case .singleLivePhotos:
				return "no live photos"
			case .similarLivePhotos:
				return "no similar live photos"
			case .similarSelfies:
				return "no similar selfies"
			case .singleLargeVideos:
				return "no large videos"
			case .duplicatedVideos:
				return "no duplicated videos"
			case .similarVideos:
				return "no similar videos"
			case .singleScreenRecordings:
				return "no screen recordings"
			case .allContacts:
				return "no contacts"
			case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return "no contacts to clean"
			default:
				return "none"
		}
	}
}
