//
//  VideoSpaceSelectorViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.02.2022.
//

import UIKit

enum LargeVideoSize {
	case superLow
	case low
	case medium
	case midleHight
	case hight
	case superHight
	
	var rawValue: Int {
		switch self {
			case .superLow:
				return 33000000
			case .low:
				return 55000000
			case .medium:
				return 75000000
			case .midleHight:
				return 150000000
			case .hight:
				return 200000000
			case .superHight:
				return 300000000
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
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
		setupUI()
		stepSliderSetup()
		delegateSetup()
		updateColors()
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
		
	}
}

extension VideoSpaceSelectorViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		self.closeDatePicker()
	}
	
	private func closeDatePicker() {
		self.dismiss(animated: true) {
			debugPrint("set value")
		}
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
		
		let navigationTitle = "Select lower size (need text)"
		navigationBar.setUpNavigation(title: navigationTitle, leftImage: nil, rightImage: I.systemItems.navigationBarItems.dissmiss)
	}
	
	private func setupUI() {
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 358 : 338
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerViewHeightConstraint.constant = containerHeight
		
		bottomButtonView.title("SUBMIT".localized())
	}
	
	private func stepSliderSetup() {
		
		sizeControll.maxCount = 5
		sizeControll.enableHapticFeedback = true
		
		sizeControll.setTrackCircleImage(I.systemItems.helpersItems.filledSegmentDotSlider, for: .selected)
		sizeControll.setTrackCircleImage(I.systemItems.helpersItems.segmentDotSlider, for: .normal)
		
		sizeControll.trackCircleRadius = 12
		sizeControll.trackHeight = 4
		
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
		
		sizeControll.trackColor = .red
		sizeControll.tintColor = .blue
		sizeControll.backgroundColor = .clear
	}
}


