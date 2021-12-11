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
    @IBOutlet weak var autoDatePickButton: UIButton!
    @IBOutlet weak var autoDatePickBackgroundImageView: UIImageView!
    @IBOutlet weak var autoDatePickImageView: UIImageView!
    @IBOutlet weak var autoDatePickTextLabel: UILabel!
    @IBOutlet weak var submitButtonView: ShadowView!
    @IBOutlet weak var submitButtonTextLabel: UILabel!
    @IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
    
	private var autoPickCheckIsOn: Bool = false
    public var isStartingDateSelected: Bool = false
    
    private var selectedDate: String {
        get {
//            U.getString(from: periodDatePicker.date, format: C.dateFormat.fullDmy)
			""
        }
    }
    
    public var selectedDateCompletion: ((_ selectedDate: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupObserversAndDelegate()
		setupDatePickers()
        setupUI()
		setupPickerSpacerView()
        updateColors()
		

		
		
		
//		self.datePicker.font = .systemFont(ofSize: 20, weight: .bold)
//		self.datePicker.showsLargeContentViewer = false

		
	
		
////		let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: (pickerContainerView.bounds.height - 216) / 2), size: CGSize(width: view.bounds.width, height: 216)))
//		let picker = MonthYearPickerView(frame: CGRect(x: 0, y: 0, width: pickerContainerView.frame.height, height: pickerContainerView.frame.width))
//
//
//
////			  picker.minimumDate = Date()
//			  picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
//			  picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
//		pickerContainerView.addSubview(picker)
//		picker.translatesAutoresizingMaskIntoConstraints = false
//
//		picker.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 20).isActive = true
//		picker.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -20).isActive = true
//		picker.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 0).isActive = true
//		picker.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: 0).isActive = true
//
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		
//		datePicker.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor).isActive = true
//		datePicker.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor).isActive = true
//		datePicker.topAnchor.constraint(equalTo: pickerContainerView.topAnchor).isActive = true
//		datePicker.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor).isActive = true
//		datePicker.layoutIfNeeded()
    }
	
//	@objc func dateChanged(_ picker: MonthYearPickerView) {
//			print("date changed: \(picker.date)")
//		}
//
    func setupNavigation() {
        
        customNavBar.setUpNavigation(title: "SELECT_PERIOD".localized(), leftImage: nil, rightImage: I.systemItems.navigationBarItems.dissmiss)
    }
    
    func setupObserversAndDelegate() {

        customNavBar.delegate = self
	
    }
    
    
    @IBAction func didTapSetPickerAutoSettingsActionButton(_ sender: Any) {
        
            autoPickCheckIsOn = !autoPickCheckIsOn
            autoDatePickImageView.isHidden = !autoPickCheckIsOn//image = autoPickCheckIsOn ? I.systemElementsItems.checkBoxIsChecked : I.systemElementsItems.checkBox
        
        if isStartingDateSelected {
            if let lastPickDate = S.lastSmartCleanDate, let date = U.getDateFrom(string: lastPickDate, format: C.dateFormat.fullDmy) {
//                periodDatePicker.setDate(date, animated: true)
            }
        } else {
            if autoPickCheckIsOn {
//                periodDatePicker.setDate(Date(), animated: true)
            }
        }
    }
    
    @IBAction func didTapSubmitActionButton(_ sender: Any) {
        self.checkTheDate()
    }
    
//    @IBAction func didPickUpActionPicker(_ sender: Any) {
//        debugPrint(selectedDate)
//    }
}

extension DateSelectorViewController {
    
    private func closeDatePicker() {
        self.dismiss(animated: true) {
            self.selectedDateCompletion?(self.selectedDate)
        }
    }
    
    public func setPicker(_ value: String) {
        if let date = U.getDateFrom(string: value, format: C.dateFormat.fullDmy) {
            U.UI {
//                self.periodDatePicker.setDate(date, animated: true)
            }
        }
    }
    
