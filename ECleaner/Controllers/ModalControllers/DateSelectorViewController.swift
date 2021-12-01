//
//  DateSelectorViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit

class DateSelectorViewController: UIViewController {
    
    @IBOutlet weak var periodDatePicker: UIDatePicker!
    @IBOutlet weak var mainContainerView: UIView!
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
            U.getString(from: periodDatePicker.date, format: C.dateFormat.fullDmy)
        }
    }
    
    public var selectedDateCompletion: ((_ selectedDate: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupObserversAndDelegate()
        setupUI()
        updateColors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
    
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
                periodDatePicker.setDate(date, animated: true)
            }
        } else {
            if autoPickCheckIsOn {
                periodDatePicker.setDate(Date(), animated: true)
            }
        }
    }
    
    @IBAction func didTapSubmitActionButton(_ sender: Any) {
        self.checkTheDate()
    }
    
    @IBAction func didPickUpActionPicker(_ sender: Any) {
        debugPrint(selectedDate)
    }
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
                self.periodDatePicker.setDate(date, animated: true)
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
        periodDatePicker.maximumDate = Date()
        
        autoDatePickBackgroundImageView.layer.applySketchShadow(
            color: UIColor().colorFromHexString("D8DFEB"),
            alpha: 1.0,
            x: 6,
            y: 6,
            blur: 10,
            spread: 0)
        
        autoDatePickImageView.isHidden = !autoPickCheckIsOn
        
        periodDatePicker.setValue(false, forKey: "highlightsToday")
        periodDatePicker.setValue(theme.titleTextColor, forKeyPath: "textColor")
        if periodDatePicker.subviews[0].subviews.count >= 2 {
            periodDatePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
        }
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = theme.backgroundColor
        submitButtonTextLabel.textColor = theme.blueTextColor
        autoDatePickTextLabel.textColor = theme.subTitleTextColor
    }
}

extension DateSelectorViewController: StartingNavigationBarDelegate {
    
    func didTapLeftBarButton(_sender: UIButton) {}
    
    func didTapRightBarButton(_sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
