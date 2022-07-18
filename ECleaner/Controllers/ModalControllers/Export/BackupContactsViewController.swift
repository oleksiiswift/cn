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
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonHeightConststraint: NSLayoutConstraint!
	@IBOutlet weak var currentProgressContactTextLabel: UILabel!
	
	private let backgroundImageView = UIImageView(image: Images.personalisation.contacts.cloud)
	private var progressTitleTextLabel = UILabel()
	private lazy var circleprogress = CircleProgressView()
	
	private var currentProgress: ContactsBackupStatus = .initial
	private var savedURL: URL?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		setupUI()
		updateColors()
		setupObseervers()
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
				self.currentProgressContactTextLabel.isHidden = true
				self.circleprogress.setProgress(progress: 0 , animated: false)
				self.setCurrenProgressName(name: "", status: .initial)
			case .prepare:
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: .prepare)
				self.bottomButtonView.startAnimatingButton()
				self.circleprogress.setProgress(progress: 0 , animated: false)
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
			case .processing:
				self.currentProgressContactTextLabel.isHidden = false
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
			case .empty:
				self.currentProgressContactTextLabel.isHidden = true
				self.setCurrenProgressName(name: "", status: .empty)
				self.circleprogress.setProgress(progress: 0 , animated: false)
				self.bottomButtonView.actionButton.setbuttonAvailible(true)
			case .filesCreated(_):
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: status)
				self.circleprogress.setProgress(progress: 0 , animated: false)
				self.bottomButtonView.actionButton.setbuttonAvailible(false)
				
				let image = UIImage(systemName: "archivebox")!
				let size = CGSize(width: 100, height: 100)
				let instricticSize = image.getPreservingAspectRationScaleImageSize(from: size)
				self.backgroundImageView.image = image
				self.backgroundImageView.widthAnchor.constraint(equalToConstant: instricticSize.width).isActive = true
				self.backgroundImageView.heightAnchor.constraint(equalToConstant: instricticSize.height).isActive = true
				self.backgroundImageView.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor, constant: -50).isActive = true
				self.backgroundImageView.layoutIfNeeded()
				
				
			case .archived(url: let url):
				self.savedURL = url
				self.currentProgressContactTextLabel.isHidden = false
				let size = Utils.getSpaceFromInt(Int64(url.fileSize))
				let fileName = Localization.Main.Title.contactsTitle.lowercased() + ".zip"
				self.setCurrenProgressName(name: fileName + ", " + size, status: status)
				self.bottomButtonView.stopAnimatingButton()
				self.circleprogress.setProgress(progress: 0 , animated: false)
				
				Utils.delay(1) {
					self.bottomButtonView.actionButton.setbuttonAvailible(true)
					self.shareContacsBackup(with: url)
				}
			case .error(_):
				self.currentProgressContactTextLabel.isHidden = false
				self.setCurrenProgressName(name: "", status: status)
				self.bottomButtonView.stopAnimatingButton()
				self.circleprogress.setProgress(progress: 0 , animated: false)
				self.bottomButtonView.actionButton.setbuttonAvailible(true)
		}
	}
	
	private func shareContacsBackup(with url: URL) {
		
		ShareManager.shared.shareContacts(with: url) {
			
		}
	}
	
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
	
	private func clearFolders() {
		
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
					let string = NSMutableAttributedString(string: "", attributes: expireDateAttributes)
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
					let string = NSMutableAttributedString(string: "archived processing", attributes: expireDateAttributes)
					return string
				case .archived(_):
					let string = NSMutableAttributedString(string: "backup created:", attributes: expireDateAttributes)
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
		
		let statrtTitle = "Start Backup"
		let processing = "processing"
		let archiving = "archiving"
		let save = "save"
		
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
	
	private func setProgress(progress: CGFloat) {
		
		let isHiden = (0.01...0.99).contains(progress)
		
		if self.circleprogress.isHidden == isHiden {
			UIView.transition(with: self.circleprogress, duration: 0.5, options: .transitionCrossDissolve) {
				self.circleprogress.isHidden = !isHiden
				self.backgroundImageView.isHidden = isHiden
			}
		}
		
		self.progressTitleTextLabel.text = String("\(Int((progress * 100).rounded()))%")
		self.circleprogress.setProgress(progress: progress , animated: true)
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
		
		titleTextLabel.text = "Backup"
		titleTextLabel.font = FontManager.exportModalFont(of: .title)
		
		currentProgressContactTextLabel.font = FontManager.exportModalFont(of: .title).monospacedDigitFont
		bottomButtonView.setButtonHeight(AppDimensions.BottomButton.bottomBarButtonDefaultHeight)
		
		mainContainerView.insertSubview(backgroundImageView, at: 0)
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor, constant: -3).isActive = true
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
		circleprogress.percentLabel.font = FontManager.deepCleanScreenFont(of: .progress)
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
		
		backgroundImageView.tintColor = UIColor().colorFromHexString("C9D3E2")
		
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
		circleprogress.startColor = theme.circleStarterGradientColor
		circleprogress.endColor = theme.circleEndingGradientColor
		circleprogress.backgroundShadowColor = theme.bottomShadowColor
		
		let titleLabelBounds = circleprogress.percentLabel.bounds
		let titleGradient = Utils.Manager.getGradientLayer(bounds: titleLabelBounds, colors: theme.titleCircleGradientTitleColorSet)
		let color = Utils.Manager.gradientColor(bounds: titleLabelBounds, gradientLayer: titleGradient)
		circleprogress.percentColor = color ?? theme.titleTextColor
	}
	
	private func setupObseervers() {
		
		ContactsBackupUpdateMediator.instance.setListener(listener: self)
		bottomButtonView.delegate = self
	}
}
