//
//  VideoSpaceSelectorViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.02.2022.
//

import UIKit

enum LargeVideoSize: CaseIterable {
	case superLow
	case low
	case medium
	case midleHight
	case hight
	case superHight
	
	var rawValue: Int64 {
		switch self {
			case .superLow:
				return 330000000
			case .low:
				return 550000000
			case .medium:
				return 750000000
			case .midleHight:
				return 1500000000
			case .hight:
				return 2000000000
			case .superHight:
				return 3000000000
		}
	}
	
	var titleForValue: String {
		switch self {
			case .superLow:
				return "300 MB"
			case .low:
				return "550 MB"
			case .medium:
				return "750 MB"
			case .midleHight:
				return "1.5 GB"
			case .hight:
				return "2 GB"
			case .superHight:
				return "3 GB"
		}
	}
}

class VideoSpaceSelectorViewController: UIViewController {
	
	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var navigationBar: StartingNavigationBar!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var sliderContainerView: UIView!
	
	lazy var sizeControll = StepSlider()
	private var largeVideoSize: LargeVideoSize?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
		setupUI()
		stepSliderSetup()
		setSliderIndex()
		delegateSetup()
		updateColors()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
			
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
	}
}

extension VideoSpaceSelectorViewController {
	
	@objc func changeSliderValue() {
		switch sizeControll.index {
			case 0:
				setSliderValue(.superLow)
			case 1:
				setSliderValue(.low)
			case 2:
				setSliderValue(.medium)
			case 3:
				setSliderValue(.midleHight)
			case 4:
				setSliderValue(.hight)
			default:
				setSliderValue(.superHight)
		}
	}
	
	private func setSliderValue(_ size: LargeVideoSize) {
		self.largeVideoSize = size
	}
	
	private func setSliderIndex() {
		
		let size = SettingsManager.largeVideoLowerSize
		let index = self.getSliderIndex(rawValue: size)
		self.sizeControll.index = index
		changeSliderValue()
	}
	
	private func getSliderIndex(rawValue: Int64) -> UInt {
		switch rawValue {
			case LargeVideoSize.superLow.rawValue:
				return 0
			case LargeVideoSize.low.rawValue:
				return 1
			case LargeVideoSize.medium.rawValue:
				return 2
			case LargeVideoSize.midleHight.rawValue:
				return 3
			case LargeVideoSize.hight.rawValue:
				return 4
			case LargeVideoSize.superHight.rawValue:
				return 5
			default:
				return 2
		}
	}
}

extension VideoSpaceSelectorViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		if let size = self.largeVideoSize {
			SettingsManager.largeVideoLowerSize = size.rawValue
		}
		self.closeSizePicker()
	}
	
	private func closeSizePicker() {
		self.dismiss(animated: true) {}
	}
}

extension VideoSpaceSelectorViewController: StartingNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {}
	
	func didTapRightBarButton(_sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension VideoSpaceSelectorViewController {
	
	private func setupNavigation() {
		
		let navigationTitle = "Select large video size"
		navigationBar.setUpNavigation(title: navigationTitle, leftImage: nil, rightImage: I.systemItems.navigationBarItems.dissmiss)
	}
	
	private func setupUI() {
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 358 : 338
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerViewHeightConstraint.constant = containerHeight
		
		bottomButtonView.title("SUBMIT")
	}
	
	private func stepSliderSetup() {
		
		let sizeValues: [String] = LargeVideoSize.allCases.map({$0.titleForValue})
		
		sizeControll.maxCount = 6
		sizeControll.enableHapticFeedback = true
		
		sizeControll.setTrackCircleImage(I.systemItems.helpersItems.segmentDotSlider, for: .selected)
		sizeControll.setTrackCircleImage(I.systemItems.helpersItems.segmentDotSlider, for: .normal)
		sizeControll.sliderCircleRadius = 10
		sizeControll.trackCircleRadius = 12
		
		sizeControll.trackHeight = 4
		sizeControll.labelColor = theme.titleTextColor
		sizeControll.labelFont = .systemFont(ofSize: 12, weight: .medium)

		sizeControll.labels = sizeValues
		sizeControll.labelOffset = CGFloat(5)
	
		sliderContainerView.addSubview(sizeControll)
		sizeControll.translatesAutoresizingMaskIntoConstraints = false
		
		sizeControll.centerYAnchor.constraint(equalTo: sliderContainerView.centerYAnchor, constant: 0).isActive = true
		sizeControll.centerXAnchor.constraint(equalTo: sliderContainerView.centerXAnchor).isActive = true
		sizeControll.heightAnchor.constraint(equalToConstant: 25).isActive = true
		sizeControll.leadingAnchor.constraint(equalTo: sliderContainerView.leadingAnchor, constant: 20).isActive = true
		sizeControll.trailingAnchor.constraint(equalTo: sliderContainerView.trailingAnchor, constant: -20).isActive = true
		
		sizeControll.addTarget(self, action: #selector(changeSliderValue), for: .valueChanged)
	}
	
	private func delegateSetup() {
		
		navigationBar.delegate = self
		bottomButtonView.delegate = self
	}
}

extension VideoSpaceSelectorViewController: Themeble {
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		bottomButtonView.backgroundColor = .clear
		bottomButtonView.buttonTitleColor = theme.activeLinkTitleTextColor
		bottomButtonView.buttonColor = theme.activeButtonBackgroundColor
		bottomButtonView.buttonTintColor = theme.activeLinkTitleTextColor
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadow()
		bottomButtonView.updateColorsSettings()
		
		sizeControll.trackColor = theme.sliderUntrackBackgroundColor
		sizeControll.tintColor = theme.sliderUntrackBackgroundColor
		sizeControll.backgroundColor = .clear
		sizeControll.sliderCircleColor = theme.sliderCircleBackroundColor
	}
}


