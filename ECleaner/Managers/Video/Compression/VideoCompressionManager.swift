//
//  VideoCompressionManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation
import AVFoundation

class VideoCompressionManager {
	
	class var insstance: VideoCompressionManager {
		struct Static {
			static let instance: VideoCompressionManager = VideoCompressionManager()
		}
		return Static.instance
	}
	
	private var fileManager = ECFileManager()
	
	private let group = DispatchGroup()
	private let videoCompressionQueue = DispatchQueue.init(label: C.key.dispatch.compressVideoQueue)
	private lazy var audioCompressionQueue = DispatchQueue.init(label: C.key.dispatch.compressAudieQueue)
	
	private var reader: AVAssetReader?
	private var writer: AVAssetWriter?
	
	private var videoPath: [URL] = []
	
	private init() {}
	
	public var minimumVideoBitrate = 1000 * 200
}

//	MARK: - settings -
extension VideoCompressionManager {
	
	private func createVideoSettings(with bitrate: Int, maxKeyFrameInterval: Int, size: CGSize) -> [String: Any] {

		let properties: [String: Any] = [
			AVVideoAverageBitRateKey: bitrate,
			AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
			AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCABAC,
			AVVideoMaxKeyFrameIntervalKey: maxKeyFrameInterval]
		
		let settings: [String: Any] = [
			AVVideoCodecKey: AVVideoCodecType.h264,
			AVVideoWidthKey: size.width,
			AVVideoHeightKey: size.height,
			AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
			AVVideoCompressionPropertiesKey: properties]
		
		return settings
	}
	
	private func createAudioSettings(with audioTrack: AVAssetTrack, bitrate: Int, sampleRate: Int) -> [String: Any] {
		
		var audioChannelLayout = AudioChannelLayout()
		memset(&audioChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
		audioChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
		
		let data = Data(bytes: &audioChannelLayout, count: MemoryLayout<AudioChannelLayout>.size)
		
		let settings: [String: Any] = [
			AVFormatIDKey: kAudioFormatMPEG4AAC,
			AVSampleRateKey: sampleRate,
			AVEncoderBitRateKey: bitrate,
			AVNumberOfChannelsKey: 2,
			AVChannelLayoutKey: data
		]
		return settings
	}
}

//		MARK: - calculate -
extension VideoCompressionManager {
	
	private func calculateSize(with quality: VideoCompressionQuality, originalSize: CGSize) -> CGSize {
		
		var treshold: CGFloat = -1
		
		var targetWidth = originalSize.width
		var targetHeight = originalSize.height
		let isPortrait = originalSize.height > originalSize.width
		
		switch quality {
			case .low:
				treshold = 224
			case .medium:
				treshold = 480
			case .high:
				treshold = 1080
			case .custom(_, _, let scale):
				return scale
			default:
				return CGSize()
		}
		
		if isPortrait {
			if originalSize.width > treshold {
				targetWidth = treshold
				targetHeight =  treshold * originalSize.height / originalSize.width
			}
		} else {
			if originalSize.height > treshold {
				targetHeight = treshold
				targetWidth = treshold * originalSize.width / originalSize.height
			}
		}
		return CGSize(width: Int(targetWidth), height: Int(targetHeight))
	}
	
	private func calculateSize(with scale: CGSize?, originalSize: CGSize) -> CGSize {
		
		guard let scale = scale else { return originalSize }
		
		if scale.width == -1 && scale.height == -1 {
			return originalSize
		} else if scale.width != -1 && scale.height != -1 {
			return scale
		} else {
			var targetWidth: Int = Int(scale.width)
			var targetHeight: Int = Int(scale.height)
			
			if scale.width == -1 {
				targetWidth = Int(scale.height * originalSize.width / originalSize.height)
			} else {
				targetHeight = Int(scale.width * originalSize.height / originalSize.width)
			}
			return CGSize(width: targetWidth, height: targetHeight)
			
		}
	}
	
