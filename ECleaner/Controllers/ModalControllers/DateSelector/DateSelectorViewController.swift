//
//  DateSelectorViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit
import SwiftMessages

enum PickerDateSelectType {
	case lowerDateSelectable
	case upperDateSelectable
	case lastDeepCleanDateSelectable
	case currentDateSelectable
	case none
	
	var rawValue: Date {
		switch self {
			case .lowerDateSelectable:
				return S.lowerBoundSavedDate
			case .upperDateSelectable:
				return S.upperBoundSavedDate
			case .lastDeepCleanDateSelectable:
				if let date = S.lastSmartCleanDate {
					return date
				} else {
					return S.lowerBoundSavedDate
				}
			case .currentDateSelectable:
				return Date().endOfDay
			case .none:
				return Date()
		}
	}
}

class DateSelectorViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var pickerContainerView: UIView!
	@IBOutlet weak var bottomBarContainerView: UIView!
	@IBOutlet weak var monthDatePicker: SegmentDatePicker!
	@IBOutlet weak var yearDatePicker: SegmentDatePicker!
	@IBOutlet weak var pickerSpacerShadowView: UIView!
    @IBOutlet weak var customNavBar: StartingNavigationBar!
	@IBOutlet weak var autoDatePickView: UIView!
    @IBOutlet weak var autoDatePickButton: UIButton!
    @IBOutlet weak var autoDatePickBackgroundImageView: UIImageView!
    @IBOutlet weak var autoDatePickImageView: UIImageView!
    @IBOutlet weak var autoDatePickTextLabel: UILabel!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
    @IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var customNavigationBarHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomButtonsHeghtConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomButtonsTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var autoDatePickerButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet var pickerComponentsCollection: [SegmentDatePicker]!
	
	private var dissmissGestureRecognizer = UIPanGestureRecognizer()
	private var defaultCalendar = Calendar(identifier: .gregorian)
	public var dateSelectedType: PickerDateSelectType = .none
	
	private var autoPickCheckIsOn: Bool = false
	private var currentPickUpDate: Date?
    public var selectedDateCompletion: ((_ selectedDate: Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupObserversAndDelegate()
		setupDatePickers(with: self.dateSelectedType.rawValue)
        setupUI()
		setupPickerSpacerView()
        updateColors()
		setupGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
    
	@IBAction func didTapSetPickerAutoSettingsActionButton(_ sender: Any) {

		self.checkForEnableAutoPicker()
		self.dateSelectedType = autoPickCheckIsOn ? .lastDeepCleanDateSelectable : .lowerDateSelectable
		U.delay(0.5) {
			self.checkLastDeepCleanDate()
		}
	}
}

extension DateSelectorViewController {
	
	public func setPicker(_ value: Date) {
		U.UI {
			self.monthDatePicker.setCurrentDate(value, animated: true)
			self.yearDatePicker.setCurrentDate(value, animated: true)
		}
	}
	
	private func setTheDate(month: Int, year: Int, dateType: PickerDateSelectType) {
		
		switch dateType{
			case .lowerDateSelectable:
				self.currentPickUpDate = U.getDateFromComponents(day: 1, month: month, year: year)
			case .upperDateSelectable:
				let endOfTheMonth = U.numbersOfDays(at: month, in: year)
				let date = U.getDateFromComponents(day: endOfTheMonth, month: month, year: year)
				self.currentPickUpDate = date
			case .lastDeepCleanDateSelectable:
				self.currentPickUpDate = dateType.rawValue
			case .currentDateSelectable:
				self.currentPickUpDate = dateType.rawValue
			default:
				return
		}
	}
	
	private func checkLastDeepCleanDate() {
		if self.dateSelectedType.rawValue != S.lowerBoundSavedDate {
			setTheDate(month: 0, year: 0, dateType: .lastDeepCleanDateSelectable)
			self.setPicker(self.dateSelectedType.rawValue)
		} else {
			self.dateSelectedType = .lowerDateSelectable
			self.setPicker(self.dateSelectedType.rawValue)
			self.setDisableDateAutoPicker()
		}
	}
	
	private func checkForEnableAutoPicker() {
		autoPickCheckIsOn = !autoPickCheckIsOn
		autoDatePickImageView.isHidden = !autoPickCheckIsOn
	}
	
	private func setDisableDateAutoPicker() {
		autoPickCheckIsOn = false
		autoDatePickImageView.isHidden = true
	}
	
	
	public func checkTheDate(with dateSelectType: PickerDateSelectType, completion: @escaping () -> Void) {
		
		switch dateSelectType {
			case .lowerDateSelectable:
				if let date = currentPickUpDate {
					if date > S.upperBoundSavedDate {
						self.downgradeLower()
					} else if date.getYear() == S.upperBoundSavedDate.getYear(), date.getMonth() == S.upperBoundSavedDate.getMonth() {
						self.downgradeLower()
					} else {
						completion()
					}
				}
			case .upperDateSelectable:
				if let date = currentPickUpDate {
					if date < S.lowerBoundSavedDate {
						self.downgradeUpper()
					} else if date.getYear() == S.lowerBoundSavedDate.getYear(), date.getMonth() == S.lowerBoundSavedDate.getMonth() {
						self.downgradeUpper()
					} else {
						completion()
					}
				}
			case .lastDeepCleanDateSelectable:
				self.checkLastDeepCleanDate()
				completion()
			default:
				return
		}
	}
	
	private func downgradeLower() {
		var month = S.upperBoundSavedDate.getMonth()
		var year = S.upperBoundSavedDate.getYear()
		
		if month == 1 {
			month = 12
			year -= 1
		} else {
			month -= 1
		}
		
		let newPickDate = U.getDateFromComponents(day: 1, month: month, year: year)
		self.setPicker(newPickDate)
	}
	
	private func downgradeUpper() {
		var month = S.lowerBoundSavedDate.getMonth()
		var year = S.lowerBoundSavedDate.getYear()
		
		if month == 12 {
			month = 1
			year += 1
		} else {
			month += 1
		}
		
		let theLastDayOfSummer = Utils.numbersOfDays(at: month, in: year)
		let newPickDate = U.getDateFromComponents(day: theLastDayOfSummer, month: month, year: year)
		self.setPicker(newPickDate)
	}
	
	private func closeDatePicker() {
		self.dismiss(animated: true) {
			if let date = self.currentPickUpDate {
				self.selectedDateCompletion?(date)
			}
		}
	}
}

extension DateSelectorViewController: StartingNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {}
	
	func didTapRightBarButton(_sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension DateSelectorViewController: SegmentDatePickerDelegate {
	
	func datePicker(_ segmentDatePicker: SegmentDatePicker, didSelect row: Int, in component: Int) {
	
		let month = monthDatePicker.currentDate.getMonth()
		let year = yearDatePicker.currentDate.getYear()
		self.setTheDate(month: month, year: year, dateType: self.dateSelectedType)
		U.delay(1) {
			self.checkTheDate(with: self.dateSelectedType) {
				
			}
		}
	}
}

extension DateSelectorViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		self.checkTheDate(with: self.dateSelectedType) {
			self.closeDatePicker()
		}
	}
}

