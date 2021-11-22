//
//  DateSelectebleView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 06.10.2021.
//

import UIKit

protocol DateSelectebleViewDelegate {
    func didSelectStartingDate()
    func didSelectEndingDate()
}

class DateSelectebleView: UIView {

    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var startingDateTitileTextLabel: UILabel!
    @IBOutlet weak var endingDateTitleTextLabel: UILabel!
    @IBOutlet weak var startingDateTextLabel: UILabel!
    @IBOutlet weak var endingDateTextLabel: UILabel!
    
    var delegate: DateSelectebleViewDelegate?
    
    private var startingDate: String = ""
    private var endingDate: String = ""
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        setupUI()
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    @IBAction func didTapSelectStartDateActionButton(_ sender: Any) {
        
        delegate?.didSelectStartingDate()
    }
    
    @IBAction func didTapSelectEndDateActionButton(_ sender: Any) {
        
        delegate?.didSelectEndingDate()
    }
    
    
  private func commonInit() {
    
    U.mainBundle.loadNibNamed(C.identifiers.xibs.datePickerContainer, owner: self, options: nil)
    
    dateSelectContainerView.backgroundColor = theme.innerBackgroundColor
    dateSelectContainerView.clipsToBounds = true
    dateSelectContainerView.layer.cornerRadius = 14
      
    dateSelectContainerView.layer.applySketchShadow(
      color: UIColor().colorFromHexString("D8DFEB"),
      alpha: 1.0,
      x: 6,
      y: 6,
      blur: 10,
      spread: 0)
    
    self.addSubview(self.dateSelectContainerView)
    self.dateSelectContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let margins = self.safeAreaLayoutGuide
    dateSelectContainerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
    dateSelectContainerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
    dateSelectContainerView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
    dateSelectContainerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10).isActive = true
      
    dateSelectContainerView.layer.masksToBounds = true
  }
    
  public func setupDisplaysDate(startingDate: String, endingDate: String) {
    
      startingDateTextLabel.text = U.displayDate(from: startingDate).uppercased()
      endingDateTextLabel.text = U.displayDate(from: endingDate).uppercased()
  }
    
  private func setupUI() {
    
    startingDateTitileTextLabel.text = "FROM".localized()
    endingDateTitleTextLabel.text = "TO".localized()
    
    startingDateTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 16.0)
    endingDateTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 16.0)
    startingDateTitileTextLabel.font = UIFont(font: FontManager.robotoBold, size: 14.0)
    endingDateTitleTextLabel.font = UIFont(font: FontManager.robotoBold, size: 14.0)
  }
    
  private func updateColors() {
    
    startingDateTextLabel.textColor = theme.titleTextColor.withAlphaComponent(0.7)
    endingDateTextLabel.textColor = theme.titleTextColor.withAlphaComponent(0.7)
    
    startingDateTitileTextLabel.textColor = theme.titleTextColor.withAlphaComponent(0.5)
    endingDateTitleTextLabel.textColor = theme.titleTextColor.withAlphaComponent(0.5)
  }
}
