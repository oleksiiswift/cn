//
//  SliderView.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.04.2022.
//

import Foundation
import UIKit
import AVFoundation

public protocol SliderViewDelegate: AnyObject {
	func didChangePositionBar(_ playerTime: CMTime)
	func positionBarStoppedMoving(_ playerTime: CMTime)
}

/// A view to select a specific time range of a video. It consists of an asset preview with thumbnails inside a scroll view, two
/// handles on the side to select the beginning and the end of the range, and a position bar to synchronize the control with a
/// video preview, typically with an `AVPlayer`.
/// Load the video by setting the `asset` property. Access the `startTime` and `endTime` of the view to get the selected time
// range
public class SliderView: AVAssetTimeSelector {

	// MARK: - Properties

	// MARK: Color Customization

	/// The color of the main border of the view
	public var mainColor: UIColor = UIColor.orange {
		didSet {
			updateMainColor()
		}
	}

	/// The color of the handles on the side of the view
	public var handleColor: UIColor = UIColor.gray {
		didSet {
		   updateHandleColor()
		}
	}

	/// The color of the position indicator
	public var positionBarColor: UIColor = UIColor.white {
		didSet {
			positionBar.backgroundColor = positionBarColor
		}
	}
	
	public var positionBarBorderColor: UIColor = UIColor.white {
		didSet {
			leftPositionBarBorder.backgroundColor = positionBarBorderColor
			rightPositionBarBorder.backgroundColor = positionBarBorderColor
			topPositionBarBorder.backgroundColor = positionBarBorderColor
			bottomPositionBarBorder.backgroundColor = positionBarBorderColor
		}
	}

	/// The color used to mask unselected parts of the video
	public var maskColor: UIColor = UIColor.white {
		didSet {
			leftMaskView.backgroundColor = maskColor
			rightMaskView.backgroundColor = maskColor
		}
	}
	
	public var positionBarBorderWidth: CGFloat = 0 {
		didSet {
			setupPositionBarBorderWidth()
		}
	}
	
	public var positionBarWidth: CGFloat = 2 {
		didSet {
			setWidthOfPositionBar()
		}
	}
	
	public var mobWidth: CGFloat = 2 {
		didSet {
			handleMobViewWidth()
		}
	}

	// MARK: Interface

	public weak var delegate: SliderViewDelegate?

	// MARK: Subviews

	private let trimView = UIView()
	private let leftHandleView = HandlerView()
	private let rightHandleView = HandlerView()
	private let positionBar = UIView()
	private let leftHandleKnob = UIView()
	private let rightHandleKnob = UIView()
	private let leftMaskView = UIView()
	private let rightMaskView = UIView()
	
	private let leftPositionBarBorder = UIView()
	private let rightPositionBarBorder = UIView()
	private let topPositionBarBorder = UIView()
	private let bottomPositionBarBorder = UIView()

	// MARK: Constraints

	private var currentLeftConstraint: CGFloat = 0
	private var currentRightConstraint: CGFloat = 0
	private var leftConstraint: NSLayoutConstraint?
	private var rightConstraint: NSLayoutConstraint?
	private var positionConstraint: NSLayoutConstraint?

	private let handleWidth: CGFloat = 0

	/// The minimum duration allowed for the trimming. The handles won't pan further if the minimum duration is attained.
	public var minDuration: Double = 3

	// MARK: - View & constraints configurations

	override func setupSubviews() {
		super.setupSubviews()
		layer.cornerRadius = 2
		layer.masksToBounds = true
		backgroundColor = UIColor.clear
		layer.zPosition = 1
		setupSliderView()
		setupHandleView()
		setupMaskView()
		setupPositionBar()
		setupPositionBarBorder()
		setupPositionBarBorderWidth()
		setupGestures()
		updateMainColor()
		updateHandleColor()
	}

	override func constrainAssetPreview() {
		assetPreview.leftAnchor.constraint(equalTo: leftAnchor, constant: handleWidth).isActive = true
		assetPreview.rightAnchor.constraint(equalTo: rightAnchor, constant: -handleWidth).isActive = true
		assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
		assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}