extension DateSelectorViewController: Themeble {

    private func setupUI() {
			
		var containerHeight: CGFloat {
			switch dateSelectedType {
				case .lowerDateSelectable:
					return U.UIHelper.AppDimensions.DateSelectController.datePickerContainerHeightLower
				case .upperDateSelectable:
					return U.UIHelper.AppDimensions.DateSelectController.datePickerContainerHeightUper
				default:
					return .zero
			}
		}
		
		switch dateSelectedType {
			case .lowerDateSelectable:
				autoDatePickView.isHidden = false
				bottomButtonsTopConstraint.constant = 0
				bottomButtonsHeghtConstraint.constant = U.UIHelper.AppDimensions.DateSelectController.fullDatePickerContainerHeight
			case .upperDateSelectable:
				bottomButtonsTopConstraint.constant = U.UIHelper.AppDimensions.DateSelectController.bottomContainerSpacerHeight
				bottomButtonsHeghtConstraint.constant = U.UIHelper.AppDimensions.DateSelectController.cutDatePickerContainerHeight
				autoDatePickView.isHidden = true
			default:
				return
		}
		customNavigationBarHeightConstraint.constant = U.UIHelper.AppDimensions.NavigationBar.navigationBarHeight
		
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
        mainContainerViewHeightConstraint.constant = containerHeight
	
		let autoDateSelectSize = U.UIHelper.AppDimensions.NavigationBar.navigationBarButtonSize - 10
		autoDatePickerButtonWidthConstraint.constant = autoDateSelectSize
	
		bottomButtonView.title("SUBMIT".localized())
        autoDatePickTextLabel.text = "SINCE_THE_LAST_CLEANING".localized()
		autoDatePickTextLabel.font = U.UIHelper.AppDefaultFontSize.PickerController.buttonSubTitleFontSize
		
		let checkMarkImage = I.systemItems.selectItems.checkBox.renderScalePreservingAspectRatio(from: CGSize(width: autoDateSelectSize / 2, height: autoDateSelectSize / 2))
        autoDatePickImageView.image = checkMarkImage
		autoDatePickImageView.isHidden = true
		autoDatePickBackgroundImageView.layer.applySketchShadow(color: UIColor().colorFromHexString("D8DFEB"), alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
    }
	
	private func setupDatePickers(with date: Date) {
		
		self.yearDatePicker.datePickerType = .year
		self.monthDatePicker.datePickerType = .month
		
		pickerComponentsCollection.forEach {
			$0.delegate = self
			$0.calendarIdentifier = defaultCalendar.identifier
			$0.font = U.UIHelper.AppDefaultFontSize.PickerController.pickerFontSize
			$0.disabledFont = U.UIHelper.AppDefaultFontSize.PickerController.pickerFontSize
			$0.pickerLocale = Locale(identifier: "en_US")
			$0.maximumDate = Date()
			$0.selectebleLowerPeriodBound = self.dateSelectedType == .lowerDateSelectable
			$0.setCurrentDate(date, animated: false)
			$0.reloadAllComponents()
		}
	}
    
	private func setupPickerSpacerView() {
		
		let container = UIView()
		container.backgroundColor = theme.backgroundColor
		
		pickerContainerView.addSubview(container)
		
		container.translatesAutoresizingMaskIntoConstraints = false
		container.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 10).isActive = true
		container.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: 50).isActive = true
		container.widthAnchor.constraint(equalToConstant: 3).isActive = true
		container.centerXAnchor.constraint(equalTo: pickerContainerView.centerXAnchor).isActive = true
	
