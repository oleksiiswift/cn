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
		self.progressBar.borderColor = progressBarTintColor//theme.bordersColor//theme.separatorMainColor//theme.alertProgressBorderColor
		self.progressBar.mainBackgroundColor = theme.cellBackGroundColor//theme.alertProgressBackgroundColor
        self.progressBar.progressColor = progressBarTintColor
        self.progressBar.updateColors()
    }
    
    private func setProgress(controllerType: MediaContentType, title: String) {
		
		guard !controllerPresented else { return}
		
        contentProgressType = controllerType
        alertController = UIAlertController(title: title, message: " ", preferredStyle: .alert)
	
		let cancelAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .cancel), style: .cancel) { _ in
			self.controllerPresented = false
            self.delegate?.didTapCancelOperation()
        }
		
        alertController.addAction(cancelAction)
        
        let margin: CGFloat = 16.0
        let bottomMargin: CGFloat = 48.0
        let rect = CGRect(x: margin, y: bottomMargin, width: self.alertController.view.frame.width -  margin * 2.0, height: 10.0)
        self.progressBar.frame = rect
        self.updateColors()
        self.alertController.view.addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.leadingAnchor.constraint(equalTo: self.alertController.view.leadingAnchor, constant: margin).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.alertController.view.trailingAnchor, constant: -margin).isActive = true
		progressBar.bottomAnchor.constraint(equalTo: self.alertController.view.bottomAnchor, constant: -bottomMargin).isActive = true
		progressBar.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
    
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
		
		let cancelAction = UIAlertAction(title: LocalizationService.Buttons.getButtonTitle(of: .cancel), style: .cancel) { _ in
			progressDelegate?.didProgressSetCanceled()
			self.removeAnimatedProgress()
		}
		
		self.alertController.view.addSubview(self.animatedProgressBar)
		animatedProgressBar.translatesAutoresizingMaskIntoConstraints = false
		let margin: CGFloat = 16
		let rect = CGRect(x: margin, y: 46, width: self.alertController.view.frame.width - margin * 2.0, height: 10.0)
		self.animatedProgressBar.frame = rect
		
		self.animatedProgressBar.setBorder(radius: 4, color: theme.bordersColor, width: 2)
		
		self.animatedProgressBar.leadingAnchor.constraint(equalTo: self.alertController.view.leadingAnchor, constant: margin).isActive = true
		self.animatedProgressBar.trailingAnchor.constraint(equalTo: self.alertController.view.trailingAnchor, constant: -margin).isActive = true
		self.animatedProgressBar.topAnchor.constraint(equalTo: self.alertController.view.topAnchor, constant: 46).isActive = true
		self.animatedProgressBar.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
	
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
	
	public func updateProgressAndMessages(_ progress: CGFloat, title: NSMutableAttributedString, message: NSMutableAttributedString) {
		alertController.setValue(title, forKey: "attributedTitle")
		alertController.setValue(message, forKey: "attributedMessage")
		progressBar.progress = progress
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
		setProgress(controllerType: .userContacts, title: Localization.AlertController.AlertTitle.deletingContact)
    }
    
    public func showMergeContactsProgressAlert() {
		setProgress(controllerType: .userContacts, title: Localization.AlertController.AlertTitle.mergingContacts)
    }
	
	public func showDeepCleanProgressAlert() {
		setProgress(controllerType: .none, title: Localization.AlertController.AlertTitle.deepCleanProcessing)
	}
	
	public func showContactsProgressAlert(of type: ProgressAlertType) {
		setProgress(controllerType: .userContacts, title: type.progressTitle)
	}
	
	public func showCompressingProgressAlertController(from viewController: UIViewController, delegate: ProgressAlertControllerDelegate?)  {
		let progress: ProgressAlertType = .compressing
		self.delegate = delegate
		Utils.UI {
			self.setProgress(controllerType: .userVideo, title: progress.progressTitle)
		}
	}
	
	public func showVideoSortingAnimateProgress(from viewConstroller: UIViewController) {
		let progress: ProgressAlertType = .videoSorting
		presentAnimatedProgress(title: progress.progressTitle,
								progressDelegate: nil,
								from: viewConstroller,
								barColor: theme.videosTintColor,
								animatedColor: theme.videosTintColor,
								withCancel: false)
	}
			
	public func showSimpleProgressAlerControllerBar(of type: ProgressAlertType, from viewController: UIViewController, delegate: AnimatedProgressDelegate? = nil) {
		presentAnimatedProgress(title: type.progressTitle, progressDelegate: delegate, from: viewController, barColor: .white, animatedColor: type.accentColor, withCancel: type.withCancel)
	}
}

