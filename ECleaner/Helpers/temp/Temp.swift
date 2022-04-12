//
//  Temp.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import Foundation

//private var fileManager = ECFileManager()
//private var photoManager = PhotoManager.shared
//private var videoCompressionManager = VideoCompressionManager.insstance


//
//
//extension VideoCompressingViewController {
//	
//	private func videoCompressingWithConfiguration() {
//		
//		if let processingPHAsset = processingPHAsset {
//			
//			processingPHAsset.getPhassetURL { responseURL in
//			
//				guard let url = responseURL else { return }
//				
//				let config = VideoCompressionConfig(videoBitrate: 1000_000, audioBitrate: 128_000, fps: 30, audioSampleRate: 44100, maximumVideoKeyFrameInterval: 10, scaleResolution: nil, fileType: .mp4)
//				
//				self.videoCompressionManager.compressVideo(from: url, with: config) { result in
//					switch result {
//						case .success(let compressedVideoURL):
//							self.photoManager.saveVideoAsset(from: compressedVideoURL) { isSaved in
//								self.navigationController?.popViewController(animated: true)
//							}
//						case .failure(let error):
//							debugPrint(error)
//					}
//				}
//			}
//		}
//	}
//	
//	private func removeAudeoComponentFromPHAsset() {
//		
//		if let processingPHAsset = processingPHAsset {
//			processingPHAsset.getPhassetURL { responseURL in
//				
//				guard let url = responseURL else { return}
//				
//				self.videoCompressionManager.removeAudioComponentFromVideo(with: url) { result in
//					switch result {
//						case .success(let outputURL):
//							self.photoManager.saveVideoAsset(from: outputURL) { isSaved in
//								debugPrint(isSaved)
//							}
//						case .failure(let error):
//							debugPrint(error)
//					}
//				}
//			}
//		}
//	}
//}
//
