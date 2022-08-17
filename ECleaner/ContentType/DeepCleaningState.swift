//
//  DeepCleaningState.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.02.2022.
//

import Foundation

enum DeepCleaningState {
	case redyForStartingCleaning
	case willStartCleaning
	case didCleaning
	case willAvailibleDelete
	case canclel
}


enum DeepCleanButtonState {
	case startDeepClen
	case startAnalyzing
	case stopAnalyzing
	case startCleaning
}
