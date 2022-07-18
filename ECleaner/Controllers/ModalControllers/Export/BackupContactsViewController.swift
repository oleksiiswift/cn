//
//  BackupContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.07.2022.
//

import UIKit
import SwiftMessages

class BackupContactsViewController: UIViewController {

	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var topShevronView: UIView!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonHeightConststraint: NSLayoutConstraint!
	@IBOutlet weak var currentProgressContactTextLabel: UILabel!
	
	private lazy var circleprogress = CircleProgressView()
	private let backgroundImageView = UIImageView()
	private var progressTitleTextLabel = UILabel()
	
	private var tapOutsideRecognizer: UITapGestureRecognizer!
	private var dissmissGestureRecognizer = UIPanGestureRecognizer()
	
	private var currentProgress: ContactsBackupStatus = .initial
	private var savedURL: URL?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		setupUI()
		updateColors()
		setupObseervers()
		setContainer(status: .initial)
		setupGestureRecognizers()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.setupDissmissGestureRecognizer()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
	}
}

extension BackupContactsViewController {
	
	private func shareContacsBackup(with url: URL) {
		ShareManager.shared.shareContacts(with: url) { completed in
			if completed {
				self.closeController(sender: self)
			}
		}
	}
	
	private func clearFolders() {
		ECFileManager().deleteAllFiles(at: .contactsArcive) {}
		ECFileManager().deleteAllFiles(at: .systemTemp) {}
	}
}

extension BackupContactsViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		switch self.currentProgress {
			case .archived(_):
				if let url = savedURL {
					self.shareContacsBackup(with: url)
				}
			default:
				ContactsExportManager.shared.contactsBackup { status in
					self.setContainer(status: status)
				}
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
			self.handleCurrentProgressTitle(with: .processing, name: name)
			self.setProgress(progress: progress)
		}
	}
}

extension BackupContactsViewController {
	
	private func setContainer(status: ContactsBackupStatus) {
		
		currentProgress = status
		handleBackroundImage(with: status)
		handleCurrentProgressTitle(with: status)
		handleBackroundImage(with: status)
		handleBottomButton(with: status)

		switch status {
			case .initial:
				return
			case .prepare:
				self.bottomButtonView.startAnimatingButton()
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
			case .processing:
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
			case .empty:
				self.bottomButtonView.actionButton.setbuttonAvailible(true)
			case .filesCreated(_):
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
			case .archived(url: let url):
				self.savedURL = url
				self.bottomButtonView.stopAnimatingButton()
				self.bottomButtonView.actionButton.setbuttonAvailible(true)
				self.shareContacsBackup(with: url)
			case .error(_):
				self.bottomButtonView.stopAnimatingButton()
				self.bottomButtonView.actionButton.setbuttonAvailible(true)
		}
	}
	
	private func handleCurrentProgressTitle(with status: ContactsBackupStatus, name: String = "") {
				
		if case .initial = status {
			self.currentProgressContactTextLabel.isHidden = true
		} else {
			self.currentProgressContactTextLabel.isHidden = false
		}
		
		let dateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .premiumBannerDateSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		let expireDateAttributes: [NSAttributedString.Key: Any] = [.font: FontManager.subscriptionFont(of: .permiumBannerSubtitle), .foregroundColor: theme.premiumSubtitleTextColor]
		var attributedString: NSMutableAttributedString {
			switch status {
				case .initial:
					return NSMutableAttributedString.init(string: L.empty)
				case .prepare:
					let string = NSMutableAttributedString(string: L.empty, attributes: expireDateAttributes)
					return string
				case .empty:
					let string = NSMutableAttributedString(string: Localization.ErrorsHandler.EmptyResultsError.contactsIsEmpty, attributes: expireDateAttributes)
					return string
				case .processing:
					let string = NSMutableAttributedString(string: Localization.Backup.currentContact, attributes: expireDateAttributes)
					string.append(NSAttributedString(string: L.whitespace))
					string.append(NSAttributedString(string: name, attributes: dateAttributes))
					return string
				case .filesCreated(_):
					let string = NSMutableAttributedString(string: Localization.Backup.archiveProcessing, attributes: expireDateAttributes)
					return string
				case .archived(let url):
					let size = Utils.getSpaceFromInt(Int64(url.fileSize))
					let fileName = Localization.Main.Title.contactsTitle.lowercased() + ".zip"
					let string = NSMutableAttributedString(string: Localization.Backup.backupCreated, attributes: expireDateAttributes)
					string.append(NSAttributedString(string: L.whitespace))
					string.append(NSAttributedString(string: fileName + ", " + size, attributes: dateAttributes))
					return string
				case .error(let error):
					let string = NSMutableAttributedString(string: Localization.Backup.error, attributes: expireDateAttributes)
					string.append(NSAttributedString(string: L.whitespace))
					string.append(NSAttributedString(string: error.localizedDescription, attributes: dateAttributes))
					return string
			}
		}
		
		currentProgressContactTextLabel.attributedText = attributedString
	}
	
