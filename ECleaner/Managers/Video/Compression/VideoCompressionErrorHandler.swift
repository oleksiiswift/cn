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
	
	public var errorDescription: String? {
		switch self {
			case .noVideoFile:
				return "no video"
			case .compressedFailed(let error):
				return error.localizedDescription
			case .errorRemoveAudioComponent:
				return "cant remove audioComponent"
		}
	}
	
	public func showVideoCompressedError() {
		switch self {
			case .noVideoFile:
				debugPrint("show no compressed file alert")
			case .compressedFailed(_):
				debugPrint("show compressed file error")
			case .errorRemoveAudioComponent:
				debugPrint("show cant remove audio component")
		}
	}
}
