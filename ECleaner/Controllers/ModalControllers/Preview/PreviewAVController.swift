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
        preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
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