    public func checkTheDate() {
        
        if let date = U.getDateFrom(string: self.selectedDate, format: C.dateFormat.fullDmy),
           let highBoundDate = U.getDateFrom(string: self.isStartingDateSelected ? S.endingSavedDate : S.startingSavedDate, format: C.dateFormat.fullDmy) {
            if isStartingDateSelected ? date > highBoundDate : date < highBoundDate {
                AlertManager.showAlert("alarm", message:  isStartingDateSelected ? "loco date is bigger" : "loco date is lower", actions: []) {
                    self.setPicker(self.isStartingDateSelected ? S.timeMachine : U.getString(from: Date(), format: C.dateFormat.fullDmy))
                }
            } else {
                self.closeDatePicker()
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension DateSelectorViewController: Themeble {

    private func setupUI() {
        
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
        
        let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 458 : 438
        self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
        mainContainerViewHeightConstraint.constant = containerHeight
        
        submitButtonTextLabel.text = "SUBMIT".localized()
        submitButtonTextLabel.font = UIFont(font: FontManager.robotoBlack, size: 16.0)
        
        autoDatePickTextLabel.text = isStartingDateSelected ? "SINCE_THE_LAST_CLEANING".localized() : "NOW_IS_THE_TIME_FOR".localized()
        autoDatePickTextLabel.font = UIFont(font: FontManager.robotoBold, size: 14.0)
        autoDatePickImageView.image = I.systemElementsItems.checkBox
//        periodDatePicker.maximumDate = Date()
        
        autoDatePickBackgroundImageView.layer.applySketchShadow(
            color: UIColor().colorFromHexString("D8DFEB"),
            alpha: 1.0,
            x: 6,
            y: 6,
            blur: 10,
            spread: 0)
        
        autoDatePickImageView.isHidden = !autoPickCheckIsOn
        
//        periodDatePicker.setValue(false, forKey: "highlightsToday")
//        periodDatePicker.setValue(theme.titleTextColor, forKeyPath: "textColor")
//        if periodDatePicker.subviews[0].subviews.count >= 2 {
//            periodDatePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
//        }
    }
	
	private func setupDatePickers() {
		
		self.yearDatePicker.delegate = self
		self.yearDatePicker.calendarIdentifier = .gregorian
		self.yearDatePicker.font = .systemFont(ofSize: 26, weight: .black)
		self.yearDatePicker.disabledFont = .systemFont(ofSize: 26, weight: .black)
		self.yearDatePicker.pickerLocale = Locale(identifier: "en_US")
		self.yearDatePicker.datePickerType = .year
		self.yearDatePicker.reloadAllComponents()
		self.yearDatePicker.maximumDate = Date()
		self.yearDatePicker.selectebleLowerPeriodBound = isStartingDateSelected
		self.yearDatePicker.setCurrentDate(Date(), animated: false)
		
		self.monthDatePicker.delegate = self
		self.monthDatePicker.calendarIdentifier = .gregorian
		self.monthDatePicker.font = .systemFont(ofSize: 26, weight: .black)
		self.monthDatePicker.disabledFont = .systemFont(ofSize: 26, weight: .black)
		self.monthDatePicker.pickerLocale = Locale(identifier: "en_US")
		self.monthDatePicker.datePickerType = .month
		self.monthDatePicker.selectebleLowerPeriodBound = isStartingDateSelected
		self.monthDatePicker.reloadAllComponents()
		self.monthDatePicker.setCurrentDate(Date(), animated: false)
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
	
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = theme.backgroundColor
        submitButtonTextLabel.textColor = theme.blueTextColor
        autoDatePickTextLabel.textColor = theme.subTitleTextColor
		self.monthDatePicker.textColor = theme.titleTextColor
		self.yearDatePicker.textColor = theme.titleTextColor
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
		if segmentDatePicker == monthDatePicker {
			debugPrint(segmentDatePicker.currentDate.getMonth())
		} else if segmentDatePicker == yearDatePicker {
			debugPrint(segmentDatePicker.currentDate.getYear())
		}
	}
}