	private func calculateBitrate(with quality: VideoCompressionQuality, originBitrate: Int) -> Int {
		
		var targetBitrate = quality.preSavedValues.bitrate
		
		if originBitrate < targetBitrate {
			switch quality {
				case .low:
					targetBitrate = self.getMaxBitrate(from: originBitrate / 8)
				case .medium:
					targetBitrate = self.getMaxBitrate(from: originBitrate / 4)
				case .high:
					targetBitrate = self.getMaxBitrate(from: originBitrate / 2)
				case .custom(_, _, _):
					break
				default:
					break
			}
		}
		return targetBitrate
	}
	
	private func getMaxBitrate(from bitrate: Int) -> Int {
		return max(bitrate, self.minimumVideoBitrate)
	}
	
	private func getFrameIndexes(with originFPS: Float, targetFPS: Float, duration: Float) -> [Int] {
		
		assert(originFPS > 0)
		assert(targetFPS > 0)
		
		let originFrames = Int(originFPS * duration)
		let targetFrames = Int(ceil(Float(originFrames) * targetFPS / originFPS))
		
		var range = Array(repeating: 0, count: targetFrames)
		
		for frame in 0..<targetFrames {
			range[frame] = Int(ceil(Double(originFrames) * Double(frame + 1) / Double(targetFrames)))
		}
		
		var randomFrames = Array(repeating: 0, count: range.count)
		
		guard !randomFrames.isEmpty else { return [] }
		
		guard randomFrames.count > 1 else { return randomFrames }
		
		for index in 1..<range.count {
			let pre = range[index - 1]
			let res = Int.random(in: pre..<range[index])
			randomFrames[index] = res
		}
		return randomFrames
	}
}

//		MARK: - output -
extension VideoCompressionManager {
	
	private func getOutputVideoData(videoInput: AVAssetWriterInput, videoOutput: AVAssetReaderTrackOutput, completionHandler: @escaping (() -> Void)) {
		
		videoInput.requestMediaDataWhenReady(on: self.videoCompressionQueue) {
			while videoInput.isReadyForMoreMediaData {
				if let videoBuffer = videoOutput.copyNextSampleBuffer(), CMSampleBufferDataIsReady(videoBuffer) {
					videoInput.append(videoBuffer)
				} else {
					videoInput.markAsFinished()
					completionHandler()
					break
				}
			}
		}
	}
	
	private func getOuputVideoDataByReducingFPS(originFPS: Float, targetFPS: Float, videoInput: AVAssetWriterInput, videoOuput: AVAssetReaderTrackOutput, duration: CMTime, completionHandler: @escaping (() -> Void)) {
		
		var index = 0
		var counter = 0
		let randeomFrames = self.getFrameIndexes(with: originFPS, targetFPS: targetFPS, duration: Float(duration.seconds))
		
		videoInput.requestMediaDataWhenReady(on: self.videoCompressionQueue) {
			
			while videoInput.isReadyForMoreMediaData {
				
				if let buffer = videoOuput.copyNextSampleBuffer() {
					if index < randeomFrames.count {
						let frameIndex = randeomFrames[index]
						if counter == frameIndex {
							index += 1
							let timingInfo = UnsafeMutablePointer<CMSampleTimingInfo>.allocate(capacity: 1)
							let newSample = UnsafeMutablePointer<CMSampleBuffer?>.allocate(capacity: 1)
							
							CMSampleBufferGetSampleTimingInfo(buffer, at: 0, timingInfoOut: timingInfo)
							timingInfo.pointee.duration = CMTimeMultiplyByFloat64(timingInfo.pointee.duration, multiplier: Float64(originFPS/targetFPS))
							CMSampleBufferCreateCopyWithNewTiming(allocator: nil, sampleBuffer: buffer, sampleTimingEntryCount: 1, sampleTimingArray: timingInfo, sampleBufferOut: newSample)
							videoInput.append(newSample.pointee!)
							newSample.deinitialize(count: 1)
							newSample.deallocate()
							timingInfo.deinitialize(count: 1)
							timingInfo.deallocate()
						}
						counter += 1
					} else {
						break
					}
				} else {
					videoInput.markAsFinished()
					completionHandler()
					break
				}
			}
		}
	}
}

extension VideoCompressionManager {
	
