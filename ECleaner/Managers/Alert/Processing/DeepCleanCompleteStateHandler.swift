//
//  DeepCleanCompleteStateHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.06.2022.
//

import Foundation

enum DeepCleanCompleteStateHandler {
	case successfull
	case canceled
	
	var description: AlertDescription {
		return LocalizationService.Alert.DeepClean.deepCleanCompleted(for: self)
	}
	
	static func alertHandler(for state: DeepCleanCompleteStateHandler, completionHandler: (() -> Void)? = nil) {
		AlertManager.showDeepCleanProcessing(with: state) {
			completionHandler?()
		}
	}
}
