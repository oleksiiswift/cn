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
    @IBOutlet weak var startingDateStackView: UIStackView!
    @IBOutlet weak var endingDateStackView: UIStackView!
    @IBOutlet weak var startingDateButtonView: UIView!
    @IBOutlet weak var endingDateButtonView: UIView!
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
        
        self.addSubview(self.dateSelectContainerView)
        self.dateSelectContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                                        self.dateSelectContainerView.topAnchor.constraint(equalTo: self.topAnchor),
                                        self.dateSelectContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                        self.dateSelectContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                        self.dateSelectContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)])
    }
    
    public func setupDisplaysDate(startingDate: String, endingDate: String) {
        
        startingDateTextLabel.text = U.displayDate(from: startingDate)
        endingDateTextLabel.text = U.displayDate(from: endingDate)
    }
    
    private func setupUI() {
        
        startingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        startingDateStackView.isLayoutMarginsRelativeArrangement = true
        endingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        endingDateStackView.isLayoutMarginsRelativeArrangement = true
        
        startingDateButtonView.setCorner(12)
        endingDateButtonView.setCorner(12)
        
        startingDateTitileTextLabel.text = "from"
        endingDateTitleTextLabel.text = "to"
    
        startingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        startingDateTitileTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private func updateColors() {
        
        startingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        endingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        
        startingDateTitileTextLabel.textColor = currentTheme.titleTextColor
        endingDateTextLabel.textColor = currentTheme.titleTextColor
        
        startingDateTitileTextLabel.textColor = currentTheme.subTitleTextColor
        endingDateTitleTextLabel.textColor = currentTheme.subTitleTextColor
    }
}
