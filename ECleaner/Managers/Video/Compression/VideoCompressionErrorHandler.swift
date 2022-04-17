//
//  VideoCompressionErrorHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation

enum VideoCompressionErrorHandler: Error, LocalizedError {
	case noVideoFile
	case compressedFailed(_ error: Error)
	case errorRemoveAudioComponent
	case operationIsCanceled
	
	public var errorDescription: String? {
		switch self {
			case .noVideoFile:
				return ErrorHandler.CompressionError.noVideoFile.errorMessage
			case .compressedFailed(let error):
				return error.localizedDescription
			case .errorRemoveAudioComponent:
				return ErrorHandler.CompressionError.removeAudio.errorMessage
			case .operationIsCanceled:
				return ErrorHandler.CompressionError.operationIsCanceled.errorMessage
		}
	}
	
	public func showErrorAlert(completionHandler: @escaping () -> Void) {
		switch self {
			case .noVideoFile:
				ErrorHandler.shared.showCompressionErrorFor(.noVideoFile) {
					completionHandler()
				}
			case .compressedFailed(_):
				ErrorHandler.shared.showCompressionErrorFor(.compressionFailed) {
					completionHandler()
				}
			case .errorRemoveAudioComponent:
				ErrorHandler.shared.showCompressionErrorFor(.removeAudio) {
					completionHandler()
				}
			case .operationIsCanceled:
				ErrorHandler.shared.showCompressionErrorFor(.operationIsCanceled) {
					completionHandler()
				}
		}
	}
}
