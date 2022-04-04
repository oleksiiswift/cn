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
	
	@IBOutlet weak var sliderShadowBackroundView: SliderShadowView!
	@IBOutlet weak var reuseShadowView: PreviewCollectionShadowView!
	@IBOutlet weak var trackingSliderArea: UIView!
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
	
	private var phassetMediaPlayer: AVPlayer = AVPlayer()
	private var playerItem: AVPlayerItem?
	private var playerObserver: NSKeyValueObservation!
	
	public var isPlaying: Bool = false
	private var isSeekInProgress = false
	private var timeObserver: Any?
		
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == C.key.observers.player.duration, let duration = self.phassetMediaPlayer.currentItem?.duration.seconds, duration > 0.0 {
			if let currentItem = self.phassetMediaPlayer.currentItem {
				self.videoDurationLeftTextLabel.text = currentItem.duration.durationText
			}
		}
	}
	
	
	#warning("TODO !!!! important")
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let touchRect = self.bounds
		
		if touchRect.contains(point) {
			let touchPoint = self.convert(point, to: durationTimeSlider)
			
			if durationTimeSlider.bounds.contains(touchPoint) {
				return durationTimeSlider
			}
			return self
					
		}
		return self
	}
	

	@IBAction func sliderDurationDidChange(_ sender: Any, event: UIEvent? = nil) {
		
		if let touch = event?.allTouches?.first, let sender = sender as? UISlider {
			self.durationSliderValueDidChange(with: touch, of: sender)
		}
	}

	@IBAction func didTapPlayCurrentMediaItemActionButton(_ sender: Any) {
		
		playCurrentItemButton.animateButtonTransform()
		self.didPlayCurrenMediaItem()
	}
}

extension PhotoPreviewCollectionViewCell {
	
	public func configurePreview(from phasset: PHAsset, imageManager: PHCachingImageManager, size: CGSize, of contentType: MediaContentType) {
		
		self.unloadImagePreview(with: contentType)
		self.imageManager = imageManager
		self.currentPHAsset = phasset
		let options = PhotoManager.shared.requestOptions
	
		resetSliderDurationValues()
		updateSliderDurationOriginValue()
		
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
		
		if isPlaying {
			self.phassetMediaPlayer.pause()
			self.isPlaying = false
			self.handlePlayerButton()
		} else {
			if let phasset = currentPHAsset {
				if let _ = self.phassetMediaPlayer.currentItem {
					self.phassetMediaPlayer.play()
					self.isPlaying = true
					self.handlePlayerButton()
				} else {
					self.didStartLoadPlayerItem(for: phasset)
				}
			}
		}
	}
	
	private func handlePlayerButton() {
		
		let playerCurrentImage = isPlaying ? I.player.pause : I.player.play
		playCurrentItemButton.setImage(playerCurrentImage, for: .normal)
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
					
					self.updateSliderDurationOriginValue()
					self.setPHAssetPlayerObserver(for: self.playerItem)
					self.timeObserverSetup()
					self.setupPlayerObservers()
										
					if let seekTime = seekTime {
						self.phassetMediaPlayer.seek(to: seekTime)
					}
				}
			} else {
				debugPrint("error play video from phasset")
			}
		})
	}

	private func durationSliderValueDidChange(with touch: UITouch, of slider: UISlider) {
		
		guard let phasset = self.currentPHAsset else { return }
		
		let currentDuration = getOriginDurationValue()
		let currentTime = CMTime(seconds: Double(slider.value), preferredTimescale: 1)
		
		switch touch.phase {
			case .began:
				self.isSeekInProgress = true
			case .moved:
				self.updateLabelsTimesCodes(by: currentTime, with: currentDuration)
			case .ended:
				if self.isPlaying {
					self.phassetMediaPlayer.seek(to: currentTime) { [weak self] _ in
						guard let `self` = self else { return }
						self.isSeekInProgress = false
					}
				} else {
					self.didStartLoadPlayerItem(for: phasset, and: currentTime)
					self.isSeekInProgress = false
				}
			default:
				return
		}
	}
}

