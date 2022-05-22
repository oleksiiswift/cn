//
//  ProgressAlertController.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.11.2021.
//

import Foundation
import UIKit

protocol ProgressAlertControllerDelegate: AnyObject {
    func didTapCancelOperation()
    func didAutoCloseController()
}

protocol AnimatedProgressDelegate: AnyObject {
	func didProgressSetCanceled()
}

enum ProgressAlertType {
	case mergeContacts
	case deleteContacts
	case deleteVideos
	case deletePhotos
	case compressing
	case updatingContacts
	case selectingContacts
	case selectingPhotos
	case selectingVideos
	case prepareDeepClean
	
	var progressTitle: String {
		switch self {
			case .mergeContacts:
				return "merged contacts"
			case .deleteContacts:
				return "delete contacts"
			case .deleteVideos:
				return "delete contacts"
			case .deletePhotos:
				return "delete photos"
			case .compressing:
				return "compressing"
			case .updatingContacts:
				return "updating contacts"
			case .selectingContacts:
				return "select contacts, wait"
			case .selectingPhotos:
				return "select photo, wait"
			case .selectingVideos:
				return "select videio, wait"
			case .prepareDeepClean:
				return "prepare searching"
		}
	}
	
	var withCancel: Bool {
		switch self {
			case .mergeContacts:
				return true
			case .deleteContacts:
				return true
			case .deleteVideos:
				return false
			case .deletePhotos:
				return false
			case .compressing:
				return true
			case .updatingContacts:
				return false
			case .selectingContacts, .selectingVideos, .selectingPhotos:
				return false
			case .prepareDeepClean:
				return false
		}
	}
	
	var accentColor: UIColor {
		switch self {
			case .mergeContacts, .deleteContacts, .updatingContacts, .selectingPhotos:
				return self.contentType.screenAcentTintColor
			case .deleteVideos, .deletePhotos, .compressing, .selectingVideos:
				return self.contentType.screenAcentTintColor
			case .selectingContacts:
				return self.contentType.screenAcentTintColor
			case .prepareDeepClean:
				return self.contentType.screenAcentTintColor
		}
	}
	
	private var contentType: MediaContentType {
		switch self {
			case .mergeContacts:
				return .userContacts
			case .deleteContacts:
				return .userContacts
			case .deleteVideos:
				return .userVideo
			case .deletePhotos:
				return .userPhoto
			case .compressing:
				return .userVideo
			case .updatingContacts:
				return .userContacts
			case .selectingContacts:
				return .userContacts
			case .selectingVideos:
				return .userVideo
			case .selectingPhotos:
				return .userPhoto
			case .prepareDeepClean:
				return .userPhoto
		}
	}
}

class ProgressAlertController: Themeble {

    static var shared = ProgressAlertController()
    
    var alertController = UIAlertController()
    let progressBar = ProgressAlertBar()
	let animatedProgressBar = AnimatedProgressBar()
    
    var delegate: ProgressAlertControllerDelegate?

    var contentProgressType: MediaContentType = .none
	
	public var controllerPresented: Bool = false
	
    private var theme = ThemeManager.theme
    
    var progressBarTintColor: UIColor {
        switch contentProgressType {
            case .userPhoto:
                return theme.photoTintColor
            case .userVideo:
                return theme.videosTintColor
            case .userContacts:
                return theme.contactsTintColor
            case .none:
				return theme.photoTintColor
        }
    }
    
    func updateColors() {
        
        alertController.view.tintColor = theme.titleTextColor
		self.progressBar.borderColor = theme.separatorMainColor//theme.alertProgressBorderColor
		self.progressBar.mainBackgroundColor = theme.cellBackGroundColor//theme.alertProgressBackgroundColor
        self.progressBar.progressColor = progressBarTintColor
        self.progressBar.updateColors()
    }
    
    private func setProgress(controllerType: MediaContentType, title: String) {
		
		guard !controllerPresented else { return}
		
        contentProgressType = .userContacts
        alertController = UIAlertController(title: title, message: " ", preferredStyle: .alert)
        
		let cancelAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.cancel.title, style: .cancel) { _ in
			self.controllerPresented = false
            self.delegate?.didTapCancelOperation()
        }
    
        alertController.addAction(cancelAction)
        
