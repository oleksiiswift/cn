//
//  BackupContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.07.2022.
//

import UIKit


class BackupContactsViewController: UIViewController {

	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var topShevronView: UIView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonHeightConststraint: NSLayoutConstraint!
	@IBOutlet weak var currentProgressContactTextLabel: UILabel!
	@IBOutlet weak var progressContainerView: UIView!
	
	private var progressBar = ProgressAlertBar()
	
	private lazy var circleprogress = CircleProgressView()
	
	override func viewDidLoad() {
        super.viewDidLoad()

		setupUI()
		updateColors()
		setupObseervers()
		setupProgressBar()
		setContainer(status: .initial)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
	}
}

extension BackupContactsViewController: BottomActionButtonDelegate {
	
	private func setContainer(status: ContactsBackupStatus) {
		
		switch status {
			case .initial:
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = true
			case .prepare:
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: .prepare)
				self.bottomButtonView.startAnimatingButton()
			case .processing:
//				self.progressBar.isHidden = false
				self.currentProgressContactTextLabel.isHidden = false
			case .empty:
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = true
				self.setCurrenProgressName(name: "", status: .empty)
			case .filesCreated(_):
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: status)
			case .archived(_):
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "file name MB", status: status)
				
				self.bottomButtonView.stopAnimatingButton()
			case .error(_):
//				self.progressBar.isHidden = true
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: status)
				
				self.bottomButtonView.stopAnimatingButton()
			
		}
	}
	
	func didTapActionButton() {
		
		ContactsExportManager.shared.contactsBackup { status in
			self.setContainer(status: status)
		}
	}
}

extension BackupContactsViewController: ContactsBackupUpdateListener {
	
	func didUpdateStatus(_ status: ContactsBackupStatus) {
		Utils.UI {
			self.setContainer(status: status)
		}
	}
	
	func didUpdateProgress(with name: String, progress: CGFloat) {
		Utils.UI {
			self.setCurrenProgressName(name: name, status: .processing)
			self.setProgress(progress: progress)
		}
	}
}

extension BackupContactsViewController {
	
	private func setCurrenProgressName(name: String, status: ContactsBackupStatus) {
				
		let dateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .premiumBannerDateSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		let expireDateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .permiumBannerSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		
		var attributedString: NSMutableAttributedString {
			
			switch status {
				case .initial:
					return NSMutableAttributedString.init(string: "")
				case .prepare:
					let string = NSMutableAttributedString(string: "prepare", attributes: expireDateAttributes)
					return string
				case .empty:
					let string = NSMutableAttributedString(string: "contact store is empty", attributes: expireDateAttributes)
					return string
				case .processing:
					let string = NSMutableAttributedString(string: "current contact:", attributes: expireDateAttributes)
					string.append(NSAttributedString(string: " "))
					string.append(NSAttributedString(string: name, attributes: dateAttributes))
					return string
				case .filesCreated(_):
					let string = NSMutableAttributedString(string: "archived", attributes: expireDateAttributes)
					return string
				case .archived(_):
					let string = NSMutableAttributedString(string: "archive created", attributes: expireDateAttributes)
					string.append(NSAttributedString(string: " "))
					string.append(NSAttributedString(string: name, attributes: dateAttributes))
					return string
				case .error(let error):
					let string = NSMutableAttributedString(string: "backup error", attributes: expireDateAttributes)
					string.append(NSAttributedString(string: " "))
					string.append(NSAttributedString(string: error.localizedDescription, attributes: dateAttributes))
					return string
			}
		}
		currentProgressContactTextLabel.attributedText = attributedString
	}
	
	private func setProgress(progress: CGFloat) {
		progressBar.progress = progress
		
		U.animate(1) {
			self.circleprogress.isHidden = !(0.01...0.99).contains(progress)
		}
		
		circleprogress.setProgress(progress: progress , animated: true)
		self.circleprogress.layoutIfNeeded()
	}
}

extension BackupContactsViewController: Themeble {
	
	private func setupUI() {
		
		progressContainerView.isHidden = true
		
		let containerHeight: CGFloat = AppDimensions.ContactsController.ExportModalController.controllerHeight
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerHeightConstraint.constant = containerHeight
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		topShevronView.setCorner(3)
		topShevronView.backgroundColor = theme.subTitleTextColor
		
		titleTextLabel.text = "Backup"
		titleTextLabel.font = FontManager.exportModalFont(of: .title)
		
		currentProgressContactTextLabel.font = FontManager.exportModalFont(of: .title).monospacedDigitFont
	
		let image = I.systemItems.defaultItems.refresh
		let size = CGSize(width: 25, height: 25)
		let instricticSize = image.getPreservingAspectRationScaleImageSize(from: size)
		bottomButtonView.actionButton.imageSize = instricticSize
		bottomButtonView.setImage(image, with: instricticSize)
		bottomButtonView.title("start backup")
		bottomButtonView.setButtonHeight(AppDimensions.BottomButton.bottomBarButtonDefaultHeight)
		
		
		let backgroundImageView = UIImageView(image: Images.personalisation.contacts.cloud)

		mainContainerView.insertSubview(backgroundImageView, at: 0)
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor).isActive = true
		backgroundImageView.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -70).isActive = true
		
		backgroundImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
		backgroundImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
		
		
		mainContainerView.addSubview(circleprogress)
		circleprogress.translatesAutoresizingMaskIntoConstraints = false
		circleprogress.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor).isActive = true
		circleprogress.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -50).isActive = true
		circleprogress.widthAnchor.constraint(equalToConstant: 150).isActive = true
		circleprogress.heightAnchor.constraint(equalToConstant: 150).isActive = true

		circleprogress.isHidden = true
		circleprogress.disableBackgrounShadow = true
		circleprogress.lineWidth = 3
		circleprogress.backgroundShapeColor = .clear
		circleprogress.startColor = MediaContentType.userContacts.screeAcentGradientUICoror.first!
		circleprogress.endColor = MediaContentType.userContacts.screeAcentGradientUICoror.last!
		circleprogress.percentLabel.isHidden = true
		circleprogress.alpha = 0.7
	}
	
	private func setupProgressBar() {
		
		progressContainerView.addSubview(progressBar)
		progressBar.translatesAutoresizingMaskIntoConstraints = false
		
		progressBar.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor).isActive = true
		progressBar.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor).isActive = true
		progressBar.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor).isActive = true
		progressBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		
		titleTextLabel.textColor = theme.titleTextColor
		
		bottomButtonView.buttonColor = theme.cellBackGroundColor
		bottomButtonView.buttonTintColor = theme.secondaryTintColor
		bottomButtonView.buttonTitleColor = theme.titleTextColor
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadow()
		bottomButtonView.updateColorsSettings()
		
		progressBar.mainBackgroundColor = theme.cellBackGroundColor
		progressBar.progressColor = theme.contactsTintColor
		progressBar.updateColors()
	}
	
	private func setupObseervers() {
		
		ContactsBackupUpdateMediator.instance.setListener(listener: self)
		bottomButtonView.delegate = self
	}
}
