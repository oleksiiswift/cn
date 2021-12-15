//
//  DateSelectorViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit

class DateSelectorViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var pickerContainerView: UIView!
	@IBOutlet weak var monthDatePicker: SegmentDatePicker!
	@IBOutlet weak var yearDatePicker: SegmentDatePicker!
	@IBOutlet weak var pickerSpacerShadowView: UIView!
    @IBOutlet weak var customNavBar: StartingNavigationBar!
	@IBOutlet weak var spaceStackEmptyView: UIView!
	@IBOutlet weak var autoDatePickView: UIView!
    @IBOutlet weak var autoDatePickButton: UIButton!
    @IBOutlet weak var autoDatePickBackgroundImageView: UIImageView!
    @IBOutlet weak var autoDatePickImageView: UIImageView!
    @IBOutlet weak var autoDatePickTextLabel: UILabel!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
    @IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
	
	private var defaultCalendar = Calendar(identifier: .gregorian)
	public var isStartingDateSelected: Bool = false
	private var autoPickCheckIsOn: Bool = false
	private var currentPickUpDate: Date?
    private var selectedDate: Date {
        get {
			if isStartingDateSelected {
				return S.lowerBoundSavedDate
			} else {
				return S.upperBoundSavedDate
			}
		}
    }

    public var selectedDateCompletion: ((_ selectedDate: Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupObserversAndDelegate()
		setupDatePickers(with: self.selectedDate)
        setupUI()
		setupPickerSpacerView()
        updateColors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
    
	@IBAction func didTapSetPickerAutoSettingsActionButton(_ sender: Any) {
		
		autoPickCheckIsOn = !autoPickCheckIsOn
		autoDatePickImageView.isHidden = !autoPickCheckIsOn
		
		if let savedDate = S.lastSmartCleanDate {
			self.setPicker(savedDate)
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
	
	private func setTheDate(month: Int, year: Int) {
		
		if isStartingDateSelected {
			self.currentPickUpDate = U.getDateFromComponents(day: 1, month: month, year: year)
		} else {
			let endOfTheMonth = U.numbersOfDays(at: month, in: year)
			let date = U.getDateFromComponents(day: endOfTheMonth, month: month, year: year)
			self.currentPickUpDate = date
		}
	}
	public func checkTheDate(completion: @escaping () -> Void) {
		
		if isStartingDateSelected {
			if let date = currentPickUpDate {
				if date > S.upperBoundSavedDate {
					self.downgradeLower()
				} else if date.getYear() == S.upperBoundSavedDate.getYear(), date.getMonth() == S.upperBoundSavedDate.getMonth() {
					self.downgradeLower()
				} else {
					completion()
				}
			}
		} else {
			if let date = currentPickUpDate {
				if date < S.lowerBoundSavedDate {
					self.downgradeUpper()
				} else if date.getYear() == S.lowerBoundSavedDate.getYear(), date.getMonth() == S.lowerBoundSavedDate.getMonth() {
					self.downgradeUpper()
				} else {
					completion()
				}
			}
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
		self.setTheDate(month: month, year: year)
		U.delay(1) {
			self.checkTheDate {}
		}
	}
}

extension DateSelectorViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		checkTheDate {
			self.closeDatePicker()
		}
	}
}

extension DateSelectorViewController: Themeble {

    private func setupUI() {
        
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
        
        let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 458 : 438
        self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
        mainContainerViewHeightConstraint.constant = containerHeight
        
		bottomButtonView.title("SUBMIT".localized())
        
		autoDatePickView.isHidden = !isStartingDateSelected
		spaceStackEmptyView.isHidden = isStartingDateSelected
	
        autoDatePickTextLabel.text = "SINCE_THE_LAST_CLEANING".localized()
        autoDatePickTextLabel.font = UIFont(font: FontManager.robotoBold, size: 14.0)
        autoDatePickImageView.image = I.systemElementsItems.checkBox
        
        autoDatePickBackgroundImageView.layer.applySketchShadow(color: UIColor().colorFromHexString("D8DFEB"), alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
        
        autoDatePickImageView.isHidden = !autoPickCheckIsOn
    }
	
	private func setupDatePickers(with date: Date) {
		
		self.yearDatePicker.delegate = self
		self.yearDatePicker.calendarIdentifier = defaultCalendar.identifier
		self.yearDatePicker.font = .systemFont(ofSize: 26, weight: .black)
		self.yearDatePicker.disabledFont = .systemFont(ofSize: 26, weight: .black)
		self.yearDatePicker.pickerLocale = Locale(identifier: "en_US")
		self.yearDatePicker.datePickerType = .year
		self.yearDatePicker.reloadAllComponents()
		self.yearDatePicker.maximumDate = Date()
		self.yearDatePicker.selectebleLowerPeriodBound = isStartingDateSelected
		self.yearDatePicker.setCurrentDate(date, animated: false)
		
		self.monthDatePicker.delegate = self
		self.monthDatePicker.calendarIdentifier = defaultCalendar.identifier
		self.monthDatePicker.font = .systemFont(ofSize: 26, weight: .black)
		self.monthDatePicker.disabledFont = .systemFont(ofSize: 26, weight: .black)
		self.monthDatePicker.pickerLocale = Locale(identifier: "en_US")
		self.monthDatePicker.datePickerType = .month
		self.monthDatePicker.maximumDate = Date()
		self.monthDatePicker.selectebleLowerPeriodBound = isStartingDateSelected
		self.monthDatePicker.reloadAllComponents()
		self.monthDatePicker.setCurrentDate(date, animated: false)
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
		
		let navigationText: String = isStartingDateSelected ? "select lower date" : "select upper date"
		
		customNavBar.setUpNavigation(title: navigationText, leftImage: nil, rightImage: I.systemItems.navigationBarItems.dissmiss)
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
