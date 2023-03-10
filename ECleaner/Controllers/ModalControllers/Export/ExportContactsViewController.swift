//
//  ExportContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.11.2021.
//

import UIKit
import SwiftMessages

class ExportContactsViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var topShevronView: UIView!
    @IBOutlet weak var controllerTitleTextLabel: UILabel!
    @IBOutlet weak var helperTopView: UIView!
    @IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var exportButtonStackView: UIStackView!
	@IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var bottomButtonView: BottomButtonBarView!
    @IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButtonView: ReuseShadowView!
    @IBOutlet weak var rightButtonView: ReuseShadowView!
	@IBOutlet weak var bottomButtonMenuHeightConstraint: NSLayoutConstraint!
	
	public var leftExportFileFormat: ExportContactsAvailibleFormat = .none
    public var rightExportFileFormat: ExportContactsAvailibleFormat = .none
    
    public var selectExportFormatCompletion: ((_ selectedFormat: ExportContactsAvailibleFormat) -> Void)?
    public var selectExtraOptionalOption: (() -> Void)?
	
	private var dissmissGestureRecognizer = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateColors()
        setupDelegate()
		stupGesturerecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			case C.identifiers.segue.backupContacts:
				self.setupShowContactsBackupController(segue: segue)
			default:
				break
		}
	}
    
    @IBAction func didTapLeftActionButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.selectExportFormatCompletion?(self.leftExportFileFormat)
        }
    }
    
    @IBAction func didTapRightActionButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.selectExportFormatCompletion?(self.rightExportFileFormat)
        }
    }
}

extension ExportContactsViewController: Themeble {
    
    private func setupUI() {
        
		let containerHeight: CGFloat = AppDimensions.ContactsController.ExportModalController.controllerHeight
        self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
        mainContainerHeightConstraint.constant = containerHeight
		bottomButtonMenuHeightConstraint.constant = AppDimensions.ContactsController.ExportModalController.bottomButtonViewHeight
		bottomButtonView.setButtonHeight(AppDimensions.BottomButton.bottomBarButtonDefaultHeight)
		
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
        topShevronView.setCorner(3)
        
		controllerTitleTextLabel.text = Localization.Main.HeaderTitle.selectFileFormat
		controllerTitleTextLabel.font = FontManager.exportModalFont(of: .title)
    
        leftButton.setTitleColor(theme.titleTextColor, for: .normal)
		leftButton.titleLabel?.font = FontManager.exportModalFont(of: .buttons)
        rightButton.setTitleColor(theme.titleTextColor, for: .normal)
		rightButton.titleLabel?.font = FontManager.exportModalFont(of: .buttons)
        
        leftButton.setTitle(leftExportFileFormat.formatRowValue, for: .normal)
        rightButton.setTitle(rightExportFileFormat.formatRowValue, for: .normal)
        
		bottomButtonView.title(Localization.Main.MediaContentTitle.backup.uppercased())
        
		let image = I.systemElementsItems.persons
		let size = CGSize(width: 25, height: 25)
		let instricticSize = image.getPreservingAspectRationScaleImageSize(from: size)
		bottomButtonView.actionButton.imageSize = instricticSize
		bottomButtonView.setImage(image, with: instricticSize)
		self.view.layoutIfNeeded()
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = theme.backgroundColor
        topShevronView.backgroundColor = theme.subTitleTextColor
        controllerTitleTextLabel.textColor = theme.titleTextColor
        leftButton.setTitleColor(theme.titleTextColor, for: .normal)
        rightButton.setTitleColor(theme.titleTextColor, for: .normal)
        bottomButtonView.buttonColor = theme.cellBackGroundColor
        bottomButtonView.buttonTintColor = theme.secondaryTintColor
        bottomButtonView.buttonTitleColor = theme.titleTextColor
        bottomButtonView.configureShadow = true
        bottomButtonView.addButtonShadow()
        bottomButtonView.updateColorsSettings()
    }

    private func setupDelegate() {
        
        bottomButtonView.delegate = self
    }
	
	private func stupGesturerecognizers() {
		
		let animator = TopBottomAnimation(style: .bottom)
		dissmissGestureRecognizer = animator.panGestureRecognizer
		dissmissGestureRecognizer.cancelsTouchesInView = false
		animator.panGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(dissmissGestureRecognizer)
	}
}

extension ExportContactsViewController: BottomActionButtonDelegate {
    
    func didTapActionButton() {
		SubscriptionManager.instance.purchasePremiumHandler { status in
			switch status {
				case .lifetime, .purchasedPremium:
					self.performSegue(withIdentifier: C.identifiers.segue.backupContacts, sender: self)
				case .nonPurchased:
					UIPresenter.showViewController(of: .subscription)
			}
		}
    }
	
	private func setupShowContactsBackupController(segue: UIStoryboardSegue) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .color(color: .clear, interactive: false)
		segue.interactiveHide = true
		segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
		segue.messageView.configureNoDropShadow()
		
		if let backupViewController = segue.destination as? BackupContactsViewController {
			backupViewController.didSeceltCloseController = {
				self.closeControllerWithCompletion()
			}
		}
	}
	
	private func closeControllerWithCompletion() {
		self.dismiss(animated: true) {
			self.selectExtraOptionalOption?()
		}
	}
}

extension ExportContactsViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		
		if gestureRecognizer == dissmissGestureRecognizer {
			let stackPoint = gestureRecognizer.location(in: self.exportButtonStackView)
			let bottomButtonPoint = gestureRecognizer.location(in: self.bottomButtonView)
			
			if self.exportButtonStackView.bounds.contains(stackPoint) {
				return false
			}
			
			if self.bottomButtonView.bounds.contains(bottomButtonPoint) {
				return false
			}
		}
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		
		if gestureRecognizer == dissmissGestureRecognizer {
			let point = gestureRecognizer.location(in: self.helperTopView)

			if self.helperTopView.bounds.contains(point) {
				return true
			}
		}
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
