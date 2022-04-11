//
//  VideoCompressionConfig.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation
import AVFoundation

struct VideoCompressionConfig {
	
	public var videoBitrate: Int
	public var audioBitrate: Int
	public var fps: Float
	public var audioSampleRate: Int
	public var maximumVideoKeyframeInterval: Int
	public var scaleResolution: CGSize?
	public var fileType: AVFileType
	
	public init(videoBitrate: Int = 1000_000,
				audioBitrate: Int = 128_000,
				fps: Float = 24,
				audioSampleRate: Int = 44100,
				maximumVideoKeyFrameInterval: Int = 10,
				scaleResolution: CGSize? = nil,
				fileType: AVFileType = .mp4) {
		self.videoBitrate = videoBitrate
		self.audioBitrate = audioBitrate
		self.fps = fps
		self.audioSampleRate = audioSampleRate
		self.maximumVideoKeyframeInterval = maximumVideoKeyFrameInterval
		self.scaleResolution = scaleResolution
		self.fileType = fileType
	}
}
