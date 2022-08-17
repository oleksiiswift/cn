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
				return Localization.Main.HeaderTitle.videoPreview
			case .low:
				return Localization.Main.HeaderTitle.lowQuality
			case .medium:
				return Localization.Main.HeaderTitle.mediumQuality
			case .high:
				return Localization.Main.HeaderTitle.highQuality
			case .custom(_, _, _):
				return Localization.Main.HeaderTitle.customSettings
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
	
	var portraitHeightForRow: CGFloat {
		switch self {
			case .videoPreview:
				return UITableView.automaticDimension
			default:
				return AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType
		}
	}
	
	var heightForRow: CGFloat {
		switch self {
			case .videoPreview:
				return UITableView.automaticDimension
			default:
				return AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType
		}
	}
	
	var selectedIndex: Int {
		switch self {
			case .videoPreview:
				return 666
			case .low:
				return 0
			case .medium:
				return 1
			case .high:
				return 2
			case .custom( _, _, _):
				return 3
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
	
	private func getHeighPortraitPreviewSize() -> CGFloat {
		switch Screen.size {
			case .small:
				return U.screenHeight / 1.5
			default:
				return U.screenHeight / 2
				
		}
	}
	
	private func getHeightOfLandscapePreviewSize() -> CGFloat {
		switch Screen.size {
			case .small:
				return 400
			default:
				return 400
		}
	}
	
	public func getCustomCongfiguration() -> VideoCompressionConfig {
		return CompressionSettingsConfiguretion.getSavedConfiguration()
	}
	
	public func getVideoResolution(from size: CGSize?, isPortrait: Bool) -> VideoResolution {
		
		guard let size = size else {
			return .origin
		}
		
		if isPortrait {
			if let resolution = VideoResolution.allCases.first(where: {$0.resolutionSizePortrait.height == size.height}) {
				return resolution
			}
		} else {
			if let resolution = VideoResolution.allCases.first(where: {$0.resolutionSize.width == size.width}) {
				return resolution
			}
		}
		return .origin
	}
	
	public func getFPS(from fps: Float) -> FPS {
		
		if let fps = FPS.allCases.first(where: {$0.rawValue == fps}) {
			return fps
		} else {
			return FPS.fps24
		}
	}
}

enum VideoCGSize {
	case origin
	case width
	case height
}

extension CGSize {
	
	 func videoResolutionSize() -> VideoCGSize {
		
		let originSize = CGSize(width: -1, height: -1)
		let widthSize = CGSize(width: self.width, height: -1)
		let heightSize = CGSize(width: -1, height: self.height)
		
		switch self {
			case originSize:
				return .origin
			case widthSize:
				return .width
			case heightSize:
				return .height
			default:
				return .origin
		}
	}
}
