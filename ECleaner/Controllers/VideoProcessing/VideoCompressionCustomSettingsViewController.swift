//
//  VideoCompressionCustomSettingsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.04.2022.
//

import UIKit
import AVFoundation
import SwiftMessages
import Photos

class VideoCompressionCustomSettingsViewController: UIViewController {
	
	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var topShevronView: UIView!
	@IBOutlet weak var controllerTitleTextLabel: UILabel!
	@IBOutlet weak var helperTopView: UIView!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var videoResolutionSliderContainerView: UIView!
	@IBOutlet weak var fpsSliderContainerView: UIView!
	@IBOutlet weak var videoBitrateSliderContainerView: UIView!
	@IBOutlet weak var maximumVideoKeySliderContainerView: UIView!
	@IBOutlet weak var audioBitrateSliderContainerView: UIView!
	@IBOutlet weak var audioSampleRateContainerView: UIView!
	@IBOutlet weak var slidersStackView: UIStackView!
	@IBOutlet weak var resolutionTitleTextLabel: UILabel!
	@IBOutlet weak var fpsTitleTextLabel: UILabel!
	@IBOutlet weak var bitrateTitleTextLabel: UILabel!
	@IBOutlet weak var keyframeTitleTextLabel: UILabel!
	@IBOutlet weak var audioBitrateTitleTextLabel: UILabel!
	
	@IBOutlet weak var bitrateView: UIView!
	@IBOutlet weak var keyframeView: UIView!
	@IBOutlet weak var bitrateTextLabel: UILabel!
	@IBOutlet weak var keyframeTextLabel: UILabel!
	@IBOutlet weak var resolutionSizeTextLabel: UILabel!
	
	@IBOutlet weak var keyframeShadowView: ReuseShadowView!
	@IBOutlet weak var bitrateShadowView: ReuseShadowView!
	@IBOutlet weak var resetButtonShadowView: ReuseShadowView!
	@IBOutlet weak var resetToDafaultButton: UIButton!
	@IBOutlet weak var removeAudioShadowView: ReuseShadowView!
	@IBOutlet weak var removeAudioButton: UIButton!
	
	@IBOutlet var titleLabelsCollection: [UILabel]!
	
	private var dissmissGestureRecognizer = UIPanGestureRecognizer()
	private var resolutionStepSlider = StepSlider()
	private var fpsStepSlider = StepSlider()
	private var videoBitrateSlider = StepSlider()
	private var videoKeyFrameSlider = StepSlider()
	private var audioBitrateSlider = StepSlider()
	private var audioSampleRateSlider = StepSlider()
	private var slidersContainer: [StepSlider] = []
	
	private var isAudioAvailible: Bool = false {
		didSet {
			handlRemoveTrackButtonAvailible()
		}
	}
	
	private var removeAudioComponent: Bool = false {
		didSet {
			handleRemoveAudioComponentButtom()
		}
	}
	
	public var asset: PHAsset?
	
	private var videoResolutionValue: VideoResolution = .res1080p {
		didSet {
			resolutionSizeTextLabel.text = videoResolutionValue.resolutionInfo
			handleValuesDidChange()
		}
	}
	
	private var videoFpsValue: FPS = .fps24 {
		didSet {
			handleValuesDidChange()
		}
	}
	
	private var videoBitrateValue: Int = 1000_000 {
		didSet {
			let value = videoBitrateValue / 1000_000
			bitrateTextLabel.text = String(value) + "Mbs"
			handleValuesDidChange()
		}
	}
	
	private var videoKeyframeValue: Int = 10 {
		didSet {
			keyframeTextLabel.text = String(videoKeyframeValue)
			handleValuesDidChange()
		}
	}
	private var audioBitrateValue: AudioBitrate = .bit128 {
		didSet {
			handleValuesDidChange()
		}
	}
	
