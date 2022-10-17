//
//  TotalSpacePageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.10.2022.
//

import UIKit

enum SpaceScaningState {
	case awake
	case scaning
	case complete
}

class TotalSpacePageViewController: UIViewController {

	@IBOutlet weak var circleProgressView: CircleProgressView!
	@IBOutlet weak var photoInfoSpaceView: InfoSpaceView!
	@IBOutlet weak var videoInfoSpaceView: InfoSpaceView!
	
	init() {
		super.init(nibName: Constants.identifiers.xibs.totalSpacePage, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
				
		updateColors()
		setupCircleProgressView()
		setupProgressSize()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.configureSpaceInfo(of: .userPhoto, state: .awake)
		self.configureSpaceInfo(of: .userVideo, state: .awake)
	}
}

extension TotalSpacePageViewController {
	
	public func setProgress(of type: MediaContentType, progress: CGFloat) {
		
		let stringFormat = String(format: "%.f %%", progress)
		
//		switch type {
//			case .userPhoto:
//				self.photoInfoSpaceView.handleProgress(progress)
//			case .userVideo:
//				self.videoInfoSpaceView.handleProgress(progress)
//			default:
//				return
//		}
	}
	
	private func configureSpaceInfo(of type: MediaContentType, state: SpaceScaningState) {
		
		switch type {
			case .userPhoto:
				self.photoInfoSpaceView.handleState(state)
			case .userVideo:
				self.videoInfoSpaceView.handleState(state)
				
			default:
				photoInfoSpaceView.isHidden = true
				videoInfoSpaceView.isHidden = true
		}
	}
}


extension TotalSpacePageViewController: UpdateColorsDelegate {
	

	
	private func setupCircleProgressView() {
		
		let calculatePercentage: Double = Double(Device.usedDiskSpaceInBytes) / Double(Device.totalDiskSpaceInBytes)
//		circleProgressView.setProgress(progress: CGFloat(calculatePercentage), animated: true)
		circleProgressView.setProgress(progress: 1, animated: true)
		circleProgressView.progressShapeColor = theme.tintColor
		circleProgressView.backgroundShapeColor = .clear
		circleProgressView.titleColor = theme.subTitleTextColor
		circleProgressView.percentColor = theme.titleTextColor
		
		circleProgressView.titleLabelTextAligement = Screen.size == .medium || Screen.size == .small ? .center : .right
		circleProgressView.orientation = .bottom
		circleProgressView.titleLabelsPercentPosition = .centeredRightAlign
		circleProgressView.backgroundShadowColor = theme == .light ? theme.bottomShadowColor : .clear
		circleProgressView.lineCap = .butt
		circleProgressView.spaceDegree = 60.0
		circleProgressView.progressShapeStart = 0.0
		circleProgressView.progressShapeEnd = 1.0
		
		let startPoint = CGPoint(x: 0.5, y: 0.5)
		let endPoint = CGPoint(x: 0.5, y: 1.0)
		circleProgressView.gradientSetup(startPoint: startPoint, endPoint: endPoint, gradientType: .conic)
		
		circleProgressView.clockwise = true
		circleProgressView.startColor = theme.primaryButtonBackgroundColor
		circleProgressView.endColor = theme.cellBackGroundColor
		circleProgressView.title = "\(Device.usedDiskSpaceInGB) \n \(Localization.Main.Subtitles.of) \(Device.totalDiskSpaceInGB)"
		circleProgressView.percentLabelFormat = "%.f%%"
	}
	
	private func setupProgressSize() {
		
		switch Screen.size {
				
			case .small:
				circleProgressView.lineWidth = 28
			case .medium:
				circleProgressView.lineWidth = 28
			case .plus:
				circleProgressView.lineWidth = 28
			case .large:
				circleProgressView.lineWidth = 28
			case .modern:
				circleProgressView.lineWidth = 28
			case .max:
				circleProgressView.lineWidth = 28
			case .madMax:
				circleProgressView.lineWidth = 28
		}
	}
	
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
	}
}
