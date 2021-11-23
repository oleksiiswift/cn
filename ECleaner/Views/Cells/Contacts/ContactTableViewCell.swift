//
//  ContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.11.2021.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reuseShadowView: ReuseShadowView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var contactTitleTextLabel: UILabel!
    @IBOutlet weak var contactSubtitleTextLabel: UILabel!
    @IBOutlet weak var shadowRoundedReuseView: ReuseShadowRoundedView!
    @IBOutlet weak var topBaseViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBaseViewConstraint: NSLayoutConstraint!
    
    private var contact: CNContact?
    
    public var contactEditingMode: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        superPrepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if contactEditingMode {
            self.handleSelectedContact()
        }
    }
}


extension ContactTableViewCell {
    
    public func updateContactCell(_ contact: CNContact, contentType: PhotoMediaType) {
        
        self.contact = contact
        
        switch contentType {
            case .allContacts:
                setupAllContactCell(contact)
            case .emptyContacts:
                setupEmptyContactCell(contact)
            default:
                return
        }
        
        if contactEditingMode {
            self.handleSelectedContact()
        } else {
            if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
                shadowRoundedReuseView.setImage(image)
            } else {
                shadowRoundedReuseView.setImage(I.personalisation.contacts.contactPhoto)
            }
        }
    }
    
    private func setupAllContactCell(_ contact: CNContact) {
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
        let numbers = contact.phoneNumbers.map({$0.value.stringValue})
        let emails = contact.emailAddresses.map({$0.value as String})
    
        if contactFullName == nil {
            if numbers.isEmpty {
                if emails.count == 0 {
                    setupForMissingData(type: .wholeEmpty, textData: "all missing data")
                } else {
                    setupForMissingData(type: .onlyEmail, textData: emails.joined(separator: emails.count > 1 ? ", " : ""))
                }
            } else {
                setupForMissingData(type: .onlyPhone, textData: numbers.joined(separator: numbers.count > 1 ? ", " : ""))
            }
        } else {
            if let contactFullName = contactFullName {
                setupForMissingData(type: .none, textData: contactFullName)
            }
        }
    }
    
    private func setupForMissingData(type: ContactasCleaningType, textData: String) {
        
        switch type {
            case .wholeEmpty:
                
                contactTitleTextLabel.text = "-"
                contactSubtitleTextLabel.isHidden = true
                contactTitleTextLabel.font = .italicSystemFont(ofSize: 16, weight: .regular)
                contactTitleTextLabel.textColor = theme.subTitleTextColor
            case .onlyEmail:
                contactTitleTextLabel.text = "-"
                contactTitleTextLabel.textColor = theme.titleTextColor
                contactTitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
                
                contactSubtitleTextLabel.text = textData
                contactSubtitleTextLabel.textColor = theme.subTitleTextColor
                contactSubtitleTextLabel.font = .italicSystemFont(ofSize: 14, weight: .regular)
                contactSubtitleTextLabel.isHidden = false
                
            default:
                contactTitleTextLabel.text = textData
                contactSubtitleTextLabel.isHidden = true
                contactTitleTextLabel.textColor = theme.titleTextColor
                contactTitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
        }
    }

    private func setupEmptyContactCell(_ contact: CNContact) {
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
        let numbers = contact.phoneNumbers.map({$0.value.stringValue})
        let emails = contact.emailAddresses.map({$0.value as String})
        
        if contactFullName != nil {
            contactTitleTextLabel.text = contactFullName
            contactTitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
            contactTitleTextLabel.textColor = theme.titleTextColor
            
            if numbers.isEmpty {
                contactSubtitleTextLabel.font = .italicSystemFont(ofSize: 14, weight: .regular)
                contactSubtitleTextLabel.textColor = theme.subTitleTextColor
                if emails.isEmpty {
                    contactSubtitleTextLabel.text = "number missing"
                } else {
                    contactSubtitleTextLabel.text = emails.joined(separator: emails.count > 1 ? ", " : "")
                }
            }
        } else if numbers.count != 0 {
            contactTitleTextLabel.text = "name missing"
            contactTitleTextLabel.font = .italicSystemFont(ofSize: 16, weight: .regular)
            contactTitleTextLabel.textColor = theme.subTitleTextColor
            
            contactSubtitleTextLabel.text = numbers.joined(separator: numbers.count > 1 ? ", " : "")
            contactSubtitleTextLabel.font = .systemFont(ofSize: 14, weight: .bold)
            contactSubtitleTextLabel.textColor = theme.titleTextColor
        } else if emails.count != 0 {
            contactTitleTextLabel.text = emails.joined(separator: numbers.count > 1 ? ", " : "")
            contactTitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
            contactTitleTextLabel.textColor = theme.titleTextColor
            
            contactSubtitleTextLabel.text = "all data missing"
            contactSubtitleTextLabel.font = .italicSystemFont(ofSize: 14, weight: .regular)
            contactSubtitleTextLabel.textColor = theme.subTitleTextColor
        } else {
            contactSubtitleTextLabel.isHidden = true
            contactTitleTextLabel.font = .italicSystemFont(ofSize: 14, weight: .regular)
            contactTitleTextLabel.text = "all data missing"
            contactTitleTextLabel.textColor = theme.subTitleTextColor
        }
    }
    
    private func handleSelectedContact() {
        
        if isSelected {
            shadowRoundedReuseView.setImage(I.personalisation.contacts.selectContact)
        } else {
            shadowRoundedReuseView.setImage(I.personalisation.contacts.deselectContact)
        }
    }
}

extension ContactTableViewCell: Themeble {
    
    private func setupUI() {
        
        reuseShadowView.topShadowOffsetOriginY = -2
        reuseShadowView.topShadowOffsetOriginX = -2
        reuseShadowView.viewShadowOffsetOriginX = 6
        reuseShadowView.viewShadowOffsetOriginY = 6
        reuseShadowView.topBlurValue = 15
        reuseShadowView.shadowBlurValue = 5
    
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
    
    func updateColors() {
        
        baseView.backgroundColor = .clear
        shadowRoundedReuseView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor.withAlphaComponent(0.5))
    }
    
    private func superPrepareForReuse() {
        
        accessoryType = .none
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
        shadowRoundedReuseView.setImage(nil)
    }
}
