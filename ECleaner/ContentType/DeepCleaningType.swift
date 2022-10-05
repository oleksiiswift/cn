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
		return LocalizationService.DeepClean.getProgressTitle(of: self)
	}
}


