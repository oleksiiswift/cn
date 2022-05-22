//
//  CompressionResolution.swift
//  ECleaner
//
//  Created by alexey sorochan on 14.04.2022.
//

import Foundation

enum CustomCompressionSection {
	case resolution
	case fps
	case videoBitrate
	case keyframe
	case audioBitrate
	case none
	
	var name: String {
		switch self {
			case .resolution:
				return "Resolution"
			case .fps:
				return "FPS"
			case .videoBitrate:
				return "Video Bitrate"
			case .keyframe:
				return "Interval Between Keyframe"
			case .audioBitrate:
				return "Audio Bitrate"
			case .none:
				return ""
		}
	}
	
	var description: String {
		switch self {
			case .resolution:
				return "if set to a lower value, the picture will be more pixelated and the file size will be smaller"
			case .fps:
				return "a lower framerate means the video will be less smooth and the file size will be significantly smaller"
			case .videoBitrate:
				return "if set to a lower value, it will reduce video quality and considerably decrease file size"
			case .keyframe:
				return "if set to a higher value, video quality and size will decrease, it is recommended to choose higher values if your video has no dynamic scenes"
			case .audioBitrate:
				return "if set to a lower value, the audio quality will deteriorate and the file size will be insignificantly reduced"
			case .none:
				return ""
		}
	}
}

enum VideoResolution: CaseIterable {
	case origin
	case res1080p
	case res720p
	case res540p
	case res480p
	case res360p
	case res240p
	
	public var resolutionName: String {
		switch self {
			case .origin:
				return "origin"
			case .res1080p:
				return "1080p"
			case .res720p:
				return "720p"
			case .res540p:
				return "540p"
			case .res480p:
				return "480p"
			case .res360p:
				return "360p"
			case .res240p:
				return "240p"
		}
	}
	
	public var resolutionSize: CGSize { 
		switch self {
			case .origin:
				return CGSize(width: -1, height: -1)
			case .res1080p:
				return CGSize(width: 1920, height: 1080)
			case .res720p:
				return CGSize(width: 1280, height: 720)
			case .res540p:
				return CGSize(width: 960, height: 540)
			case .res480p:
				return CGSize(width: 852, height: 480)
			case .res360p:
				return CGSize(width: 640, height: 360)
			case .res240p:
				return CGSize(width: 426, height: 240)
		}
	}
	
	public var resolutionSizePortrait: CGSize {
		switch self {
			case .origin:
				return CGSize(width: -1, height: -1)
			case .res1080p:
				return CGSize(width: 1080, height: 1920)
			case .res720p:
				return CGSize(width: 720, height: 1280)
			case .res540p:
				return CGSize(width: 540, height: 960)
			case .res480p:
				return CGSize(width: 480, height: 852)
			case .res360p:
				return CGSize(width: 360, height: 640)
			case .res240p:
				return CGSize(width: 240, height: 426)
		}
	}
	
	
	public var resolutionDescription: String {
		switch self {
			case .origin:
				return "keep origin resolution"
			case .res1080p:
				return "1920 x 1080 (or 1080p)"
			case .res720p:
				return "1280 x 720 (or 720p)"
			case .res540p:
				return "960 x 540 (or 540p)"
			case .res480p:
				return "852 x 480 (or 480p)"
			case .res360p:
				return "640 x 360 (or 360p)"
			case .res240p:
				return "426 x 240 (or 240p)"
		}
	}
	
	public var resolutionInfo: String {
		switch self {
			case .origin:
				return "origin resolution"
			case .res1080p:
				return "1920 x 1080"
			case .res720p:
				return "1280 x 720"
			case .res540p:
				return "960 x 540"
			case .res480p:
				return "852 x 480"
			case .res360p:
				return "640 x 360"
			case .res240p:
				return "426 x 240"
		}
	}
	
	public var resolutionInfoPortrait: String {
		switch self {
			case .origin:
				return "origin resolution"
			case .res1080p:
				return "1080 x 1920"
			case .res720p:
				return "720 x 1280"
			case .res540p:
				return "540 x 960"
			case .res480p:
				return "480 x 852"
			case .res360p:
				return "360 x 640"
			case .res240p:
				return "240 x 426"
		}
	}
}

enum FPS: CaseIterable {
	case fps60
	case fps30
	case fps24
	case fps15
	
	public var rawValue: Float {
		switch self {
			case .fps60:
				return 60
			case .fps30:
				return 30
			case .fps24:
				return 24
			case .fps15:
				return 15
		}
	}
	
	public var name: String {
		switch self {
			case .fps60:
				return "60 FPS"
			case .fps30:
				return "30 FPS"
			case .fps24:
				return "24 FPS"
			case .fps15:
				return "15 FPS"
		}
	}
}
	
enum AudioBitrate: CaseIterable {
	case bit256
	case bit192
	case bit160
	case bit128
	case bit96
//	case bit32
	
	public var rawValue: Int {
		switch self {
				
			case .bit256:
				return 256_000
			case .bit192:
				return 192_000
			case .bit160:
				return 160_000
			case .bit128:
				return 128_000
			case .bit96:
				return 96_000
//			case .bit32:
//				return 32_000
		}
	}
	
	public var name: String {
		switch self {
			case .bit256:
				return "256 kbit/s"
			case .bit192:
				return "192kbit/s"
			case .bit160:
				return "160kbit/s"
			case .bit128:
				return "128kbit/s"
			case .bit96:
				return "96kbit/s"
//			case .bit32:
//				return "32 kbit/s"
		}
	}
	
	public var description: String {
		switch self {
				
			case .bit256:
				return "a commonly used high-quality bitrate."
			case .bit192:
				return "medium quality bitrate."
			case .bit160:
				return "mid-range bitrate quality."
			case .bit128:
				return "mid-range bitrate quality."
			case .bit96:
				return "generally used for speech or low-quality streaming."
//			case .bit32:
//				return "generally acceptable only for speech."
		}
	}
	
	public var shortDescription: String {
		switch self {
			case .bit256:
				return "high-quality"
			case .bit192:
				return "medium quality"
			case .bit160:
				return "mid-range quality"
			case .bit128:
				return "mid-range quality"
			case .bit96:
				return "low-quality"
		}
	}
}
