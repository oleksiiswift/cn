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
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var dissmissButtonImageView: UIImageView!
    @IBOutlet weak var autoDatePickButton: UIButton!
    @IBOutlet weak var autoDatePickImageView: UIImageView!
    @IBOutlet weak var autoDatePickTextLabel: UILabel!
    @IBOutlet weak var submitButtonView: UIView!
    @IBOutlet weak var submitButton: UIButton!
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

        setupUI()
        updateColors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
    
    
    @IBAction func didTapSetPickerAutoSettingsActionButton(_ sender: Any) {
        
            autoPickCheckIsOn = !autoPickCheckIsOn
            autoDatePickImageView.image = autoPickCheckIsOn ? I.systemElementsItems.checkBoxIsChecked : I.systemElementsItems.checkBox
        
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
    

    @IBAction func didTapDissmissViewControllerActionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        
        submitButtonView.setCorner(12)
        submitButton.setTitle("submit", for: .normal)
        dissmissButtonImageView.image = I.systemElementsItems.crissCross
        
        titleTextLabel.text = "select period"
        
        autoDatePickTextLabel.text = isStartingDateSelected ? "since the last cleaning" : "now is the time for"
        autoDatePickTextLabel.font = .systemFont(ofSize: 17, weight: .regular)
        autoDatePickImageView.image = I.systemElementsItems.checkBox
        periodDatePicker.maximumDate = Date()
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = currentTheme.backgroundColor
        submitButtonView.backgroundColor = currentTheme.accentBackgroundColor
        submitButton.setTitleColor(currentTheme.backgroundColor, for: .normal)
        dissmissButtonImageView.tintColor = currentTheme.tintColor
        autoDatePickTextLabel.textColor = currentTheme.titleTextColor
        autoDatePickImageView.tintColor = currentTheme.titleTextColor
    }
}