        let margin: CGFloat = 16.0
        let topMargin: CGFloat = 66.0
        let rect = CGRect(x: margin, y: topMargin, width: self.alertController.view.frame.width -  margin * 2.0, height: 10.0)
        self.progressBar.frame = rect
        self.updateColors()
        self.alertController.view.addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.leadingAnchor.constraint(equalTo: self.alertController.view.leadingAnchor, constant: margin).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.alertController.view.trailingAnchor, constant: -margin).isActive = true
        progressBar.topAnchor.constraint(equalTo: self.alertController.view.topAnchor, constant: topMargin).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
    
        if let topController = topController() {
			topController.present(alertController, animated: true) {
				self.controllerPresented = true
			}
        }
    }
	
	private func presentAnimatedProgress(title: String, progressDelegate: AnimatedProgressDelegate?, from viewController: UIViewController, barColor: UIColor, animatedColor: UIColor, withCancel: Bool = true) {
		
		alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
		animatedProgressBar.progressMainColor = barColor
		animatedProgressBar.progressAnimatedColor = animatedColor
		
		let cancelAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.cancel.title, style: .cancel) { _ in
			progressDelegate?.didProgressSetCanceled()
			self.removeAnimatedProgress()
		}
		
		self.alertController.view.addSubview(self.animatedProgressBar)
		animatedProgressBar.translatesAutoresizingMaskIntoConstraints = false
		let margin: CGFloat = 16
		let rect = CGRect(x: margin, y: 56, width: self.alertController.view.frame.width - margin * 2.0, height: 2.0)
		self.animatedProgressBar.frame = rect
		
		self.animatedProgressBar.leadingAnchor.constraint(equalTo: self.alertController.view.leadingAnchor, constant: margin).isActive = true
		self.animatedProgressBar.trailingAnchor.constraint(equalTo: self.alertController.view.trailingAnchor, constant: -margin).isActive = true
		self.animatedProgressBar.topAnchor.constraint(equalTo: self.alertController.view.topAnchor, constant: 56).isActive = true
		self.animatedProgressBar.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
	
		U.UI {
			self.animatedProgressBar.performAnimation()
			withCancel ? self.alertController.addAction(cancelAction) : ()
			viewController.present(self.alertController, animated: true) {
				self.animatedProgressBar.startAnimation()
			}
		}
	}
    
	public func setProgress(_ progress: CGFloat, totalFilesProcessong: String) {
        alertController.message = totalFilesProcessong
        progressBar.progress = CGFloat(progress)
        if progress == 1 {
            self.closeAlertController()
        }
    }
	
	public func updateChangedProgress(_ progress: CGFloat, processingTitle: String) {
		alertController.message = processingTitle
		progressBar.progress = CGFloat(progress)
	}
    
    private func closeAlertController() {
        alertController.dismiss(animated: true) {
			self.controllerPresented = false
            self.delegate?.didAutoCloseController()
        }
    }
	
	public func closeForceController() {
		self.controllerPresented = false
		alertController.dismiss(animated: true, completion: nil)
	}
	
	public func closeProgressAnimatedController() {
		U.UI {
			self.alertController.dismiss(animated: true) {
				self.controllerPresented = false
				self.removeAnimatedProgress()
			}
		}
	}
	
	private func removeAnimatedProgress() {
		
		animatedProgressBar.stopAnimation()
		animatedProgressBar.removeFromSuperview()
		animatedProgressBar.layer.removeAllAnimations()
	}
}

extension ProgressAlertController {
    
    public func showDeleteContactsProgressAlert() {
        setProgress(controllerType: .userContacts, title: "delete contacts")
    }
    
    public func showMergeContactsProgressAlert() {
        setProgress(controllerType: .userContacts, title: "merged contacts")
    }
	
	public func showDeepCleanProgressAlert() {
		setProgress(controllerType: .none, title: "deep clean processing")
	}
	
	public func showContactsProgressAlert(of type: ProgressAlertType) {
		setProgress(controllerType: .userContacts, title: type.progressTitle)
	}
	
	public func showCompressingProgressAlertController(from viewController: UIViewController, delegate: AnimatedProgressDelegate?)  {
		let progress: ProgressAlertType = .compressing
		presentAnimatedProgress(title: progress.progressTitle, progressDelegate: delegate, from: viewController, barColor: UIColor().colorFromHexString("3C82C8"), animatedColor: theme.videosTintColor )
	}
			
	public func showSimpleProgressAlerControllerBar(of type: ProgressAlertType, from viewController: UIViewController, delegate: AnimatedProgressDelegate? = nil) {
		presentAnimatedProgress(title: type.progressTitle, progressDelegate: delegate, from: viewController, barColor: .white, animatedColor: type.accentColor, withCancel: type.withCancel)
	}
}


