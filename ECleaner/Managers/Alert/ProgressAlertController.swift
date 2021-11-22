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
}

class ProgressAlertControllerDeprio {

    private let progressAlertController: UIAlertController
    private var progrssBar: UIProgressView

    init(title: String, delegate: ProgressAlertControllerDelegate?, progressColor: UIColor) {


        progressAlertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        progrssBar = UIProgressView(progressViewStyle: .default)
        progrssBar.tintColor = progressColor

        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { _ in
            delegate?.didTapCancelOperation()
        }
        progressAlertController.addAction(cancelAction)
    }

    func presentProgress(in viewController: UIViewController) {

        viewController.present(progressAlertController, animated: true) {
            let margin: CGFloat = 16.0
            let rect = CGRect(x: margin, y: 56, width: self.progressAlertController.view.frame.width -  margin * 2.0, height: 2.0)
            self.progrssBar.frame = rect
            self.progressAlertController.view.addSubview(self.progrssBar)
            U.notificationCenter.addObserver(self, selector: #selector(self.progressNotification(_:)), name: .progressAlertDidChangeProgress, object: nil)
        }
    }

    public func setObserver() {
       
    }

    @objc func progressNotification(_ notification: Notification) {

        guard let userInfo = notification.userInfo else { return }

        if let progress = userInfo[C.key.notificationDictionary.progrssAlertValue] as? Float {
            setProgress(progress)
        }
    }

    func dismiss(completion: (() -> Void)?) {
        progressAlertController.dismiss(animated: true, completion: completion)
    }

    func setProgress(_ value: Float) {
        U.UI {
            debugPrint("values of the Progress: \(value)")
            self.progressAlertController.message = "\(value)"
            self.progrssBar.setProgress(value, animated: true)
        }
    }
}



class AlertController {
    
    static func createAlertControllerWithProgressView(withTitle title: String?, withMessage message: String?) -> (UIAlertController, UIProgressView) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: 0, y: 57, width: 270, height: 0)
        
        alertController.view.addSubview(progressView)
        progressView.setProgress(0, animated: true)
        
        return (alertController, progressView)
    }
}



class AlertProgressAlertController: Themeble {

    static var shared = AlertProgressAlertController()
    
    var alertController = UIAlertController()
//    let progressBar = UIProgressView(progressViewStyle: .default)
//    var zz = ProgressBar()
    let progressBar = ProgressAlertBar()
    
    var delegate: ProgressAlertControllerDelegate?
    
    var contentProgressType: MediaContentType = .none
    
    private var theme = ThemeManager.theme
    
    var progressBarTintColor: UIColor {
        switch contentProgressType {
            case .userPhoto:
                return theme.phoneTintColor
            case .userVideo:
                return theme.videosTintColor
            case .userContacts:
                return theme.contactsTintColor
            case .none:
                return .black
        }
    }
    
    func updateColors() {
        self.progressBar.borderColor = theme.alertProgressBorderColor
        self.progressBar.mainBackgroundColor = theme.alertProgressBackgroundColor
        self.progressBar.progressColor = progressBarTintColor
    }
    
    public func showDeleteContactsProgressAlert() {
        setProgress(controllerType: .userContacts, title: "delete contacts")
    }
    
    private func setProgress(controllerType: MediaContentType, title: String) {
        contentProgressType = .userContacts
        alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { _ in
            
            self.delegate?.didTapCancelOperation()
        }
        alertController.addAction(cancelAction)
        
        let margin: CGFloat = 16.0
        let rect = CGRect(x: margin, y: 66, width: self.alertController.view.frame.width -  margin * 2.0, height: 10.0)
        self.progressBar.frame = rect
        
        self.updateColors()
        self.alertController.view.addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.leadingAnchor.constraint(equalTo: self.alertController.view.leadingAnchor, constant: 16).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.alertController.view.trailingAnchor, constant: -16).isActive = true
        progressBar.topAnchor.constraint(equalTo: self.alertController.view.topAnchor, constant: 66).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
    
        if let topController = topController() {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func handleDeleteContactsProgress(progress: Float, message: String) {
        
        alertController.message = message
        progressBar.progress = CGFloat(progress)
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
    
    var borderWidth: CGFloat = 2 {
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        
        self.backgroundColor = mainBackgroundColor
        self.setCorner(progressCorner)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.addSubview(progressView)
    }
    
    override func draw(_ rect: CGRect) {
        
        let progressFrame: CGRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
        progressView.setCorner(progressCorner)
        progressView.backgroundColor = progressColor
        progressView.frame = progressFrame
    }
}
