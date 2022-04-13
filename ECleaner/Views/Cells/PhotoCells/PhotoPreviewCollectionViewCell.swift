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
	@IBOutlet weak var sliderContainerView: UIView!
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
	private var isContunuesPlaying = false
	private var isSeekInProgress = false
	private var timeObserver: Any?
	
	let panContainerGestureRecognizer = UIPanGestureRecognizer()

    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		gestureReconizerSetup()
		updateColors()
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if keyPath == C.key.observers.player.duration, let duration = self.phassetMediaPlayer.currentItem?.duration.seconds, duration > 0.0 {
			if let currentItem = self.phassetMediaPlayer.currentItem {
				self.videoDurationLeftTextLabel.text = currentItem.duration.durationText
			}
		}
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
		self.currentPHAsset = phasset
		
		switch contentType {
			case .userPhoto:
				self.loadImagePreview(for: phasset, imageManager: imageManager, size: size)
			case .userVideo:
				self.loadAVASSetPreview(for: phasset, imageManager: imageManager)
			default:
				return
		}
	}
	
	private func loadImagePreview(for phasset: PHAsset, imageManager: PHCachingImageManager, size: CGSize) {
		
		self.imageManager = imageManager
		let options = PhotoManager.shared.requestOptions
		
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
	
	private func loadAVASSetPreview(for phasset: PHAsset, imageManager: PHCachingImageManager) {
		
		resetSliderDurationValues()
		updateSliderDurationOriginValue()
		
		imageManager.requestAVAsset(forVideo: phasset, options: nil) { videoAVAsset, _, _ in
			if let videoAVAsset = videoAVAsset {
				U.UI {
					self.playerItem = AVPlayerItem(asset: videoAVAsset)
					self.phassetMediaPlayer = AVPlayer(playerItem: self.playerItem)
					let playerVideoLayer = AVPlayerLayer(player: self.phassetMediaPlayer)
					playerVideoLayer.frame = CGRect(x: 0, y: 0, width: self.videoPreviewView.frame.width, height: self.videoPreviewView.frame.height)
					playerVideoLayer.name = C.key.observers.player.playerLayer
					playerVideoLayer.videoGravity = .resizeAspect
					playerVideoLayer.backgroundColor = UIColor.black.cgColor
					self.videoPreviewView.layer.addSublayer(playerVideoLayer)
					self.updateSliderDurationOriginValue()
					self.timeObserverSetup()
					self.setupPlayerObservers()
				}
			} else {
				debugPrint("error loading phasset")
			}
		}
	}

	public func configureLayout(with contentType: MediaContentType) {

		switch contentType {
			case .userPhoto:
				setVideoLayout(isActive: false)
			case .userVideo:
				setVideoLayout(isActive: true)
			default:
				return
		}
	}

	private func setVideoLayout(isActive: Bool) {
		
		photoImageView.isHidden = isActive
		videoPreviewView.isHidden = !isActive
		remoteControlContainerView.isHidden = !isActive
		remoteControllHeightConstraint.constant = isActive ? 80 : 0
		isActive ? videoPreviewView.layoutIfNeeded() : ()
	}
}

extension PhotoPreviewCollectionViewCell {
	
	private func didPlayCurrenMediaItem() {
		
		if isPlaying {
			self.phassetMediaPlayer.pause()
			self.isPlaying = false
			self.handlePlayerButton()
		} else {
			if let _ = self.phassetMediaPlayer.currentItem {
				self.phassetMediaPlayer.play()
				self.isPlaying = true
				self.handlePlayerButton()
			} else {
				debugPrint("erroor")
			}
		}
	}
	
	private func handlePlayerButton() {
		
		let playerCurrentImage = isPlaying ? I.player.pause : I.player.play
		playCurrentItemButton.setImage(playerCurrentImage, for: .normal)
	}
	