	private func startVideoCompressing(asset: AVAsset, fileType: AVFileType, videoTrack: AVAssetTrack, audioTrack: AVAssetTrack?, videoSettigs: [String: Any]?, audioSettings: [String: Any]?, targetFPS: Float, completionHandler: @escaping (Result<URL, Error>) -> Void) {
		
		let videoOutputSettings: [String: Any] = [
			kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA
		]
		let videoOutput = AVAssetReaderTrackOutput.init(track: videoTrack, outputSettings: videoOutputSettings)
		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettigs)
		videoInput.transform = videoTrack.preferredTransform
		
		do {
			var outputURL = try self.fileManager.getTempDirectory(with: AppDirectories.compressedVideo.name)
			let outputVideoName = UUID().uuidString + ".\(fileType.fileExtension)"
			outputURL.appendPathComponent(outputVideoName)
			self.videoPath.append(outputURL)
			
			let reader = try AVAssetReader(asset: asset)
			let writer = try AVAssetWriter(outputURL: outputURL, fileType: fileType)
			
			self.reader = reader
			self.writer = writer
			
			if reader.canAdd(videoOutput) {
				reader.add(videoOutput)
				videoOutput.alwaysCopiesSampleData = false
			}
			
			if writer.canAdd(videoInput) {
				writer.add(videoInput)
			}
			
			var audioInput: AVAssetWriterInput?
			var audioOutput: AVAssetReaderTrackOutput?
			
			if let audioTrack = audioTrack, let audioSettings = audioSettings {
				let outputAudioSettings: [String: Any] = [
					AVFormatIDKey: kAudioFormatLinearPCM,
					AVNumberOfChannelsKey: 2
				]
				audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputAudioSettings)
				let audioWriteInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
				audioInput = audioWriteInput
				
				if reader.canAdd(audioOutput!) {
					reader.add(audioOutput!)
				}
				
				if writer.canAdd(audioWriteInput) {
					writer.add(audioWriteInput)
				}
			}
			
			reader.startReading()
			writer.startWriting()
			writer.startSession(atSourceTime: CMTime.zero)
			
			group.enter()
			
			let reduceFPS = targetFPS < videoTrack.nominalFrameRate
			
			if reduceFPS {
				self.getOuputVideoDataByReducingFPS(originFPS: videoTrack.nominalFrameRate,
													targetFPS: targetFPS,
													videoInput: videoInput,
													videoOuput: videoOutput,
													duration: videoTrack.asset!.duration) {
					self.group.leave()
				}
			} else {
				self.getOutputVideoData(videoInput: videoInput,
										videoOutput: videoOutput) {
					self.group.leave()
				}
			}
			
			if let realAudioInput = audioInput, let realAudioOutput = audioOutput {
				group.enter()
				
				realAudioInput.requestMediaDataWhenReady(on: audioCompressionQueue) {
					while realAudioInput.isReadyForMoreMediaData {
						if let buffer = realAudioOutput.copyNextSampleBuffer() {
							realAudioInput.append(buffer)
						} else {
							realAudioInput.markAsFinished()
							self.group.leave()
							break
						}
					}
				}
			}
			
			group.notify(queue: .main) {
				switch writer.status {
					case .writing, .completed:
						writer.finishWriting {
							DispatchQueue.main.sync {
								completionHandler(.success(outputURL))
							}
						}
					default:
						completionHandler(.failure(writer.error!))
				}
			}
			
		} catch {
			completionHandler(.failure(error))
		}
	}
}

extension VideoCompressionManager {
	
