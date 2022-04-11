//
//  VideoCompressionQuality.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation

enum VideoCompressionQuality: Equatable {
	case low
	case medium
	case high
	case custom(fps: Float, bitrate: Int = 1000_000, scale: CGSize)
	
	var preSavedValues: (fps: Float, bitrate: Int) {
		switch self {
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
}