	private var compressionConfig = VideoCompressionConfig()
	public var selectVideoCompressingConfig: ((_ compressinggConfig: VideoCompressionConfig) -> Void)?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
		videoResolutionSliderSetupUI()
		pfsSliderSetupUI()
		handleAudioTrackIsEnable()
		videoBitrateSliderSetupUI()
		videoKeyFrameSliderSetupUI()
		audioBitrateSliderSetupUI()
		audioSampleRateSliderSetupUI()
		setupSlidersTarget()
		stupGesturerecognizers()
		setupSliders()
		loadPreSavedConfiguration(CompressionSettingsConfiguretion.getSavedConfiguration())
		updateColors()
		setupDelegate()
		handleValuesDidChange()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
	}
	
	@IBAction func didTapResetToDefaultSettingsActionButton(_ sender: Any) {
		
		resetToDafaultButton.animateButtonTransform()
		let defaultConfiguration = VideoCompressionConfig()
		loadPreSavedConfiguration(defaultConfiguration)
	}
	
	@IBAction func didTapRemoveAudioTrackActionButton(_ sender: Any) {
		
		removeAudioButton.animateButtonTransform()
		removeAudioComponent = !removeAudioComponent
	}
}

extension VideoCompressionCustomSettingsViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		self.setCompressionConfiguration()
	}
}

extension VideoCompressionCustomSettingsViewController {
	
	private func setCompressionConfiguration() {
		
		guard let asset = self.asset else {
			debugPrint("error loading phasset")
			return
		}
		
		let videoBitrate = self.videoBitrateValue
		let audioBitrate = self.audioBitrateValue.rawValue
		let fps = self.videoFpsValue.rawValue
		let audioSampleRate = 44100
		let maximumVideoKeyframeInterval = self.videoKeyframeValue
		
		var resoultion = self.videoResolutionValue.resolutionSize
		
		if asset.isPortrait {
			resoultion = CGSize(width: -1, height: resoultion.height)
		} else {
			resoultion = CGSize(width: resoultion.width, height: -1)
		}
	
		let config = VideoCompressionConfig(videoBitrate: videoBitrate,
											audioBitrate: audioBitrate,
											fps: fps,
											audioSampleRate: audioSampleRate,
											maximumVideoKeyframeInterval: maximumVideoKeyframeInterval,
											scaleResolution: resoultion,
											fileType: .mp4,
											removeAudioComponent: self.removeAudioComponent)
		
		CompressionSettingsConfiguretion.saveCompressionConfiguration(config)
		
		self.dismiss(animated: true) {
			self.selectVideoCompressingConfig?(config)
		}
	}
	
	private func loadPreSavedConfiguration(_ savedConfig: VideoCompressionConfig) {
		
		self.setVideoBitrateSlider(to: savedConfig.videoBitrate)
		self.setAudioBitrateSlider(to: savedConfig.audioBitrate)
		self.setFpsSlider(to: savedConfig.fps)
		self.setKeyIntervalSlider(value: savedConfig.maximumVideoKeyframeInterval)
		if let resolution = savedConfig.scaleResolution {
			self.setResolutionSlider(value: resolution)
		}
		self.removeAudioComponent = savedConfig.removeAudioComponent
	}
	