//		MARK: - remove observers, unload -
extension PhotoPreviewCollectionViewCell {
		
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
				
				self.removePlayerObservers()
				self.isPlaying = false
				self.playerItem = nil
				self.currentPHAsset = nil
				
				self.currentTimePositionTextLabel.text = nil
				self.videoDurationLeftTextLabel.text = nil
				self.durationTimeSlider.value = 0
				
				self.photoImageView.isHidden = false
				self.videoPreviewView.isHidden = true
				
				if let _ = self.phassetMediaPlayer.currentItem {
					self.phassetMediaPlayer.replaceCurrentItem(with: nil)
				}
				
			default:
				return
		}
	}
}

//		MARK: - player state observers -
extension PhotoPreviewCollectionViewCell {
	
	private func setPHAssetPlayerObserver(for playerItem: AVPlayerItem?) {
		
		guard let _ = playerItem else { return }
		
		playerObserver = playerItem!.observe(\AVPlayerItem.status) { (playerItem, _) in
			if playerItem.status == .readyToPlay {
				self.isPlaying = true
				self.phassetMediaPlayer.play()
				self.handlePlayerButton()
			}
		}
	}
	
	private func timeObserverSetup() {
		
		let timeObserverFPS: Int = 30
		let scaleObserveValue: Double = 1 / Double(timeObserverFPS)
		let timeIntervar = CMTime(seconds: scaleObserveValue, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		
		self.timeObserver = self.phassetMediaPlayer.addPeriodicTimeObserver(forInterval: timeIntervar, queue: .main, using: { (CMTime) in
			
			guard let currentItem = self.phassetMediaPlayer.currentItem,
				  currentItem.status.rawValue == AVPlayer.Status.readyToPlay.rawValue,
				  !self.isSeekInProgress else { return }
			
			let currentTime = currentItem.currentTime()
			let duration = currentItem.duration
			self.durationTimeSlider.value = Float(currentTime.seconds)
			self.updateLabelsTimesCodes(by: currentTime, with: duration)
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
		
		self.phassetMediaPlayer.currentItem?.addObserver(self, forKeyPath: C.key.observers.player.duration, options: [.new, .initial], context: nil)
		U.notificationCenter.addObserver(self, selector: #selector(self.playerDidEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
	}
	
	private func removePlayerObservers() {
		
		guard let _ = self.timeObserver else { return }
		
		if self.phassetMediaPlayer.rate == 1 {
			self.phassetMediaPlayer.removeTimeObserver(self.timeObserver!)
			self.timeObserver = nil
		}
		
		self.phassetMediaPlayer.currentItem?.removeObserver(self, forKeyPath: C.key.observers.player.duration)
		U.notificationCenter.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
	}
}
	
//		MARK: - handle duration values -
extension PhotoPreviewCollectionViewCell {
	
	private func getOriginDurationValue() -> CMTime {
		
		if let currentItem = self.phassetMediaPlayer.currentItem {
			return currentItem.duration
		} else if let phasset = self.currentPHAsset {
			return CMTime(seconds: phasset.duration, preferredTimescale: 1000000)
		} else {
			return .zero
		}
	}
	
	private func getStringVideoTimeDuration() -> String {
		let duration = getOriginDurationValue()
		return duration != .zero ? duration.durationText : "00:00"
	}
	
	private func resetSliderDurationValues() {
		currentTimePositionTextLabel.text = "00:00"
		videoDurationLeftTextLabel.text = getStringVideoTimeDuration()
		handlePlayerButton()
	}

	private func updateSliderDurationOriginValue() {
		
		let currentDurationValue = getOriginDurationValue()
		self.durationTimeSlider.minimumValue = 0
		self.durationTimeSlider.maximumValue =  Float(currentDurationValue.seconds)
	}
	
	private func updateLabelsTimesCodes(by currentTime: CMTime, with duration: CMTime) {
		
		let timeLeftInterval = duration - currentTime
		self.videoDurationLeftTextLabel.text = timeLeftInterval.durationText
		self.currentTimePositionTextLabel.text = currentTime.durationText
	}
}

//		MARK: - SETUP - UI -
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