		let lefty = UIView()
		lefty.backgroundColor = theme.backgroundColor
		container.addSubview(lefty)
		lefty.translatesAutoresizingMaskIntoConstraints = false
		lefty.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
		lefty.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
		lefty.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
		lefty.widthAnchor.constraint(equalToConstant: 1.5).isActive = true
		
		let righty = UIView()
		righty.backgroundColor = theme.backgroundColor
		container.addSubview(righty)
		righty.translatesAutoresizingMaskIntoConstraints = false
		righty.leadingAnchor.constraint(equalTo: lefty.trailingAnchor).isActive = true
		righty.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
		righty.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
		righty.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
		
		let leftyGradientMask: CAGradientLayer = CAGradientLayer()
		leftyGradientMask.frame = CGRect(x: 0.0, y: 0.0, width: 1.5, height: pickerContainerView.frame.height - 20)
		leftyGradientMask.colors = [theme.backgroundColor.cgColor,
									theme.separatorMainColor.cgColor,
									theme.backgroundColor.cgColor]
		leftyGradientMask.startPoint = CGPoint(x: 0.0, y: 0.0)
		leftyGradientMask.endPoint = CGPoint(x: 0.0, y: 1.0)
	
		let rightyGradientMask: CAGradientLayer = CAGradientLayer()
		rightyGradientMask.frame = CGRect(x: 0.0, y: 0.0, width: 1.5, height: pickerContainerView.frame.height - 20)
		rightyGradientMask.colors = [theme.backgroundColor.cgColor,
									theme.separatorHelperColor.cgColor,
									theme.backgroundColor.cgColor]
		rightyGradientMask.startPoint = CGPoint(x: 0.0, y: 0.0)
		rightyGradientMask.endPoint = CGPoint(x: 0.0, y: 1.0)
		
		lefty.layer.addSublayer(leftyGradientMask)
		righty.layer.addSublayer(rightyGradientMask)
		
		leftyGradientMask.bringToFront()
		rightyGradientMask.bringToFront()
	}
	
	func setupNavigation() {
	
		var navigationText: String {
			switch self.dateSelectedType {
				case .lowerDateSelectable:
					return "select lower date"
				case .upperDateSelectable:
					return "select upper date"
				default:
					return ""
			}
		}
		
		customNavBar.setUpNavigation(title: navigationText.uppercased(), rightImage: I.systemItems.navigationBarItems.dissmiss, targetImageScaleFactor: 0.4)
		customNavBar.topShevronEnable = true
	}
	
	private func setupGestureRecognizers() {
		
		let animator = TopBottomAnimation(style: .bottom)
		dissmissGestureRecognizer = animator.panGestureRecognizer
		dissmissGestureRecognizer.cancelsTouchesInView = false
		animator.panGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(dissmissGestureRecognizer)
	}
	
	func setupObserversAndDelegate() {

		customNavBar.delegate = self
		bottomButtonView.delegate = self
	}
	
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = theme.backgroundColor
		bottomButtonView.backgroundColor = .clear
		bottomButtonView.buttonTitleColor = theme.activeLinkTitleTextColor
		bottomButtonView.buttonColor = theme.activeButtonBackgroundColor
		bottomButtonView.buttonTintColor = theme.activeLinkTitleTextColor
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadow()
		bottomButtonView.updateColorsSettings()
		
        autoDatePickTextLabel.textColor = theme.subTitleTextColor
		self.monthDatePicker.textColor = theme.titleTextColor
		self.yearDatePicker.textColor = theme.titleTextColor
    }
}

extension DateSelectorViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer == dissmissGestureRecognizer {
			let pickerPoint = gestureRecognizer.location(in: self.pickerContainerView)
			let bottomContainerPoint = gestureRecognizer.location(in: self.bottomBarContainerView)
			
			if self.pickerContainerView.bounds.contains(pickerPoint) {
				return false
			} else if self.bottomBarContainerView.bounds.contains(bottomContainerPoint) {
				return false
			}
		}
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		
		if gestureRecognizer == dissmissGestureRecognizer {
			let pickerPoint = gestureRecognizer.location(in: self.pickerContainerView)
			let bottomContainerPoint = gestureRecognizer.location(in: self.bottomBarContainerView)
			
			if self.pickerContainerView.bounds.contains(pickerPoint) {
				return true
			} else if self.bottomBarContainerView.bounds.contains(bottomContainerPoint) {
				return true
			}
		}
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
