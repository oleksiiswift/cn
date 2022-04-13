//
//  VideoCompressionQuality.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation

typealias ComprssionModel = VideoCompressionQuality

enum VideoCompressionQuality: Equatable {
	case videoPreview
	case low
	case medium
	case high
	case custom(fps: Float, bitrate: Int = 1000_000, scale: CGSize)
	
	var preSavedValues: (fps: Float, bitrate: Int) {
		switch self {
			case .videoPreview:
				return (0,0)
			case .low:
				return (15, 250_000)
			case .medium:
				return (24, 2500_000)
			case .high:
				return (30, 8000_000)
			case .custom(fps: let fps, bitrate: let bitrate, scale: _):
				return (fps, bitrate)
		}
	}
	
	var compressionTitle: String {
		switch self {
			case .videoPreview:
				return "video preview"
			case .low:
				return "low quality"
			case .medium:
				return "medium quality"
			case .high:
				return "hight quality"
			case .custom(_, _, _):
				return "custom settings"
		}
	}
	
	var compressionSubtitle: String {
		switch self {
			case .videoPreview:
				return ""
			case .low:
				return "description for low"
			case .medium:
				return "description for medium"
			case .high:
				return "description for hight"
			case .custom(_, _, _):
				return "description for custom"
		}
	}
	
	var heightForRow: CGFloat {
		switch self {
			case .videoPreview:
				return 370
			default:
				return 100
		}
	}
	
	func getCompressionModel(from indexPath: IndexPath) -> ComprssionModel {
		switch indexPath.section {
			case 1:
				switch indexPath.row {
					case 0:
						return .low
					case 1:
						return .medium
					case 2:
						return .high
					case 3:
						return .custom(fps: 0, bitrate: 0, scale: .zero)
					default:
						return .videoPreview
				}
			default:
				return .videoPreview
		}
	}
}