	public func compressVideo(from url: URL, quality: VideoCompressionQuality = .medium, completionHandler: @escaping (Result<URL, Error>) -> Void) {
		
		let asset = AVAsset(url: url)
		
		guard let videoTrack = asset.tracks(withMediaType: .video).first else {
			completionHandler(.failure(VideoCompressionErrorHandler.noVideoFile))
			return
		}
		
		let originBitrate = Int(videoTrack.estimatedDataRate)
		let targetVideoBitrate = self.calculateBitrate(with: quality, originBitrate: originBitrate)
		let scaleSize = self.calculateSize(with: quality, originalSize: videoTrack.naturalSize)
		let videoSettings = self.createVideoSettings(with: targetVideoBitrate, maxKeyFrameInterval: 10, size: scaleSize)
		var audioTrack: AVAssetTrack?
		var audioSettings: [String: Any]?
		
		if let audioAssetTrack = asset.tracks(withMediaType: .audio).first {
			audioTrack = audioAssetTrack
			let audioBitrate: Int = quality == .low ? 96_000 : 128_000
			let audioSampleRate: Int = 44100
			
			audioSettings = self.createAudioSettings(with: audioAssetTrack, bitrate: audioBitrate, sampleRate: audioSampleRate)
		}
		
		self.startVideoCompressing(asset: asset, fileType: .mp4, videoTrack: videoTrack, audioTrack: audioTrack, videoSettigs: videoSettings, audioSettings: audioSettings, targetFPS: quality.preSavedValues.fps, completionHandler: completionHandler)
	}
	
	
	public func compressVideo(from url: URL, with config: VideoCompressionConfig, completionHandler: @escaping (Result<URL, Error>) -> Void) {
		
		let asset = AVAsset(url: url)
		
		guard let videoTrack = asset.tracks(withMediaType: .video).first else {
			completionHandler(.failure(VideoCompressionErrorHandler.noVideoFile))
			return
		}
		
		let targetSize = self.calculateSize(with: config.scaleResolution, originalSize: videoTrack.naturalSize)
		let videoSettings = self.createVideoSettings(with: config.videoBitrate, maxKeyFrameInterval: config.maximumVideoKeyframeInterval, size: targetSize)
		
		var audioTrack: AVAssetTrack?
		var audioSettings: [String: Any]?
		
		if let assetAudioTrack = asset.tracks(withMediaType: .audio).first {
			if !config.removeAudioComponent {
				audioTrack = assetAudioTrack
				audioSettings = self.createAudioSettings(with: assetAudioTrack, bitrate: config.audioBitrate, sampleRate: config.audioSampleRate)
			}
		}
		
		self.startVideoCompressing(asset: asset, fileType: config.fileType, videoTrack: videoTrack, audioTrack: audioTrack, videoSettigs: videoSettings, audioSettings: audioSettings, targetFPS: config.fps, completionHandler: completionHandler)
	}
}

extension VideoCompressionManager {
	
	public func removeAudioComponentFromVideo(with url: URL, completionHandler: @escaping (Result<URL, Error>) -> Void) {
		
		let asset = AVURLAsset(url: url)
		
		guard let inputVideoTrack = asset.tracks(withMediaType: .video).first else {
			completionHandler(.failure(VideoCompressionErrorHandler.noVideoFile))
			return
		}
		
		let composition = AVMutableComposition()
		let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
		compositionVideoTrack!.preferredTransform = asset.preferredTransform
		let range = CMTimeRange(start: .zero, duration: asset.duration)
		
		do {
			try compositionVideoTrack?.insertTimeRange(range, of: inputVideoTrack, at: .zero)
			var outputURL = try self.fileManager.getTempDirectory(with: AppDirectories.compressedVideo.name)
			let ouputVideoName = UUID().uuidString + ".\(FileFormat.mp4.fileExtension)"
			outputURL.appendPathComponent(ouputVideoName)
			
			guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
			exportSession.outputFileType = .mp4
			exportSession.outputURL = outputURL
			
			exportSession.exportAsynchronously(completionHandler: {
				switch exportSession.status {
					case .completed:
						DispatchQueue.main.async {
							completionHandler(.success(outputURL))
						}
					case .exporting:
						debugPrint(exportSession.status)
					default:
						completionHandler(.failure(VideoCompressionErrorHandler.errorRemoveAudioComponent))
				}
			})
		} catch {
			completionHandler(.failure(error))
		}
	}
}
