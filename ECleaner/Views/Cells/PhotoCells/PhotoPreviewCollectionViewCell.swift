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
	
	@IBOutlet weak var videoPreviewView: UIView!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var remoteControlContainerView: UIView!
	@IBOutlet weak var remoteControllHeightConstraint: NSLayoutConstraint!
	
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
	
	
	@IBAction func didTapPlayCurrentMediaItemActionButton(_ sender: Any) {
		
		
		
	}
}

extension PhotoPreviewCollectionViewCell {
	
	public func configurePreview(from phasset: PHAsset, imageManager: PHCachingImageManager, size: CGSize, of contentType: MediaContentType) {
		
		self.unloadImagePreview(with: contentType)
		self.imageManager = imageManager
		let options = PhotoManager.shared.requestOptions
		
		imageRequestID = imageManager.requestImage(for: phasset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { image, info in
			
			if let index = self.indexPath, self.tag == index.section * 1000 + index.row {
				if let loadedImage = image {
					self.photoImageView.image = loadedImage
					
					U.delay(2) {
						self.didStartLoadPlayerItem(for: phasset)
					}
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
		
		setPHAssetPlayerObserver(for: self.playerItem)
		U.notificationCenter.addObserver(self, selector: #selector(playerDidEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
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
	
	private func didStartLoadPlayerItem(for phasset: PHAsset) {
		
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
	}
	
	func updateColors() {
		
		baseView.backgroundColor = theme.backgroundColor
		videoPreviewView.backgroundColor = .black
	}
}


class GradientSlider: UISlider {
	
	var height: CGFloat = 20
	var thumbImage: UIImage?
	
	var minimumTrackerStartColor: UIColor = .yellow
	var minimumTrackerEndColor: UIColor = .red
	var maximumTrackerColor: UIColor = .orange
	
	private func setup() {
		
		
		
	}
	
	
	private func setGradient(size: CGSize, colors: [CGColor]) throws -> UIImage? {
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		gradientLayer.cornerRadius = gradientLayer.frame.height / 2
		gradientLayer.masksToBounds = false
		gradientLayer.colors = colors
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		
		UIGraphicsBeginImageContextWithOptions(size, gradientLayer.isOpaque, 0.0);
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		gradientLayer.render(in: context)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets:
		UIEdgeInsets.init(top: 0, left: size.height, bottom: 0, right: size.height))
		UIGraphicsEndImageContext()
		return image!
	}
	

	//
}


//
//	func setup() {
//		let minTrackStartColor = Palette.SelectiveYellow
//		let minTrackEndColor = Palette.BitterLemon
//		let maxTrackColor = Palette.Firefly
//		do {
//			self.setMinimumTrackImage(try self.gradientImage(
//			size: self.trackRect(forBounds: self.bounds).size,
//			colorSet: [minTrackStartColor.cgColor, minTrackEndColor.cgColor]),
//								  for: .normal)
//			self.setMaximumTrackImage(try self.gradientImage(
//			size: self.trackRect(forBounds: self.bounds).size,
//			colorSet: [maxTrackColor.cgColor, maxTrackColor.cgColor]),
//								  for: .normal)
//			self.setThumbImage(sliderThumbImage, for: .normal)
//		} catch {
//			self.minimumTrackTintColor = minTrackStartColor
//			self.maximumTrackTintColor = maxTrackColor
//		}
//	}
//
//
//	override func trackRect(forBounds bounds: CGRect) -> CGRect {
//		return CGRect(
//			x: bounds.origin.x,
//			y: bounds.origin.y,
//			width: bounds.width,
//			height: thickness
//		)
//	}
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		setup()
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		setup()
//	}
//
//
//}
//