	private func handleBottomButton(with status: ContactsBackupStatus) {
		
		let refreshImage = I.systemItems.defaultItems.refresh
		let saveImage = I.systemItems.defaultItems.save
		
		let size = CGSize(width: 25, height: 25)
		var buttonImage: UIImage {
			switch status {
				case .initial, .prepare, .empty, .processing:
					return refreshImage
				case .filesCreated(_):
					return refreshImage
				case .archived(_):
					return saveImage
				case .error(_):
					return refreshImage
			}
		}
		 
		let instricticSize = buttonImage.getPreservingAspectRationScaleImageSize(from: size)
		bottomButtonView.actionButton.imageSize = instricticSize
		
		if !bottomButtonView.isSetImage(buttonImage) {
			bottomButtonView.setImage(buttonImage, with: instricticSize)
		}
		
		let statrtTitle = LocalizationService.Buttons.getButtonTitle(of: .startBackup)
		let processing = Localization.Main.ProcessingState.processing
		let archiving = Localization.Main.ProcessingState.archiving
		let save = LocalizationService.Buttons.getButtonTitle(of: .save)
		
		var buttonTitle: String {
			switch status {
				case .initial:
					return statrtTitle
				case .prepare:
					return statrtTitle
				case .empty:
					return statrtTitle
				case .processing:
					return processing
				case .filesCreated(_):
					return archiving
				case .archived(_):
					return save
				case .error(_):
					return statrtTitle
			}
		}
		bottomButtonView.title(buttonTitle.uppercased())
	}
	
