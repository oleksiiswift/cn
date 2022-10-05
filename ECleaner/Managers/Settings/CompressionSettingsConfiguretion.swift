//
//  CompressionSettingsConfiguretion.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.04.2022.
//

import UIKit

class CompressionSettingsConfiguretion {
	
	public static func setDefaultConfiguration() {
		let config = VideoCompressionConfig()
		saveCompressionConfiguration(config)
		isDefaultConfigurationIsSet = true
	}
	
	public static func getSavedConfiguration() -> VideoCompressionConfig {
		
		return VideoCompressionConfig(videoBitrate: self.videoBitrate,
									  audioBitrate: self.audioBitrate,
									  fps: self.fps,
									  audioSampleRate: 44100,
									  maximumVideoKeyframeInterval: self.maximumVideoKeyframeInterval,
									  scaleResolution: self.scaleResolution,
									  fileType: .mp4)
	}
	
	public static func saveCompressionConfiguration(_ config: VideoCompressionConfig) {
		self.videoBitrate = config.videoBitrate
		self.audioBitrate = config.audioBitrate
		self.fps = config.fps
		self.maximumVideoKeyframeInterval = config.maximumVideoKeyframeInterval
		if let size = config.scaleResolution {
			self.scaleResolution = size
		} else {
			self.scaleResolution = CGSize(width: 1920, height: 1080)
		}
	}

	private static var videoBitrate: Int {
		get {
			return U.userDefaults.integer(forKey: C.key.compressionSettings.videoBitrate)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.videoBitrate)
		}
	}
	
	private static var audioBitrate: Int {
		get {
			return U.userDefaults.integer(forKey: C.key.compressionSettings.audioBitrate)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.audioBitrate)
		}
	}
	
	private static var fps: Float {
		get {
			return U.userDefaults.float(forKey: C.key.compressionSettings.fps)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.fps)
		}
	}
	
	private static var maximumVideoKeyframeInterval: Int {
		get {
			return U.userDefaults.integer(forKey: C.key.compressionSettings.frameInterval)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.frameInterval)
		}
	}
	 
	private static var widthResolution: CGFloat {
		get {
			return CGFloat(U.userDefaults.float(forKey: C.key.compressionSettings.resolutionWidth))
		} set {
			U.userDefaults.set(Float(newValue), forKey: C.key.compressionSettings.resolutionWidth)
		}
	}
	
	private static var heightResolution: CGFloat {
		get {
			return CGFloat(U.userDefaults.float(forKey: C.key.compressionSettings.resolutionHeight))
		} set {
			U.userDefaults.set(Float(newValue), forKey: C.key.compressionSettings.resolutionHeight)
		}
	}
	
	private static var scaleResolution: CGSize {
		get {
			return CGSize(width: self.widthResolution, height: self.heightResolution)
		} set {
			self.widthResolution = newValue.width
			self.heightResolution = newValue.height
			self.originalResultionIsUse = newValue.width == -1 && newValue.height == -1 
		}
	}
	
	private static var originalResultionIsUse: Bool {
		get {
			return U.userDefaults.bool(forKey: C.key.compressionSettings.originalResolutionIsOnUse)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.originalResolutionIsOnUse)
		}
	}

	public static var isDefaultConfigurationIsSet: Bool {
		get {
			return U.userDefaults.bool(forKey: C.key.compressionSettings.defaultConfigurationIsSet)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.defaultConfigurationIsSet)
		}
	}
	
	public static var lastSelectedCompressionModel: Int {
		get {
			return U.userDefaults.integer(forKey: C.key.compressionSettings.lastSelectedCompressionModel)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.compressionSettings.lastSelectedCompressionModel)
		}
	}
}
