//
//  GroupContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.10.2021.
//

import UIKit
import Contacts

class GroupContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topShadowView: SectionShadowView!
    @IBOutlet weak var shhadowImageView: ShadowRoundedView!
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var contactTitleTextLabel: UILabel!
    @IBOutlet weak var contactSubtitleTextLabel: UILabel!
    
    @IBOutlet weak var topBaseViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBaseViewConstraint: NSLayoutConstraint!
    
    private var customSeparator = UIView()
    private let helperSeparatorView = UIView()
    

    
    private var indexPath: IndexPath?
    private var isFirstRowInSection: Bool = false
    private var isLastRowInSection: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
        shhadowImageView.imageView.image = nil

//        topShadowView.prepareForReuse()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shhadowImageView.rounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}

extension GroupContactTableViewCell {
    
    public func updateContactCell(_ contact: CNContact) {
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
        
        contactTitleTextLabel.text = contactFullName
        
        let numbers = contact.phoneNumbers.map({$0.value.stringValue})
    
        contactSubtitleTextLabel.text = numbers.joined(separator: numbers.count > 1 ? ", " : "")
    
        if let imageData = contact.thumbnailImageData {
            let image = UIImage(data: imageData)
            shhadowImageView.imageView.image = image
            
        } else {
            shhadowImageView.imageView.image = I.mainMenuThumbItems.contacts
        }
    }
}


extension GroupContactTableViewCell: Themeble {

    private func setupUI() {
        
        selectionStyle = .none
        shhadowImageView.rounded()
        contactTitleTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        contactSubtitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
    }
    
    func updateColors() {
        topShadowView.backgroundColor = .clear
        baseView.backgroundColor = .clear
        
        contactTitleTextLabel.textColor = theme.titleTextColor
        contactSubtitleTextLabel.textColor = theme.contactsAccentColor

        customSeparator.backgroundColor = theme.separatorMainColor
        helperSeparatorView.backgroundColor = theme.separatorHelperColor
    }
    
    public func showTopInset() {
        self.topBaseViewConstraint.constant = 20
        self.baseView.layoutIfNeeded()
    }
    
    public func showBottomInset() {
        self.bottomBaseViewConstraint.constant = 20
        self.baseView.layoutIfNeeded()
    }
    
    public func setupForCustomSeparator(_ isShow: Bool) {
        
        guard isShow else { return }
        
        self.baseView.addSubview(customSeparator)
        customSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        customSeparator.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 23).isActive = true
        customSeparator.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23).isActive = true
        customSeparator.heightAnchor.constraint(equalToConstant: 3).isActive = true
        customSeparator.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 0).isActive = true
        
        customSeparator.addSubview(helperSeparatorView)
        helperSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        helperSeparatorView.leadingAnchor.constraint(equalTo: customSeparator.leadingAnchor).isActive = true
        helperSeparatorView.trailingAnchor.constraint(equalTo: customSeparator.trailingAnchor).isActive = true
        helperSeparatorView.bottomAnchor.constraint(equalTo: customSeparator.bottomAnchor).isActive = true
        helperSeparatorView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
    }
}