	private func handleBackroundImage(with state: ContactsBackupStatus) {

		self.backgroundImageView.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor, constant: -3).isActive = true
		self.backgroundImageView.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -50).isActive = true
	
			switch state {
				case .initial, .empty:
					self.setCloudBackgroundImage()
				case .prepare:
					self.setCloudBackgroundImage()
				case .processing:
					self.setProcessingBackgroundImage()
				case .filesCreated(_):
					self.setArchiveBackgroundImage()
				case .archived(_):
					UIView.transition(with: self.circleprogress, duration: 0.5, options: .transitionCrossDissolve) {
						if self.circleprogress.isHidden == false {
							self.circleprogress.isHidden = true
						}
					}
				case .error(_):
					self.setCloudBackgroundImage()
			}
	}
	
	private func setCloudBackgroundImage() {
		
		let initialImage = Images.personalisation.contacts.cloud!
		
		guard self.backgroundImageView.image != initialImage else { return }
		
		let size = CGSize(width: 150, height: 150)
		let instricticSize = initialImage.getPreservingAspectRationScaleImageSize(from: size)
		
		self.setBackground(image: initialImage, with: instricticSize)
	}
	
	private func setArchiveBackgroundImage() {
		
		let archiveImage = Images.personalisation.contacts.archiveBox
		
		guard self.backgroundImageView.image != archiveImage else { return }
		
		let size = CGSize(width: 80, height: 80)
		let instricticSize = archiveImage.getPreservingAspectRationScaleImageSize(from: size)
		
		self.setBackground(image: archiveImage, with: instricticSize)
	}
	
	private func setProcessingBackgroundImage() {
		
		let processingImage = Images.personalisation.contacts.processing
		
		guard self.backgroundImageView.image != processingImage else { return }
		
		let size = CGSize(width: 80, height: 80)
		let instricticSize = processingImage.getPreservingAspectRationScaleImageSize(from: size)
		
		self.setBackground(image: processingImage, with: instricticSize)
	}
	
	private func setBackground(image: UIImage, with size: CGSize) {
		
		for constraint in self.backgroundImageView.constraints {
			if constraint.firstAttribute == .width {
				constraint.isActive = false
			}
			if constraint.firstAttribute == .height {
				constraint.isActive = false
			}
		}
		
		self.backgroundImageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
		self.backgroundImageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
		UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve) {
			self.backgroundImageView.image = image
			self.backgroundImageView.layoutIfNeeded()
		} completion: { _ in
			debugPrint("remove image")
		}
	}
	
	private func setProgress(progress: CGFloat) {
		
		let isHiden = (0.01...0.99).contains(progress)
		if self.circleprogress.isHidden == isHiden {
			UIView.transition(with: self.circleprogress, duration: 0.5, options: .transitionCrossDissolve) {
				self.circleprogress.isHidden = !isHiden
				self.backgroundImageView.isHidden = isHiden
			}
		} else {
			self.circleprogress.setProgress(progress: progress , animated: true)
		}
		
		if progress == 0.9 {
			self.setArchiveBackgroundImage()
		}
		
		self.progressTitleTextLabel.text = String("\(Int((progress * 100).rounded()))%")
	}
}

extension BackupContactsViewController {
	
	private func setupDissmissGestureRecognizer() {
		
		guard self.tapOutsideRecognizer == nil else { return }
		
		self.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
		self.tapOutsideRecognizer.numberOfTapsRequired = 1
		self.tapOutsideRecognizer.cancelsTouchesInView = false
		self.tapOutsideRecognizer.delegate = self
		U.sceneDelegate.window?.addGestureRecognizer(self.tapOutsideRecognizer)
	}
	
	private func removeDissmissGestureRecognizer() {
		
		guard self.tapOutsideRecognizer != nil else { return }
		
		Utils.sceneDelegate.window?.removeGestureRecognizer(self.tapOutsideRecognizer)
		self.tapOutsideRecognizer = nil
	}
	
	private func setupGestureRecognizers() {
		
		let animator = TopBottomAnimation(style: .bottom)
		dissmissGestureRecognizer = animator.panGestureRecognizer
		dissmissGestureRecognizer.cancelsTouchesInView = false
		animator.panGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(dissmissGestureRecognizer)
	}
	
	@objc func handleTapBehind(sender: UITapGestureRecognizer) {
		
		if sender.state == UIGestureRecognizer.State.ended {
			
			let location: CGPoint = sender.location(in: nil)

			if !self.view.point(inside: self.view.convert(location, from: self.view.window), with: nil) {
				self.view.window?.removeGestureRecognizer(sender)
				self.closeController(sender: sender)
			}
		}
	}
	
	private func closeController(sender: AnyObject) {
		
		switch self.currentProgress {
			case .filesCreated(_), .processing, .prepare:
				return
			default:
				self.dismiss(animated: true) {
					self.removeDissmissGestureRecognizer()
					self.clearFolders()
				}
		}
	}
}

extension BackupContactsViewController: Themeble {
	
