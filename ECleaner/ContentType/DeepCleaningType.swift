//
//  DeepCleaningType.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.02.2022.
//

import Foundation

enum DeepCleaningType {
	case prepareCleaning
	case photoCleaning
	case contactsEmptyCleaning
	case contactsMergeCleaning
	case contactsDeleteCleaning
	
	var progressTitle: String {
		switch self {
			case .photoCleaning:
				return "deleting photo (video):"
			case .contactsEmptyCleaning:
				return "removing empty contacts:"
			case .contactsMergeCleaning:
				return "merge selecting contacts:"
			case .contactsDeleteCleaning:
				return "deleting selected contacts:"
			case .prepareCleaning:
				return "prepare cleaning"
		}
	}
}
