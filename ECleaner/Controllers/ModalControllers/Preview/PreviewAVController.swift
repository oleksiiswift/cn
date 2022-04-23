//
//  PreviewAVController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 13.07.2021.
//

import UIKit
import AVKit
import Photos

class PreviewAVController: AVPlayerViewController {
    
    init(asset: PHAsset) {
        super.init(nibName: nil, bundle: nil)
        
        self.showsPlaybackControls = false
		self.view.backgroundColor = theme.backgroundColor
        
		if asset.isPortrait {
			switch Screen.size {
				case .small, .medium, .plus, .large:
					let originSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
					let screenRect = CGRect(x: 0, y: 0, width: U.screenWidth, height: U.screenHeight - 250)
					let preViewSize = AVMakeRect(aspectRatio: originSize, insideRect: screenRect).size
					preferredContentSize = preViewSize
				case .modern, .max, .madMax:
					preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
			}
		} else {
			preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
		}
		
		let options = PHVideoRequestOptions()
		options.version = .current
		options.isNetworkAccessAllowed = true
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            U.UI {
                if avAsset != nil {
                    let player = AVPlayer(playerItem: AVPlayerItem(asset: avAsset!))
                    self.player = player
                    self.player?.play()
                } else {
                    return
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