	private func setupUI() {
			
		let containerHeight: CGFloat = AppDimensions.ContactsController.ExportModalController.controllerHeight
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerHeightConstraint.constant = containerHeight
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		topShevronView.setCorner(3)
		topShevronView.backgroundColor = theme.subTitleTextColor
		
		titleTextLabel.text = Localization.Main.MediaContentTitle.backup
		titleTextLabel.font = FontManager.exportModalFont(of: .title)
		
		currentProgressContactTextLabel.font = FontManager.exportModalFont(of: .title).monospacedDigitFont
		bottomButtonView.setButtonHeight(AppDimensions.BottomButton.bottomBarButtonDefaultHeight)
				
		mainContainerView.insertSubview(backgroundImageView, at: 0)
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

		mainContainerView.addSubview(circleprogress)
		circleprogress.translatesAutoresizingMaskIntoConstraints = false
		circleprogress.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor).isActive = true
		circleprogress.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -50).isActive = true
		circleprogress.widthAnchor.constraint(equalToConstant: 150).isActive = true
		circleprogress.heightAnchor.constraint(equalToConstant: 150).isActive = true
		
		circleprogress.isHidden = true
		let startPoint = CGPoint(x: 0.0, y: 0.0)
		let endPoint = CGPoint(x: 1.0, y: 0.0)
		circleprogress.gradientSetup(startPoint: startPoint, endPoint: endPoint, gradientType: .axial)
		
		circleprogress.disableBackgrounShadow = false
		circleprogress.titleLabelTextAligement = .center
		circleprogress.orientation = .bottom
		circleprogress.titleLabelsPercentPosition = .centered
		circleprogress.lineCap = .round
		circleprogress.clockwise = true
		circleprogress.percentLabelFormat = "%.f%%"
		circleprogress.percentLabel.font = .systemFont(ofSize: 16, weight: .medium)
		circleprogress.lineWidth = AppDimensions.CircleProgress.circleProgressInfoLineWidth
		
		progressTitleTextLabel.isHidden = true
		progressTitleTextLabel.font = .systemFont(ofSize: 10, weight: .bold).monospacedDigitFont
		mainContainerView.addSubview(progressTitleTextLabel)
		progressTitleTextLabel.translatesAutoresizingMaskIntoConstraints = false
		progressTitleTextLabel.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor).isActive = true
		progressTitleTextLabel.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -25).isActive = true
	}
		
	func updateColors() {
		
		self.view.backgroundColor = .clear
		
		backgroundImageView.tintColor = theme.backupTintColor
		
		mainContainerView.backgroundColor = theme.backgroundColor
		
		titleTextLabel.textColor = theme.titleTextColor
		
		bottomButtonView.buttonColor = theme.cellBackGroundColor
		bottomButtonView.buttonTintColor = theme.secondaryTintColor
		bottomButtonView.buttonTitleColor = theme.titleTextColor
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadow()
		bottomButtonView.updateColorsSettings()
		
		progressTitleTextLabel.textColor = theme.subTitleTextColor.withAlphaComponent(0.3)
	
		circleprogress.progressShapeColor = theme.tintColor
		circleprogress.backgroundShapeColor = theme.topShadowColor.withAlphaComponent(0.2)
		circleprogress.startColor = theme.contactsGradientStarterColor
		circleprogress.endColor = theme.contactsGradientEndingColor
		circleprogress.backgroundShadowColor = theme.bottomShadowColor
		
		let titleLabelBounds = circleprogress.percentLabel.bounds
		let titleGradient = Utils.Manager.getGradientLayer(bounds: titleLabelBounds, colors: [theme.contactsGradientStarterColor.cgColor, theme.contactsGradientEndingColor.cgColor])
		let color = Utils.Manager.gradientColor(bounds: titleLabelBounds, gradientLayer: titleGradient)
		circleprogress.percentColor = color ?? theme.titleTextColor
	}
	
	private func setupObseervers() {
		
		ContactsBackupUpdateMediator.instance.setListener(listener: self)
		bottomButtonView.delegate = self
	}
}

extension BackupContactsViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	
		switch self.currentProgress {
			case .filesCreated(_), .processing, .prepare:
				if gestureRecognizer == dissmissGestureRecognizer {
					let point = gestureRecognizer.location(in: self.view)
					if self.view.bounds.contains(point) {
						return false
					}
				}
			default:
				return true
		}
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
	
		switch self.currentProgress {
			case .filesCreated(_), .processing, .prepare:
				if gestureRecognizer == dissmissGestureRecognizer {
					let point = gestureRecognizer.location(in: self.view)
					
					if self.view.bounds.contains(point) {
						return true
					}
				}
			default:
				return true
		}
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
