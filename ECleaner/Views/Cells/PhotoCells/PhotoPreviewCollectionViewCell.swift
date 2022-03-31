//
//  PhotoPreviewCollectionViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.03.2022.
//

import UIKit
import Photos

class PhotoPreviewCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseShadowView: PreviewCollectionShadowView!
	@IBOutlet weak var playCurrentItemButton: PrimaryButton!
	@IBOutlet weak var durationTimeSlider: GradientSlider!
	@IBOutlet weak var currentTimePositionTextLabel: UILabel!
	@IBOutlet weak var videoDurationLeftTextLabel: UILabel!
	
	@IBOutlet weak var videoPreviewView: UIView!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var remoteControlContainerView: UIView!
	@IBOutlet weak var remoteControllHeightConstraint: NSLayoutConstraint!
	
	private var currentPHAsset: PHAsset?
	public var indexPath: IndexPath?
	public var cellMediaType: PhotoMediaType = .none
	public var cellContentType: MediaContentType = .none
	
	private var imageManager: PHCachingImageManager?
	private var imageRequestID: PHImageRequestID?
	
	private var phassetMediaPlayer: AVPlayer!
	private var playerItem: AVPlayerItem!
	private var playerObserver: NSKeyValueObservation!
		
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
    }
	
	@IBAction func sliderDurationDidChange(_ sender: Any, event: UIEvent? = nil) {
		
		if let touch = event?.allTouches?.first, let sender = sender as? UISlider {
			self.durationSiderValueDidChant(with: touch, of: sender)
		}
	}

	@IBAction func didTapPlayCurrentMediaItemActionButton(_ sender: Any) {
		
		self.didPlayCurrenMediaItem()
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == C.key.observers.player.duration, let duration = self.phassetMediaPlayer.currentItem?.duration.seconds, duration > 0.0 {
			if let currentItem = self.phassetMediaPlayer.currentItem {
				self.videoDurationLeftTextLabel.text = currentItem.duration.durationText
			}
		}
	}
}

extension PhotoPreviewCollectionViewCell {
	
	public func configurePreview(from phasset: PHAsset, imageManager: PHCachingImageManager, size: CGSize, of contentType: MediaContentType) {
		
		self.unloadImagePreview(with: contentType)
		self.imageManager = imageManager
		self.currentPHAsset = phasset
		let options = PhotoManager.shared.requestOptions
		
		currentTimePositionTextLabel.text = "00:00"
		videoDurationLeftTextLabel.text = getVideoTimeDuration(from: phasset)
		
		setupSliderActualDuration(from: phasset)
	
		imageRequestID = imageManager.requestImage(for: phasset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { image, info in
			
			if let index = self.indexPath, self.tag == index.section * 1000 + index.row {
				if let loadedImage = image {
					self.photoImageView.image = loadedImage
				} else {
					self.photoImageView.image = nil
				}
			}
		})
	}
	
	private func getVideoTimeDuration(from phasset: PHAsset) -> String {
		
		guard phasset.mediaType == .video else { return "00:00"}
		return CMTime(seconds: phasset.duration, preferredTimescale: 1000000).durationText
	}
	
	public func configureLayout(with contentType: MediaContentType) {

		switch contentType {
			case .userPhoto:
				videoPreviewView.isHidden = true
				remoteControlContainerView.isHidden = true
				remoteControllHeightConstraint.constant = 0
			case .userVideo:
				photoImageView.isHidden = false
				videoPreviewView.isHidden = true
				remoteControlContainerView.isHidden = false
				remoteControllHeightConstraint.constant = 80
			default:
				return
		}
	}
}

extension PhotoPreviewCollectionViewCell {
	
	private func didPlayCurrenMediaItem() {
		
		if let phasset = currentPHAsset {
			didStartLoadPlayerItem(for: phasset)
		}
	}
	
	private func unloadImagePreview(with contentType: MediaContentType) {
		
		switch contentType {
			case .userPhoto:
				photoImageView.image = nil
				
				if imageRequestID != nil && imageManager != nil {
					imageManager!.cancelImageRequest(imageRequestID!)
				}
				
				imageRequestID = nil
				imageManager = nil
			case .userVideo:
				self.playerItem = nil
				if let _ = self.phassetMediaPlayer {
					if let _ = self.phassetMediaPlayer.currentItem {
						self.phassetMediaPlayer.replaceCurrentItem(with: nil)
					}
				}
				U.notificationCenter.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
			default:
				return
		}
	}
	
