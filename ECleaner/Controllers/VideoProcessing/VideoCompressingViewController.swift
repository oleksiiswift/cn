//
//  VideoCompressingViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import UIKit
import Photos

class VideoCompressingViewController: UIViewController {
	
	var processingPHAsset: PHAsset?
	
	private var fileManager = ECFileManager()
	private var photoManager = PhotoManager.shared
	private var videoCompressionManager = VideoCompressionManager.insstance

    override func viewDidLoad() {
        super.viewDidLoad()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	
	}
}

extension VideoCompressingViewController {
	
	private func videoCompressingWithConfiguration() {
		
		if let processingPHAsset = processingPHAsset {
			
			processingPHAsset.getPhassetURL { responseURL in
			
				guard let url = responseURL else { return }
				
				let config = VideoCompressionConfig(videoBitrate: 1000_000, audioBitrate: 128_000, fps: 30, audioSampleRate: 44100, maximumVideoKeyFrameInterval: 10, scaleResolution: nil, fileType: .mp4)
				
				self.videoCompressionManager.compressVideo(from: url, with: config) { result in
					switch result {
						case .success(let compressedVideoURL):
							self.photoManager.saveVideoAsset(from: compressedVideoURL) { isSaved in
								#warning("TODO")
							}
						case .failure(let error):
							debugPrint(error)
					}
				}
			}
		}
	}
	
	private func removeAudeoComponentFromPHAsset() {
		
		if let processingPHAsset = processingPHAsset {
			processingPHAsset.getPhassetURL { responseURL in
				
				guard let url = responseURL else { return}
				
				self.videoCompressionManager.removeAudioComponentFromVideo(with: url) { result in
					switch result {
						case .success(let outputURL):
							self.photoManager.saveVideoAsset(from: outputURL) { isSaved in
								debugPrint(isSaved)
							}
						case .failure(let error):
							debugPrint(error)
					}
				}
			}
		}
	}
}
