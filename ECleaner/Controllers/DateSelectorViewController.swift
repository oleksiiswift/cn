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
    @IBOutlet weak var lastCleanButton: UIButton!
    @IBOutlet weak var lastCleanImageView: UIImageView!
    @IBOutlet weak var lastCleanTextLabel: UILabel!
    @IBOutlet weak var submitButtonView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
    
    private var lastCleanCheckIsOn: Bool = false
    public var isStartingDateSelected: Bool = false
    
    private var selectedDate: String {
        get {
            Date().convertDateFormatterFromDate(date: periodDatePicker.date, format: C.dateFormat.dmy)
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
    
    
    @IBAction func didTapCalculateLastCleaningActionButton(_ sender: Any) {
        
        lastCleanCheckIsOn = !lastCleanCheckIsOn
        lastCleanImageView.image = lastCleanCheckIsOn ? I.systemElementsItems.checkBoxIsChecked : I.systemElementsItems.checkBox
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
        
        lastCleanTextLabel.text = "since the last cleaning"
        lastCleanTextLabel.font = .systemFont(ofSize: 17, weight: .regular)
        lastCleanImageView.image = I.systemElementsItems.checkBox
        periodDatePicker.maximumDate = Date()
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = currentTheme.backgroundColor
        submitButtonView.backgroundColor = currentTheme.accentBackgroundColor
        submitButton.setTitleColor(currentTheme.backgroundColor, for: .normal)
        dissmissButtonImageView.tintColor = currentTheme.tintColor
        lastCleanTextLabel.textColor = currentTheme.titleTextColor
        lastCleanImageView.tintColor = currentTheme.titleTextColor
    }
}

extension DateSelectorViewController {
    
    private func closeDatePicker() {
        self.dismiss(animated: true) {
            self.selectedDateCompletion?(self.selectedDate)
        }
    }
    
    public func setPicker(_ value: String) {
        if let date = Date().getDateFromString(stringDate: value, format: C.dateFormat.dmy) {
            U.UI {
                self.periodDatePicker.setDate(date, animated: true)
            }
        }
    }
    
    public func checkTheDate() {
        
        if let date = Date().getDateFromString(stringDate: self.selectedDate, format: C.dateFormat.dmy),
           let highBoundDate = Date().getDateFromString(stringDate: self.isStartingDateSelected ? S.endingSavedDate : S.startingSavedDate, format: C.dateFormat.dmy) {
            if isStartingDateSelected ? date > highBoundDate : date < highBoundDate {
                AlertManager.showAlert("alarm", message:  isStartingDateSelected ? "loco date is bigger" : "loco date is lower", actions: []) {
                    self.setPicker(self.isStartingDateSelected ? S.timeMachine : Date().convertDateFormatterFromDate(date: Date(), format: C.dateFormat.dmy))
                }
            } else {
                self.closeDatePicker()
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