	private func didStartLoadPlayerItem(for phasset: PHAsset, and seekTime: CMTime? = nil) {
		
		self.imageManager?.requestAVAsset(forVideo: phasset, options: nil, resultHandler: { videoPHAsset, _, _ in
			
			if let videoPHAsset = videoPHAsset {
				DispatchQueue.main.async {
					self.playerItem = AVPlayerItem(asset: videoPHAsset)
					self.phassetMediaPlayer = AVPlayer(playerItem: self.playerItem)
					let playerVideoLayer = AVPlayerLayer(player: self.phassetMediaPlayer)
					playerVideoLayer.frame = self.videoPreviewView.frame
					playerVideoLayer.videoGravity = .resizeAspect
					self.videoPreviewView.isHidden = false
					self.videoPreviewView.layer.addSublayer(playerVideoLayer)
					self.photoImageView.isHidden = true
					self.setPHAssetPlayerObserver(for: self.playerItem)
					self.timeObserver()
					self.phassetMediaPlayer.currentItem?.addObserver(self, forKeyPath: C.key.observers.player.duration, options: [.new, .initial], context: nil)

					U.notificationCenter.addObserver(self, selector: #selector(self.playerDidEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
					
					if let seekTime = seekTime {
						self.phassetMediaPlayer.seek(to: seekTime)
					}
				}
			} else {
				debugPrint("error play video from phasset")
			}
		})
	}

	private func setPHAssetPlayerObserver(for playerItem: AVPlayerItem) {
		
		playerObserver = playerItem.observe(\AVPlayerItem.status) { [weak self] (playerItem, _) in
			if playerItem.status == .readyToPlay {
				self?.phassetMediaPlayer.play()
			}
		}
	}
	
	private func durationSiderValueDidChant(with touch: UITouch, of slider: UISlider) {
		
		guard let assset = self.currentPHAsset else { return }
		
		if touch.phase == .ended {
			let currentTime = CMTime(seconds: Double(durationTimeSlider.value), preferredTimescale: 1)
			
			if let _ = self.phassetMediaPlayer {
				self.phassetMediaPlayer.pause()
				self.phassetMediaPlayer.seek(to: currentTime)
				self.phassetMediaPlayer.play()
			} else {
				self.didStartLoadPlayerItem(for: assset, and: currentTime)
			}
		} else if touch.phase == .moved {
			let duration = CMTime(seconds: assset.duration, preferredTimescale: 1000000)
			let currentTime = CMTime(seconds: Double(slider.value), preferredTimescale: 1)
			let timeLeft = duration - currentTime
			currentTimePositionTextLabel.text = currentTime.durationText
			videoDurationLeftTextLabel.text = timeLeft.durationText
		}
	}
	
	private func timeObserver() {
	
		let queue = DispatchQueue.main
		let timeObserverFPS: Int = 30
		let scaleObserveValue: Double = 1 / Double(timeObserverFPS)
		
		let timeIntervar = CMTime(seconds: scaleObserveValue, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		_ = phassetMediaPlayer.addPeriodicTimeObserver(forInterval: timeIntervar, queue: queue, using: { CMTime in
			
			guard let currentItem = self.phassetMediaPlayer.currentItem,
					currentItem.status.rawValue == AVPlayer.Status.readyToPlay.rawValue,
					!self.durationTimeSlider.isTracking else { return }
			
			self.durationTimeSlider.value = Float(currentItem.currentTime().seconds)
			
			let timeLeft = currentItem.duration - currentItem.currentTime()
			self.videoDurationLeftTextLabel.text = timeLeft.durationText
			self.currentTimePositionTextLabel.text = currentItem.currentTime().durationText
		})
	}
	
	private func setupSliderActualDuration(from phasset: PHAsset) {
		
		let phassetDuration: Float = Float(CMTime(seconds: phasset.duration, preferredTimescale: 1).seconds)
		self.durationTimeSlider.minimumValue = 0
		self.durationTimeSlider.maximumValue = phassetDuration
	}

	@objc func playerDidEndPlay() {
		
		playerItem.seek(to: .zero) { finished in
			if finished {
				debugPrint("seek slider to start")
			}
		}
	}
}

extension PhotoPreviewCollectionViewCell: Themeble {
	
	public func setupUI() {
		
		self.setCorner(6)
		self.contentView.setCorner(8)
		baseView.setCorner(14)
		reuseShadowView.layoutIfNeeded()
		reuseShadowView.layoutSubviews()
		
		playCurrentItemButton.setImage(I.player.play, for: .normal)
		
		currentTimePositionTextLabel.font = .systemFont(ofSize: 11, weight: .medium)
		currentTimePositionTextLabel.textAlignment = .left
		videoDurationLeftTextLabel.font = .systemFont(ofSize: 11, weight: .medium)
		videoDurationLeftTextLabel.textAlignment = .right
		
		durationTimeSlider.sliderHeight = 14
		durationTimeSlider.thumbImage = I.player.sliderThumb
		durationTimeSlider.isContinuous = true
		durationTimeSlider.value = .zero
	}
	
	func updateColors() {
		
		baseView.backgroundColor = theme.backgroundColor
		videoPreviewView.backgroundColor = .black
		
		durationTimeSlider.minTrackStartColor = theme.minimumSliderColor
		durationTimeSlider.minTrackEndColor = theme.maximumSliderTrackColor
		durationTimeSlider.maxTrackColor = theme.msximumSliderkColor
		
		currentTimePositionTextLabel.textColor = theme.sectionTitleTextColor
		videoDurationLeftTextLabel.textColor = theme.sectionTitleTextColor
	}
}
