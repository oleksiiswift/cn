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

enum ProgressContactsAlertType {
	case mergeContacts
	case deleteContacts
	
	var progressTitle: String {
		switch self {
			case .mergeContacts:
				return "merged contacts"
			case .deleteContacts:
				return "delete contacts"
		}
	}
}

class ProgressAlertController: Themeble {

    static var shared = ProgressAlertController()
    
    var alertController = UIAlertController()
    let progressBar = ProgressAlertBar()
    
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
        self.progressBar.borderColor = theme.alertProgressBorderColor
        self.progressBar.mainBackgroundColor = theme.alertProgressBackgroundColor
        self.progressBar.progressColor = progressBarTintColor
        self.progressBar.updateColors()
    }
    
    private func setProgress(controllerType: MediaContentType, title: String) {
		
		guard !controllerPresented else { return}
		
        contentProgressType = .userContacts
        alertController = UIAlertController(title: title, message: " ", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { _ in
            
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
		alertController.dismiss(animated: true, completion: nil)
	}
}

extension ProgressAlertController {
    
    public func showDeleteContactsProgressAlert() {
        setProgress(controllerType: .userContacts, title: "delete merged contacts")
    }
    
    public func showMergeContactsProgressAlert() {
        setProgress(controllerType: .userContacts, title: "merged contacts")
    }
	
	public func showDeepCleanProgressAlert() {
		setProgress(controllerType: .none, title: "deep clean processing")
	}
	
	public func showContactsProgressAlert(of type: ProgressContactsAlertType) {
		setProgress(controllerType: .userContacts, title: type.progressTitle)
	}
}

class ProgressAlertBar: UIView {
    
    private var progressView = UIView()
    
    var progressColor: UIColor = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var mainBackgroundColor: UIColor = .gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var progressCorner: CGFloat = 6 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderColor: UIColor = .orange {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderWidth: CGFloat = 1.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        updateColors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        
        self.addSubview(progressView)
    }
    
    public func updateColors() {
        self.backgroundColor = mainBackgroundColor
        self.setCorner(progressCorner)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        
        let progressFrame: CGRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
        progressView.setCorner(progressCorner)
        progressView.backgroundColor = progressColor
        progressView.frame = progressFrame
    }
}