	private func durationSliderValueDidChange(with touch: UITouch, of slider: UISlider) {
	
		let currentDuration = getOriginDurationValue()
		let currentTime = CMTime(seconds: Double(slider.value), preferredTimescale: 1)
		
		switch touch.phase {
			case .began:
				self.isSeekInProgress = true
			case .moved:
				if isPlaying {
					self.phassetMediaPlayer.pause()
				}
				self.phassetMediaPlayer.seek(to: currentTime) { [weak self] _ in
					guard let `self` = self else { return}
					self.updateLabelsTimesCodes(by: currentTime, with: currentDuration)
				}
			case .ended:
				self.phassetMediaPlayer.seek(to: currentTime) { [weak self] _ in
					guard let `self` = self else { return }
					
					self.isSeekInProgress = false
					
					if self.isPlaying {
						self.phassetMediaPlayer.play()
					}
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
				self.resetPHAssetPreview()
			case .userVideo:
				self.resetAVPHAssetPreview()
			default:
				return
		}
	}
	
	private func resetPHAssetPreview() {
		
		photoImageView.image = nil
		
		if imageRequestID != nil && imageManager != nil {
			imageManager!.cancelImageRequest(imageRequestID!)
		}
		
		imageRequestID = nil
		imageManager = nil
	}
	
	private func resetAVPHAssetPreview() {
		
		self.clearPlayerLayer()
		self.removePlayerObservers()
		self.isPlaying = false
		self.playerItem = nil
		self.currentPHAsset = nil
		
		self.currentTimePositionTextLabel.text = nil
		self.videoDurationLeftTextLabel.text = nil
		self.durationTimeSlider.value = 0
		
		if let _ = self.phassetMediaPlayer.currentItem {
			self.phassetMediaPlayer.replaceCurrentItem(with: nil)
		}
	}
	
	private func clearPlayerLayer() {
		
		guard let sublayers = videoPreviewView.layer.sublayers else { return }
		
		for sublayer in sublayers {
			if sublayer.name == C.key.observers.player.playerLayer {
				sublayer.removeFromSuperlayer()
			}
		}
	}
}

//		MARK: - player state observers -
extension PhotoPreviewCollectionViewCell {
	
	private func setPHAssetPlayerObserver(for playerItem: AVPlayerItem?) {
		
		guard let _ = playerItem else { return }
		
		self.playerObserver = playerItem!.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
			debugPrint(playerItem.status)
		})
	}
	
	private func timeObserverSetup() {
		
		let timeObserverFPS: Int = 60
		let scaleObserveValue: Double = 1 / Double(timeObserverFPS)
		let timeInterval = CMTime(seconds: scaleObserveValue, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		
		self.timeObserver = self.phassetMediaPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main, using: { (CMTime) in
			
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
	
	private func gestureReconizerSetup() {
		
		panContainerGestureRecognizer.delegate = self
		remoteControlContainerView.addGestureRecognizer(panContainerGestureRecognizer)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDurationSlider(gestureRecognizer:)))
		self.durationTimeSlider.addGestureRecognizer(tapGestureRecognizer)
		
		let playPauseTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePlayPauseCenterVideoPreviewTap))
		self.videoPreviewView.addGestureRecognizer(playPauseTapGestureRecognizer)
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

extension PhotoPreviewCollectionViewCell {
	
	@objc func didTapDurationSlider(gestureRecognizer: UIGestureRecognizer) {
		
		guard let _ = self.playerItem else { return }
		
		self.isSeekInProgress = true
		
		let point = gestureRecognizer.location(in: self.durationTimeSlider)
		let positionSlider: CGPoint = durationTimeSlider.frame.origin
		let width = self.durationTimeSlider.frame.size.width
		let newValue = ((point.x - positionSlider.x) * CGFloat(durationTimeSlider.maximumValue) / width)
		
		self.durationTimeSlider.setValue(Float(newValue), animated: false)
		
		let currentDuration = getOriginDurationValue()
		
		let currentTime = CMTime(seconds: Double(newValue), preferredTimescale: 1)
		self.updateLabelsTimesCodes(by: currentTime, with: currentDuration)
		
		self.phassetMediaPlayer.seek(to: currentTime) { [weak self] _ in
			guard let `self` = self else { return }
			self.isSeekInProgress = false
		}
	}
	
	@objc func handlePlayPauseCenterVideoPreviewTap() {
		self.didPlayCurrenMediaItem()
	}
}

extension PhotoPreviewCollectionViewCell: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
   }
	
   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	   if gestureRecognizer == panContainerGestureRecognizer {
		   let point = gestureRecognizer.location(in: self.remoteControlContainerView)
		   
		   if self.remoteControlContainerView.bounds.contains(point) {
			   return false
		   }
	   }
	   return true
   }
	
   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
	   let point = touch.location(in: self.remoteControlContainerView)
	   
	   if self.remoteControlContainerView.frame.contains(point) {
		   if gestureRecognizer == panContainerGestureRecognizer {
			   return true
		   }
	   }
	   return true
   }
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
	   return true
   }
}

