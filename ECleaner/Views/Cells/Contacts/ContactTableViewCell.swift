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
    
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//
//        debugPrint("editing: \(editing)")
//        if editing {
//            self.handleSelectedContact()
//        }
//    }
}


extension ContactTableViewCell {
    
    public func updateContactCell(_ contact: CNContact, contentType: PhotoMediaType) {
        
        self.contact = contact
        
        if contentType == .allContacts {
            contactSubtitleTextLabel.isHidden = true
        }
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)

        let numbers = contact.phoneNumbers.map({$0.value.stringValue})
    
        if contactFullName == nil {
            if !numbers.isEmpty {
                contactTitleTextLabel.text = numbers.joined(separator: numbers.count > 1 ? ", " : "")
            } else {
                contactTitleTextLabel.text = "-"
            }
        } else {
            contactTitleTextLabel.text = contactFullName
        }
        
        if contactEditingMode {
            self.handleSelectedContact()
        } else {
            if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
                shadowRoundedReuseView.setImage(image)
            } else {
                shadowRoundedReuseView.setImage(I.mainMenuThumbItems.contacts)
            }
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
        
        reuseShadowView.topShadowOffsetOriginY = -3
        reuseShadowView.topShadowOffsetOriginX = -2
        reuseShadowView.viewShadowOffsetOriginX = 6
        reuseShadowView.viewShadowOffsetOriginY = 6
        reuseShadowView.topBlurValue = 15
        reuseShadowView.shadowBlurValue = 5
    
        contactTitleTextLabel.font = .systemFont(ofSize: 16, weight: .bold)
        contactSubtitleTextLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        selectedBackgroundView = backgroundView
    }
    
    func updateColors() {
        
        baseView.backgroundColor = .clear
        shadowRoundedReuseView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
    }
    
    private func superPrepareForReuse() {
        
        accessoryType = .none
        
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
    }
}
