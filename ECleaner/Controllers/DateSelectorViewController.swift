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
    @IBOutlet weak var submitButtonView: UIView!
    
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var mainContainerViewHeightConstraint: NSLayoutConstraint!
    
    private var lastCleanCheckIsOn: Bool = false
    
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
        debugPrint(lastCleanCheckIsOn)
        let checkImage = lastCleanCheckIsOn ? I.systemElementsItems.checkBoxIsChecked : I.systemElementsItems.checkBox
        lastCleanButton.addLeftImage(image: checkImage!, size: CGSize(width: 30, height: 30), spacing: 10)
        lastCleanButton.addLeftImage(image: checkImage!, size: CGSize(width: 30, height: 30), spacing: 10)
    }
    

    @IBAction func didTapDissmissViewControllerActionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmitActionButton(_ sender: Any) {
        
    }
    
    
    @IBAction func didPickUpActionPicker(_ sender: Any) {
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
        
        lastCleanButton.setTitle("since the last cleaning", for: .normal)
        lastCleanButton.addLeftImage(image: I.systemElementsItems.checkBox!, size: CGSize(width: 30, height: 30), spacing: 10)
        
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = currentTheme.backgroundColor
        submitButtonView.backgroundColor = currentTheme.accentBackgroundColor
        submitButton.setTitleColor(currentTheme.backgroundColor, for: .normal)
        dissmissButtonImageView.tintColor = currentTheme.tintColor
        lastCleanButton.setTitleColor(currentTheme.titleTextColor, for: .normal)
        lastCleanButton.tintColor = currentTheme.titleTextColor
    }
}
