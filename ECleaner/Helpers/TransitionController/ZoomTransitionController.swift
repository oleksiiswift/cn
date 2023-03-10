//
//  ZoomTransitionController.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.03.2022.
//

import Foundation

import UIKit

public typealias ReferenceImageView = () -> UIImageView
public typealias ReferenceImageViewFrame = () -> CGRect

struct ZoomAnimatorRreferences {
	var referenceImageView: ReferenceImageView
	var referenceImageViewFrameInTransitioningView: ReferenceImageViewFrame
}

final class ZoomTransitionController: NSObject {
	
	let animator: ZoomAnimator
	let interactionController: ZoomDismissalInteractionController
	var isInteractive: Bool = false

	var to: ZoomAnimatorRreferences?
	var from: ZoomAnimatorRreferences?

	override init() {
		animator = ZoomAnimator()
		interactionController = ZoomDismissalInteractionController()
		super.init()
	}
	
	func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
		self.interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
	}
}

extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.animator.isPresenting = true
		self.animator.from = from
		self.animator.to = to
		return self.animator
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.animator.isPresenting = false
		let tmp = self.from
		self.animator.from = self.to
		self.animator.to = tmp
		return self.animator
	}

	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if !self.isInteractive { return nil }
		
		self.interactionController.animator = animator
		return self.interactionController
	}
}

extension ZoomTransitionController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		
		if operation == .push {
			self.animator.isPresenting = true
			self.animator.from = from
			self.animator.to = to
		} else {
			self.animator.isPresenting = false
			let tmp = self.from
			self.animator.from = self.to
			self.animator.to = tmp
		}
		return self.animator
	}
	
	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		
		if !self.isInteractive { return nil }
		
		self.interactionController.animator = animator
		return self.interactionController
	}
}
