//
//  VideoPreviewTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import UIKit
import Photos

class VideoPreviewTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var sliderShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var videoPreview: UIView!
	@IBOutlet weak var sliderView: SliderView!
	@IBOutlet weak var playPauseButton: UIButton!
	
	private var asset: PHAsset?
	private var imageManager: PHCachingImageManager?
	
	private var player: AVPlayer = AVPlayer()
	private var playerItem: AVPlayerItem?
	private var playerObserver: NSKeyValueObservation!
	private var isPlaying = false
	private var isContinuesPlaying = false
	private var isSeekInProgress = false
	private var timeObserver: Any?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
		setupSlider()
		setupDelegate()
    }

	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if keyPath == C.key.observers.player.duration, let duration = self.player.currentItem?.duration.seconds, duration > 0.0 {
			if let currentItem = self.player.currentItem {
				debugPrint(currentItem.currentTime())
			}
		}
	}
	
	@IBAction func didTapPlayPauseVideo(_ sender: Any) {
		
		didPlayCurrentMediaItem()
	}
}

extension VideoPreviewTableViewCell {
	
	public func configurePreview(from phasset: PHAsset, imageManager: PHCachingImageManager, size: CGSize) {
		
		self.asset = phasset
		imageManager.requestAVAsset(forVideo: phasset, options: nil) { videoAVAsset, _, _ in
			if let videoAVAsset = videoAVAsset {
				U.UI {
					self.sliderView.minDuration = videoAVAsset.duration.seconds
					self.sliderView.maxDuration = videoAVAsset.duration.seconds
					self.sliderView.assetPreview.maxDuration = videoAVAsset.duration.seconds
					self.sliderView.asset = videoAVAsset
					
					
					self.playerItem = AVPlayerItem(asset: videoAVAsset)
					self.player = AVPlayer(playerItem: self.playerItem)
					let playerVideoLayer = AVPlayerLayer(player: self.player)
					playerVideoLayer.frame = CGRect(x: 0, y: 0, width: self.videoPreview.frame.width, height: self.videoPreview.frame.height)
					playerVideoLayer.videoGravity = .resizeAspect
					playerVideoLayer.backgroundColor = UIColor.black.cgColor
					self.videoPreview.layer.addSublayer(playerVideoLayer)
					self.timeObserverSetup()
					self.setupPlayerObservers()
				}
			}
		}
	}
}

extension VideoPreviewTableViewCell {
	
	private func didPlayCurrentMediaItem() {
		
		if isPlaying {
			self.player.pause()
			self.isPlaying = false
		} else {
			if let _ = self.player.currentItem {
				self.player.play()
				self.isPlaying = true
			}
		}
		self.handlePlayerButton()
	}
	
	private func handlePlayerButton() {
		
		playPauseButton.animateButtonTransform()
		
		if isPlaying {
			playPauseButton.addCenterImage(image: I.player.templatePause, imageWidth: 40, imageHeight: 40)
			U.delay(1) {
				self.playPauseButton.removeCenterImage()
			}
		} else {
			playPauseButton.addCenterImage(image: I.player.templatePlay, imageWidth: 40, imageHeight: 40)
		}
	}
}

extension VideoPreviewTableViewCell {
	
	private func setPHAssetPlayerObserver(for playerItem: AVPlayerItem?) {
		
		guard let _ = playerItem else { return }
		
		self.playerObserver = playerItem!.observe(\.status, options: [.new, .old], changeHandler: { playerItem, change in })
	}
	
	private func timeObserverSetup() {
		
		let timeObserverFPS: Int = 60
		let scaleObserverValue: Double = 1 / Double(timeObserverFPS)
		let timeInterval = CMTime(seconds: scaleObserverValue, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		
		self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main, using: { (CMTime) in
			
			guard let currentItem = self.player.currentItem,
				  currentItem.status.rawValue == AVPlayer.Status.readyToPlay.rawValue,
				  !self.isSeekInProgress else { return }
			
			let currentTime = currentItem.currentTime()
			self.sliderView.seek(to: currentTime)
		})
	}
	
	@objc func playerDidEndPlay() {
		
		guard let _ = playerItem else { return }
		
		playerItem!.seek(to: .zero) { [weak self] finished in
			guard let `self` = self else { return }
			if finished {
				self.isPlaying = false
				self.handlePlayerButton()
			}
		}
	}
	
	private func setupPlayerObservers() {
		
		self.player.currentItem?.addObserver(self, forKeyPath: C.key.observers.player.duration, options: [.new, .initial], context: nil)
		U.notificationCenter.addObserver(self, selector: #selector(self.playerDidEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
	}
}

extension VideoPreviewTableViewCell: SliderViewDelegate {
	
	func didChangePositionBar(_ playerTime: CMTime) {
		
		self.isSeekInProgress = true
		
		if isPlaying {
			self.player.pause()
		}
		
		self.player.seek(to: playerTime)
	}
	
	func positionBarStoppedMoving(_ playerTime: CMTime) {
		self.player.seek(to: playerTime) { [weak self] _ in
			
			guard let `self` = self else { return }
			
			self.isSeekInProgress = false
			
			if self.isPlaying {
				self.player.play()
			}
		}
	}
}

extension VideoPreviewTableViewCell {
	
	private func getOriginDurationValue() -> CMTime {
		if let currentItem = self.player.currentItem {
			return currentItem.duration
		} else if let phasset = self.asset {
			return CMTime(seconds: phasset.duration, preferredTimescale: 1000000)
		} else {
			return .zero
		}
	}
}

//		MARK: - ui setup -
extension VideoPreviewTableViewCell: Themeble {
	
	private func setupUI() {
		
		self.selectionStyle = .none
		self.contentView.setCorner(8)
		self.setCorner(6)
		baseView.setCorner(8)
		videoPreview.setCorner(6)
		sliderShadowView.cornerRadius = 8
		playPauseButton.alpha = 0.8
		playPauseButton.addCenterImage(image: I.player.templatePlay, imageWidth: 40, imageHeight: 40)
	}
	
	private func setupDelegate() {
		
		sliderView.delegate = self
	}
	
	private func setupSlider() {
		
		sliderView.positionBarBorderWidth = 3
		sliderView.positionBarWidth = 9
		sliderView.mobWidth = 0
	}

	func updateColors() {
		
		baseView.backgroundColor = theme.backgroundColor
		videoPreview.backgroundColor = .black
		sliderView.handleColor = theme.backgroundColor
		sliderView.mainColor = theme.backgroundColor
		sliderView.positionBarColor = .clear
		sliderView.positionBarBorderColor = UIColor().colorFromHexString("F07378")
		
		playPauseButton.tintColor = .white
	}
}
