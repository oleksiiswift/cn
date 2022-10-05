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
	case result
	case complete
	case empty
	case selected
		
	func getTitle(by mediaType: PhotoMediaType, files: Int, selected: Int, progress: CGFloat) -> String {
		switch self {
			case .sleeping:
				return Localization.Main.ProcessingState.tap
			case .prepare:
				return Localization.Main.ProcessingState.prepareForScanning
			case .analyzing:
				return Localization.Main.ProcessingState.analyzingWait
			case .compare:
				return Localization.Main.ProcessingState.compare
			case .progress:
				return "\(progress.rounded().cleanValue)% - \(Localization.Main.ProcessingState.anayzing)"
			case .complete:
				return ProcessingResultComplete.instance.resultProcessingComplete(mediaType, files: files)
			case .result:
				return Localization.Main.ProcessingState.searchingComplete
			case .empty:
				return ProcessingResultComplete.instance.emptyResultProcessingComplete(mediaType)
			case .selected:
				return ProcessingResultComplete.instance.selectedResultProcessing(mediaType, files: files, selected: selected)
		}
	}
}

struct ProcessingResultComplete {
	
	static let instance = ProcessingResultComplete()
	
	func selectedVsResultProcessing(_ mediaType: PhotoMediaType, files: Int, selected: Int) -> String {
		switch mediaType {
			case .similarPhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .duplicatedPhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .singleScreenShots:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .singleLivePhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .similarLivePhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .similarSelfies:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .singleLargeVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto))"
			case .duplicatedVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo))"
			case .similarVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo))"
			case .singleScreenRecordings:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo))"
			case .allContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts))"
			case .emptyContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts))"
			case .duplicatedContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts))"
			case .duplicatedPhoneNumbers:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo))"
			case .duplicatedEmails:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups + "(\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts))"
			default:
				return "none"
		}
	}
	
	func selectedResultProcessing(_ mediaType: PhotoMediaType, files: Int, selected: Int) -> String {
		switch mediaType {
			case .similarPhotos:
				return selected == 0 ? String("\(files) " + Localization.Main.ProcessingState.ByGrouping.similarGroups) : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .duplicatedPhotos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .singleScreenShots:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .singleLivePhotos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .similarLivePhotos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .similarSelfies:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedPhoto)"
			case .singleLargeVideos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo)"
			case .duplicatedVideos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo)"
			case .similarVideos:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo)"
			case .singleScreenRecordings:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedVideo)"
			case .allContacts:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts)"
			case .emptyContacts:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts)"
			case .duplicatedContacts:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts)"
			case .duplicatedPhoneNumbers:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts)"
			case .duplicatedEmails:
				return selected == 0 ? String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups : "\(selected) \(Localization.Main.ProcessingState.ByGrouping.selectedContacts)"
			default:
				return Localization.none
		}
	}
	
	func resultProcessingComplete(_ mediaType: PhotoMediaType, files: Int) -> String {
		switch mediaType {
			case .similarPhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups
			case .duplicatedPhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups
			case .singleScreenShots:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files
			case .singleLivePhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files
			case .similarLivePhotos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups
			case .similarSelfies:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups
			case .singleLargeVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files
			case .duplicatedVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedGroups
			case .similarVideos:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.similarGroups
			case .singleScreenRecordings:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.files
			case .allContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts
			case .emptyContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.contacts
			case .duplicatedContacts:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups
			case .duplicatedPhoneNumbers:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups
			case .duplicatedEmails:
				return String("\(files) ") + Localization.Main.ProcessingState.ByGrouping.duplicatedCotactsGroups
			default:
				return Localization.none
		}
	}
	
	func emptyResultProcessingComplete(_ mediaType: PhotoMediaType) -> String {
		switch mediaType {
			case .similarPhotos:
				return Localization.Main.ProcessingState.ByEmptyState.emptySimilarPhoto
			case .duplicatedPhotos:
				return Localization.Main.ProcessingState.ByEmptyState.emptyDuplicatedPhoto
			case .singleScreenShots:
				return Localization.Main.ProcessingState.ByEmptyState.emptyScreenShots
			case .singleLivePhotos:
				return Localization.Main.ProcessingState.ByEmptyState.emptyLivePhoto
			case .similarLivePhotos:
				return Localization.Main.ProcessingState.ByEmptyState.emptySimilarLivePhotos
			case .similarSelfies:
				return Localization.Main.ProcessingState.ByEmptyState.emptySimilarSelfies
			case .singleLargeVideos:
				return Localization.Main.ProcessingState.ByEmptyState.emptyLargeVideos
			case .duplicatedVideos:
				return Localization.Main.ProcessingState.ByEmptyState.noDuplicatedVideo
			case .similarVideos:
				return Localization.Main.ProcessingState.ByEmptyState.noSimilarVideo
			case .singleScreenRecordings:
				return Localization.Main.ProcessingState.ByEmptyState.noScreenRecording
			case .allContacts:
				return Localization.Main.ProcessingState.ByEmptyState.noContacts
			case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return Localization.Main.ProcessingState.ByEmptyState.noContactsToClean
			default:
				return Localization.none
		}
	}
}