	private func setupSlidersTarget() {
		
		resolutionStepSlider.addTarget(self, action: #selector(resolutionSliderDidChangeValue), for: .valueChanged)
		fpsStepSlider.addTarget(self, action: #selector(fpsSliderDidChangeValue), for: .valueChanged)
		videoBitrateSlider.addTarget(self, action: #selector(videoBitrateSliderDidChangeValue), for: .valueChanged)
		videoKeyFrameSlider.addTarget(self, action: #selector(videoKeyframeSliderDidChangeValue), for: .valueChanged)
		audioBitrateSlider.addTarget(self, action: #selector(audioBitrateSliderDidChangeValue), for: .valueChanged)
	}
	
	@objc func resolutionSliderDidChangeValue() {
		
		switch resolutionStepSlider.index {
			case 0:
				setResolution(value: .res240p)
			case 1:
				setResolution(value: .res360p)
			case 2:
				setResolution(value: .res480p)
			case 3:
				setResolution(value: .res540p)
			case 4:
				setResolution(value: .res720p)
			case 5:
				setResolution(value: .res1080p)
			default:
				return
		}
	}
	
	private func setResolution(value: VideoResolution) {
		videoResolutionValue = value
	}
	
	@objc func fpsSliderDidChangeValue() {
		
		switch fpsStepSlider.index {
			case 0:
				setFps(value: .fps15)
			case 1:
				setFps(value: .fps24)
			case 2:
				setFps(value: .fps30)
			case 3:
				setFps(value: .fps60)
			default:
				return
		}
	}
	
	private func setFps(value: FPS) {
		videoFpsValue = value
	}
	
	@objc func videoBitrateSliderDidChangeValue() {
		setBitrate(value: videoBitrateSlider.index)
	}
	
	private func setBitrate(value: UInt) {
		videoBitrateValue = Int(value + 1) * 1000_000
	}
	
	@objc func videoKeyframeSliderDidChangeValue() {
		setKeyframe(value: videoKeyFrameSlider.index)
	}
	
	private func setKeyframe(value: UInt) {
		videoKeyframeValue = Int(value) + 1
	}
	
	@objc func audioBitrateSliderDidChangeValue() {
		
		switch audioBitrateSlider.index {
			case 0:
				setAudioBitrate(value: .bit96)
			case 1:
				setAudioBitrate(value: .bit128)
			case 2:
				setAudioBitrate(value: .bit160)
			case 3:
				setAudioBitrate(value: .bit192)
			default:
				return
		}
	}
	
	private func setAudioBitrate(value: AudioBitrate) {
		audioBitrateValue = value
	}
}

extension VideoCompressionCustomSettingsViewController {
	
	private func setVideoBitrateSlider(to value: Int) {
		self.videoBitrateValue = value
		self.videoBitrateSlider.index = UInt(value - 1) / 1000_000
	}
	
	private func setAudioBitrateSlider(to value: Int) {
		
		let rawValue = AudioBitrate.allCases.first(where: {$0.rawValue == value})
		let valuesArray: [AudioBitrate] = Array(AudioBitrate.allCases.reversed())
	
		if let savedValue = rawValue {
			self.audioBitrateValue = savedValue
			if let index = valuesArray.firstIndex(of: savedValue) {
				audioBitrateSlider.index = UInt(index)
			}
		}
	}
	
	private func setFpsSlider(to value: Float) {
		
		let rawValue = FPS.allCases.first(where: {$0.rawValue == value})
		let valuesArray: [FPS] = Array(FPS.allCases.reversed())
		
		if let savedValue = rawValue {
			self.videoFpsValue = savedValue
			if let index = valuesArray.firstIndex(of: savedValue) {
				fpsStepSlider.index = UInt(index)
			}
		}
	}
	
	private func setKeyIntervalSlider(value: Int) {
		videoKeyframeValue = value
		videoKeyFrameSlider.index = UInt(value - 1)
	}
	
	private func setResolutionSlider(value: CGSize) {
		
		let heightResolution = VideoResolution.allCases.first(where: {$0.resolutionSize.height == value.height})
		let widthResolution = VideoResolution.allCases.first(where: {$0.resolutionSize.width == value.width})
		let valuesArray: [VideoResolution] = Array(VideoResolution.allCases.reversed())
		
		if let heightSavedValue = heightResolution {
			videoResolutionValue = heightSavedValue
			if let index = valuesArray.firstIndex(of: heightSavedValue) {
				resolutionStepSlider.index = UInt(index)
			}
		} else if let widthSavedValue = widthResolution {
			videoResolutionValue = widthSavedValue
			if let index = valuesArray.firstIndex(of: widthSavedValue) {
				resolutionStepSlider.index = UInt(index)
			}
		}
	}
	
	private func getResolutionFrom(_ size: CGSize) -> VideoResolution {
		
		let heightResolution = VideoResolution.allCases.first(where: {$0.resolutionSize.height == size.height})
		let widthResolution = VideoResolution.allCases.first(where: {$0.resolutionSize.width == size.width})
		
		if let _ = heightResolution {
			return heightResolution!
		} else if let _ = widthResolution {
			return widthResolution!
		}
		return .res1080p
	}
	
	private func handleAudioTrackIsEnable() {
		
		if let asset = asset {
			asset.getPhassetURL { responseURL in
				if let url =  responseURL {
					let avasset = AVAsset(url: url)
					if let _ = avasset.tracks(withMediaType: .audio).first {
						self.isAudioAvailible = true
					} else {
						self.isAudioAvailible = false
					}
				}
			}
		}
	}
	
	private func handleRemoveAudioComponentButtom() {
		
		let image = removeAudioComponent ? I.personalisation.video.selected : I.personalisation.video.unselected
		
		removeAudioButton.addLeftImage(image: image, size: CGSize(width: 15, height: 15), spacing: 5)
	}
	
	private func handlRemoveTrackButtonAvailible() {
		U.UI {
			self.removeAudioButton.isEnabled = self.isAudioAvailible
			self.audioBitrateSlider.isEnabled = self.isAudioAvailible
			self.audioBitrateSlider.alpha = self.isAudioAvailible ? 1.0 : 0.5
		}
	}
	
	private func handleValuesDidChange() {
		
		let defaultConfigurationValues = VideoCompressionConfig()
		
		var isDefaultResolution: Bool = false
		
		if let size = defaultConfigurationValues.scaleResolution {
			let resolution = getResolutionFrom(size)
			isDefaultResolution = resolution == self.videoResolutionValue
		} else if defaultConfigurationValues.scaleResolution == nil {
			isDefaultResolution = true
		}

		if isDefaultResolution &&
			defaultConfigurationValues.videoBitrate == self.videoBitrateValue &&
			defaultConfigurationValues.audioBitrate == self.audioBitrateValue.rawValue &&
			defaultConfigurationValues.fps == self.videoFpsValue.rawValue &&
			defaultConfigurationValues.maximumVideoKeyframeInterval == self.videoKeyframeValue {
			
			setResetToDefaultButton(isEnable: false)
		} else {
			setResetToDefaultButton(isEnable: true)
		}
	}
	
	private func setResetToDefaultButton(isEnable: Bool) {
		self.resetToDafaultButton.isEnabled = isEnable
	}
}

extension VideoCompressionCustomSettingsViewController: Themeble {
	
	func setupUI() {
		
		let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 600 : 540
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerHeightConstraint.constant = containerHeight
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		topShevronView.setCorner(3)
		
		controllerTitleTextLabel.text = "select compression settings"
		controllerTitleTextLabel.font = .systemFont(ofSize: 16.8, weight: .heavy)
		
		bottomButtonView.title("submit".uppercased())
		
		bottomButtonView.actionButton.imageSize = CGSize(width: 24, height: 22)
		bottomButtonView.setImage(I.systemItems.defaultItems.compress)
		
		
		titleLabelsCollection.forEach {
			$0.font = .systemFont(ofSize: 12, weight: .semibold)
		}
		
		resolutionTitleTextLabel.text = "Resolution"
		fpsTitleTextLabel.text = "FPS"
		bitrateTitleTextLabel.text = "Video Bitrate"
		keyframeTitleTextLabel.text = "Interval Between Keyframes"
		audioBitrateTitleTextLabel.text = "Audio Bitrate"
		
		bitrateTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
		keyframeTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
		resolutionSizeTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
		
		bitrateTextLabel.text = "150"
		keyframeTextLabel.text = "10"
		
		bitrateShadowView.cornerRadius = 6
		keyframeShadowView.cornerRadius = 6
		
		resetToDafaultButton.setTitle("Reset to Default", for: .normal)
		resetToDafaultButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
		resetToDafaultButton.addLeftImage(image: I.personalisation.video.reset, size: CGSize(width: 15, height: 15), spacing: 5)
		resetButtonShadowView.cornerRadius = 8
		
		removeAudioButton.setTitle("Remove audio", for: .normal)
		removeAudioButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
		removeAudioShadowView.cornerRadius = 8
		handleRemoveAudioComponentButtom()
	}
	
	private func videoResolutionSliderSetupUI() {
		
		videoResolutionSliderContainerView.addSubview(resolutionStepSlider)
		resolutionStepSlider.translatesAutoresizingMaskIntoConstraints = false
		resolutionStepSlider.leadingAnchor.constraint(equalTo: videoResolutionSliderContainerView.leadingAnchor, constant: 30).isActive = true
		resolutionStepSlider.trailingAnchor.constraint(equalTo: videoResolutionSliderContainerView.trailingAnchor, constant: -30).isActive = true
		resolutionStepSlider.centerYAnchor.constraint(equalTo: videoResolutionSliderContainerView.centerYAnchor).isActive = true
		resolutionStepSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func pfsSliderSetupUI() {
		
		fpsSliderContainerView.addSubview(fpsStepSlider)
		fpsStepSlider.translatesAutoresizingMaskIntoConstraints = false
		fpsStepSlider.leadingAnchor.constraint(equalTo: fpsSliderContainerView.leadingAnchor, constant: 30).isActive = true
		fpsStepSlider.trailingAnchor.constraint(equalTo: fpsSliderContainerView.trailingAnchor, constant: -30).isActive = true
		fpsStepSlider.centerYAnchor.constraint(equalTo: fpsSliderContainerView.centerYAnchor).isActive = true
		fpsStepSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func videoBitrateSliderSetupUI() {
		
		videoBitrateSliderContainerView.addSubview(videoBitrateSlider)
		videoBitrateSlider.translatesAutoresizingMaskIntoConstraints = false
		videoBitrateSlider.leadingAnchor.constraint(equalTo: videoBitrateSliderContainerView.leadingAnchor, constant: 30).isActive = true
		videoBitrateSlider.trailingAnchor.constraint(equalTo: videoBitrateSliderContainerView.trailingAnchor, constant: -30).isActive = true
		videoBitrateSlider.centerYAnchor.constraint(equalTo: videoBitrateSliderContainerView.centerYAnchor, constant: -6).isActive = true
		videoBitrateSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func videoKeyFrameSliderSetupUI() {
		
		maximumVideoKeySliderContainerView.addSubview(videoKeyFrameSlider)
		videoKeyFrameSlider.translatesAutoresizingMaskIntoConstraints = false
		videoKeyFrameSlider.leadingAnchor.constraint(equalTo: maximumVideoKeySliderContainerView.leadingAnchor, constant: 30).isActive = true
		videoKeyFrameSlider.trailingAnchor.constraint(equalTo: maximumVideoKeySliderContainerView.trailingAnchor, constant: -30).isActive = true
		videoKeyFrameSlider.centerYAnchor.constraint(equalTo: maximumVideoKeySliderContainerView.centerYAnchor, constant: 0).isActive = true
		videoKeyFrameSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func audioBitrateSliderSetupUI() {
		
		audioBitrateSliderContainerView.addSubview(audioBitrateSlider)
		audioBitrateSlider.translatesAutoresizingMaskIntoConstraints = false
		audioBitrateSlider.leadingAnchor.constraint(equalTo: audioBitrateSliderContainerView.leadingAnchor, constant: 30).isActive = true
		audioBitrateSlider.trailingAnchor.constraint(equalTo: audioBitrateSliderContainerView.trailingAnchor, constant: -30).isActive = true
		audioBitrateSlider.centerYAnchor.constraint(equalTo: audioBitrateSliderContainerView.centerYAnchor).isActive = true
		audioBitrateSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func audioSampleRateSliderSetupUI() {
		
		audioSampleRateContainerView.addSubview(audioSampleRateSlider)
		audioSampleRateSlider.translatesAutoresizingMaskIntoConstraints = false
		audioSampleRateSlider.leadingAnchor.constraint(equalTo: audioSampleRateContainerView.leadingAnchor, constant: 30).isActive = true
		audioSampleRateSlider.trailingAnchor.constraint(equalTo: audioSampleRateContainerView.trailingAnchor, constant: -30).isActive = true
		audioSampleRateSlider.centerYAnchor.constraint(equalTo: audioSampleRateContainerView.centerYAnchor).isActive = true
		audioSampleRateSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}
	
	private func setupSliders() {
		
		slidersContainer = [resolutionStepSlider,
				   fpsStepSlider,
				   videoBitrateSlider,
				   videoKeyFrameSlider,
				   audioBitrateSlider,
				   audioSampleRateSlider]
		
		slidersContainer.forEach {
			$0.trackCircleRadius = 0
			$0.sliderCircleRadius = 6
			$0.enableHapticFeedback = true
			$0.trackHeight = 3
			$0.labelFont = .systemFont(ofSize: 10, weight: .medium)
			$0.labelOffset = CGFloat(3)
		}
		
			/// `resolution slider`
		
		let resolutionValues: [String] = VideoResolution.allCases.map({$0.resolutionName}).reversed()
		resolutionStepSlider.maxCount = UInt(resolutionValues.count)
		resolutionStepSlider.labels = resolutionValues
		
			/// `fps slider`
		let fpsValues: [String] = FPS.allCases.map({$0.name}).reversed()
		fpsStepSlider.maxCount = UInt(fpsValues.count)
		fpsStepSlider.labels = fpsValues
		
			/// `video bitrate`
		
		videoBitrateSlider.maxCount = 150
		videoBitrateSlider.addLeftLabel(with: "1Mbs",
										font: .systemFont(ofSize: 10, weight: .medium),
										color: theme.subTitleTextColor,
										xOffset: 0,
										yOffset: -7)
		videoBitrateSlider.addRightLabel(with: "150Mbs",
										 font: .systemFont(ofSize: 10, weight: .medium),
										 color: theme.subTitleTextColor,
										 xOffset: 0,
										 yOffset: -7)
		
			/// `key frame interval`
		
		var keyframes: [String] = [String](repeating: "", count: 10)
		keyframes[0] = "1"
		keyframes[9] = "10"
		videoKeyFrameSlider.maxCount = UInt(keyframes.count)
		videoKeyFrameSlider.labels = keyframes
			
			/// `audio bitrate`
		
		let bitrateValues: [String] = AudioBitrate.allCases.map({$0.name}).reversed()
		audioBitrateSlider.maxCount = UInt(bitrateValues.count)
		audioBitrateSlider.labels = bitrateValues
		
			/// `audio sample rate`
			/// `hide -> use only 44000`
	}

	private func stupGesturerecognizers() {
		
		let animator = TopBottomAnimation(style: .bottom)
		dissmissGestureRecognizer = animator.panGestureRecognizer
		dissmissGestureRecognizer.cancelsTouchesInView = false
		animator.panGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(dissmissGestureRecognizer)
	}
	
	private func setupDelegate() {
		
		bottomButtonView.delegate = self
	}
	
	func updateColors() {
		 
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		topShevronView.backgroundColor = theme.subTitleTextColor
		controllerTitleTextLabel.textColor = theme.titleTextColor
		bottomButtonView.buttonColor = theme.cellBackGroundColor
		bottomButtonView.buttonTintColor = theme.secondaryTintColor
		bottomButtonView.buttonTitleColor = theme.titleTextColor
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadow()
		bottomButtonView.updateColorsSettings()
		
		bitrateTextLabel.textColor = theme.titleTextColor
		keyframeTextLabel.textColor = theme.titleTextColor
		resolutionSizeTextLabel.textColor = theme.subTitleTextColor
		
		slidersContainer.forEach {
			$0.trackColor = theme.sliderUntrackBackgroundColor
			$0.tintColor = theme.videosTintColor
			$0.backgroundColor = .clear
			$0.sliderCircleColor = theme.sliderCircleBackroundColor
			$0.labelColor = theme.subTitleTextColor
		}
		
		titleLabelsCollection.forEach {
			$0.textColor = theme.titleTextColor
		}
		
		resetToDafaultButton.tintColor = theme.titleTextColor
		removeAudioButton.tintColor = theme.titleTextColor
	}
}

extension VideoCompressionCustomSettingsViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		
		if gestureRecognizer == dissmissGestureRecognizer {
			let point = gestureRecognizer.location(in: self.slidersStackView)
			if self.slidersStackView.bounds.contains(point) {
				return false
			}
		}
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		
		if gestureRecognizer == dissmissGestureRecognizer {
			let point = gestureRecognizer.location(in: self.slidersStackView)
			
			if self.slidersStackView.bounds.contains(point) {
				return true
			}
		}
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