	private func setupSliderView() {
		trimView.layer.borderWidth = 0.0
		trimView.layer.cornerRadius = 2.0
		trimView.translatesAutoresizingMaskIntoConstraints = false
		trimView.isUserInteractionEnabled = false
		addSubview(trimView)

		trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		leftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor)
		rightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor)
		leftConstraint?.isActive = true
		rightConstraint?.isActive = true
	}

	private func setupHandleView() {

		leftHandleView.isUserInteractionEnabled = true
		leftHandleView.layer.cornerRadius = 2.0
		leftHandleView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(leftHandleView)

		leftHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		leftHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
		leftHandleView.leftAnchor.constraint(equalTo: trimView.leftAnchor).isActive = true
		leftHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
		leftHandleView.addSubview(leftHandleKnob)

		leftHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
		leftHandleKnob.widthAnchor.constraint(equalToConstant: mobWidth).isActive = true
		leftHandleKnob.centerYAnchor.constraint(equalTo: leftHandleView.centerYAnchor).isActive = true
		leftHandleKnob.centerXAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true

		rightHandleView.isUserInteractionEnabled = true
		rightHandleView.layer.cornerRadius = 2.0
		rightHandleView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(rightHandleView)

		rightHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		rightHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
		rightHandleView.rightAnchor.constraint(equalTo: trimView.rightAnchor).isActive = true
		rightHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
		rightHandleView.addSubview(rightHandleKnob)

		rightHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
		rightHandleKnob.widthAnchor.constraint(equalToConstant: mobWidth).isActive = true
		rightHandleKnob.centerYAnchor.constraint(equalTo: rightHandleView.centerYAnchor).isActive = true
		rightHandleKnob.centerXAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
	}
	
	private func handleMobViewWidth() {
		if let widthConstraint = leftHandleKnob.constraints.first(where: {$0.firstAttribute == .width}) {
			widthConstraint.constant = mobWidth
		}
		
		if let widthConstraint = rightHandleKnob.constraints.first(where: {$0.firstAttribute == .width}) {
			widthConstraint.constant = mobWidth
		}
		
		if mobWidth == 0 {
			leftHandleView.gestureRecognizers?.removeAll()
			rightHandleView.gestureRecognizers?.removeAll()
		}
		
		leftHandleKnob.layoutIfNeeded()
		rightHandleKnob.layoutIfNeeded()
	}

	private func setupMaskView() {

		leftMaskView.isUserInteractionEnabled = false
		leftMaskView.backgroundColor = .white
		leftMaskView.alpha = 0.7
		leftMaskView.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(leftMaskView, belowSubview: leftHandleView)

		leftMaskView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true

		rightMaskView.isUserInteractionEnabled = false
		rightMaskView.backgroundColor = .white
		rightMaskView.alpha = 0.7
		rightMaskView.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(rightMaskView, belowSubview: rightHandleView)

		rightMaskView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
	}

	private func setupPositionBar() {

		positionBar.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)
		positionBar.backgroundColor = positionBarColor
		positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
		positionBar.layer.cornerRadius = 0
		positionBar.translatesAutoresizingMaskIntoConstraints = false
		positionBar.isUserInteractionEnabled = true
		addSubview(positionBar)

		positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		positionBar.widthAnchor.constraint(equalToConstant: positionBarWidth).isActive = true
		positionBar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		positionConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
		positionConstraint?.isActive = true
	}
	
	private func setupPositionBarBorder() {
		
		leftPositionBarBorder.backgroundColor = positionBarBorderColor
		leftPositionBarBorder.frame = CGRect(x: 0, y: 0, width: 2, height: positionBar.frame.height)
		leftPositionBarBorder.translatesAutoresizingMaskIntoConstraints = false
		positionBar.addSubview(leftPositionBarBorder)
		
		leftPositionBarBorder.leadingAnchor.constraint(equalTo: positionBar.leadingAnchor).isActive = true
		leftPositionBarBorder.topAnchor.constraint(equalTo: positionBar.topAnchor).isActive = true
		leftPositionBarBorder.bottomAnchor.constraint(equalTo: positionBar.bottomAnchor).isActive = true
		leftPositionBarBorder.widthAnchor.constraint(equalToConstant: positionBarBorderWidth).isActive = true
		
		rightPositionBarBorder.backgroundColor = positionBarBorderColor
		rightPositionBarBorder.frame = CGRect(x: positionBar.frame.width - 2, y: 0, width: 2, height: positionBar.frame.height)
		rightPositionBarBorder.translatesAutoresizingMaskIntoConstraints = false
		positionBar.addSubview(rightPositionBarBorder)
		
		rightPositionBarBorder.trailingAnchor.constraint(equalTo: positionBar.trailingAnchor).isActive = true
		rightPositionBarBorder.topAnchor.constraint(equalTo: positionBar.topAnchor).isActive = true
		rightPositionBarBorder.bottomAnchor.constraint(equalTo: positionBar.bottomAnchor).isActive = true
		rightPositionBarBorder.widthAnchor.constraint(equalToConstant: positionBarBorderWidth).isActive = true
		
		topPositionBarBorder.backgroundColor = positionBarBorderColor
		topPositionBarBorder.frame = CGRect(x: 0, y: 0, width: positionBar.frame.width, height: 2)
		topPositionBarBorder.translatesAutoresizingMaskIntoConstraints = false
		positionBar.addSubview(topPositionBarBorder)
		
		topPositionBarBorder.leadingAnchor.constraint(equalTo: positionBar.leadingAnchor).isActive = true
		topPositionBarBorder.trailingAnchor.constraint(equalTo: positionBar.trailingAnchor).isActive = true
		topPositionBarBorder.topAnchor.constraint(equalTo: positionBar.topAnchor).isActive = true
		topPositionBarBorder.heightAnchor.constraint(equalToConstant: positionBarBorderWidth).isActive = true
		
		
		bottomPositionBarBorder.backgroundColor = positionBarBorderColor
		bottomPositionBarBorder.frame = CGRect(x: positionBar.frame.height - 2, y: 0, width: positionBar.frame.width, height: 2)
		bottomPositionBarBorder.translatesAutoresizingMaskIntoConstraints = false
		positionBar.addSubview(bottomPositionBarBorder)
		
		bottomPositionBarBorder.leadingAnchor.constraint(equalTo: positionBar.leadingAnchor).isActive = true
		bottomPositionBarBorder.trailingAnchor.constraint(equalTo: positionBar.trailingAnchor).isActive = true
		bottomPositionBarBorder.bottomAnchor.constraint(equalTo: positionBar.bottomAnchor).isActive = true
		bottomPositionBarBorder.heightAnchor.constraint(equalToConstant: positionBarBorderWidth).isActive = true
		
		leftPositionBarBorder.layoutIfNeeded()
		rightPositionBarBorder.layoutIfNeeded()
		topPositionBarBorder.layoutIfNeeded()
		bottomPositionBarBorder.layoutIfNeeded()
	}
	
	private func setupPositionBarBorderWidth() {

		if let widthConstraint = leftPositionBarBorder.constraints.first(where: {$0.firstAttribute == .width}) {
			widthConstraint.isActive = false
			widthConstraint.constant = positionBarBorderWidth
			widthConstraint.isActive = true
		}
		if let widthConstraint = rightPositionBarBorder.constraints.first(where: {$0.firstAttribute == .width}) {
			widthConstraint.constant = positionBarBorderWidth
		}
		
		if let heightConstraint = topPositionBarBorder.constraints.first(where: {$0.firstAttribute == .height}) {
			heightConstraint.constant = positionBarBorderWidth
		}
		
		if let heightConstraint = bottomPositionBarBorder.constraints.first(where: {$0.firstAttribute == .height}) {
			heightConstraint.constant = positionBarBorderWidth
		}

		leftPositionBarBorder.layoutIfNeeded()
		rightPositionBarBorder.layoutIfNeeded()
		topPositionBarBorder.layoutIfNeeded()
		bottomPositionBarBorder.layoutIfNeeded()
	}
	
	private func setWidthOfPositionBar() {
		
		if let widthConstraint = positionBar.constraints.first(where: {$0.firstAttribute == .width}) {
			widthConstraint.constant = positionBarWidth
			positionBar.layoutIfNeeded()
		}
	}
	
	private func setupGestures() {

		let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SliderView.handlePanGesture(_:)))
		leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
		let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SliderView.handlePanGesture(_:)))
		rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
		let sliderPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SliderView.handlePanGesture(_:)))
		self.addGestureRecognizer(sliderPanGestureRecognizer)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SliderView.handleTapGesture(_:)))
		self.addGestureRecognizer(tapGestureRecognizer)
	}

	private func updateMainColor() {
		trimView.layer.borderColor = mainColor.cgColor
		leftHandleView.backgroundColor = mainColor
		rightHandleView.backgroundColor = mainColor
	}

	private func updateHandleColor() {
		leftHandleKnob.backgroundColor = handleColor
		rightHandleKnob.backgroundColor = handleColor
	}

	// MARK: - Trim Gestures

	@objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
		
		guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
		
		let isLeftGesture = view == leftHandleView
		let isRightGesture = view == rightHandleView
			
		switch gestureRecognizer.state {

		case .began:
			if isLeftGesture {
				currentLeftConstraint = leftConstraint!.constant
			} else if isRightGesture {
				currentRightConstraint = rightConstraint!.constant
			} else {
				
			}
			updateSelectedTime(stoppedMoving: false)
		case .changed:
			let translation = gestureRecognizer.translation(in: superView)
			let location = gestureRecognizer.location(in: superView)
				
			if isLeftGesture {
				updateLeftConstraint(with: translation)
			} else if isRightGesture{
				updateRightConstraint(with: translation)
			} else {
				updatePositionBart(with: location)
			}
				
			layoutIfNeeded()
			if let startTime = startTime, isLeftGesture {
				if !leftHandleView.gestureRecognizers!.isEmpty {
					seek(to: startTime)
				}
			} else if let endTime = endTime {
				if !rightHandleView.gestureRecognizers!.isEmpty {
					seek(to: endTime)
				}
			}
			updateSelectedTime(stoppedMoving: false)

		case .cancelled, .ended, .failed:
			updateSelectedTime(stoppedMoving: true)
		default: break
		}
	}
	
	@objc private func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
		
		guard let _ = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
				
		let location = gestureRecognizer.location(in: superView)
		if let updatedTime = getTime(from: location.x) {
			updateSelectedTime(stoppedMoving: false)
			seek(to: updatedTime)
			updateSelectedTime(stoppedMoving: true)
		}
	}
	
	private func updatePositionBart(with location: CGPoint) {
		if let updatedTime = getTime(from: location.x) {
			seek(to: updatedTime)
		}
	}

	private func updateLeftConstraint(with translation: CGPoint) {
		let maxConstraint = max(rightHandleView.frame.origin.x - handleWidth - minimumDistanceBetweenHandle, 0)
		let newConstraint = min(max(0, currentLeftConstraint + translation.x), maxConstraint)
		leftConstraint?.constant = newConstraint
	}

	private func updateRightConstraint(with translation: CGPoint) {
		let maxConstraint = min(2 * handleWidth - frame.width + leftHandleView.frame.origin.x + minimumDistanceBetweenHandle, 0)
		let newConstraint = max(min(0, currentRightConstraint + translation.x), maxConstraint)
		rightConstraint?.constant = newConstraint
	}

	// MARK: - Asset loading

	override func assetDidChange(newAsset: AVAsset?) {
		super.assetDidChange(newAsset: newAsset)
		resetHandleViewPosition()
	}

	private func resetHandleViewPosition() {
		leftConstraint?.constant = 0
		rightConstraint?.constant = 0
		layoutIfNeeded()
	}

	// MARK: - Time Equivalence

	/// Move the position bar to the given time.
	public func seek(to time: CMTime) {
		if let newPosition = getPosition(from: time) {

			let offsetPosition = newPosition - assetPreview.contentOffset.x - leftHandleView.frame.origin.x
			let maxPosition = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handleWidth)
							  - positionBar.frame.width
			let normalizedPosition = min(max(0, offsetPosition), maxPosition)
			positionConstraint?.constant = normalizedPosition
			layoutIfNeeded()
		}
	}

	/// The selected start time for the current asset.
	public var startTime: CMTime? {
		let startPosition = leftHandleView.frame.origin.x + assetPreview.contentOffset.x
		return getTime(from: startPosition)
	}

	/// The selected end time for the current asset.
	public var endTime: CMTime? {
		let endPosition = rightHandleView.frame.origin.x + assetPreview.contentOffset.x - handleWidth
		return getTime(from: endPosition)
	}

	private func updateSelectedTime(stoppedMoving: Bool) {
		guard let playerTime = positionBarTime else {
			return
		}
		if stoppedMoving {
			delegate?.positionBarStoppedMoving(playerTime)
		} else {
			delegate?.didChangePositionBar(playerTime)
		}
	}
	
	private var positionBarTime: CMTime? {
		let barPosition = positionBar.frame.origin.x + assetPreview.contentOffset.x - handleWidth
		return getTime(from: barPosition)
	}

	private var minimumDistanceBetweenHandle: CGFloat {
		guard let asset = asset else { return 0 }
		return CGFloat(minDuration) * assetPreview.contentView.frame.width / CGFloat(asset.duration.seconds)
	}

	// MARK: - Scroll View Delegate

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		updateSelectedTime(stoppedMoving: true)
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			updateSelectedTime(stoppedMoving: true)
		}
	}
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateSelectedTime(stoppedMoving: false)
	}
}
