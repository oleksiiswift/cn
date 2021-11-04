//
//  ContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.10.2021.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var shhadowImageView: ShadowRoundedView!
    
    @IBOutlet weak var contactTitleTextLabel: UILabel!
    
    @IBOutlet weak var contactSubtitleTextLabel: UILabel!
    @IBOutlet weak var rightShevronImageView: UIImageView!
    
    private var indexPath: IndexPath?
    private var isFirstRowInSection: Bool = false
    private var isLastRowInSection: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
        shhadowImageView.imageView.image = nil
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}

extension ContactTableViewCell {
    
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


extension ContactTableViewCell: Themeble {
    
    private func setupUI() {
        
        selectionStyle = .none
        
        shhadowImageView.rounded()
        
        contactTitleTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        contactSubtitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
        rightShevronImageView.image = I.navigationItems.rightShevronBack
    }
    
    func updateColors() {
        
        baseView.backgroundColor = .clear
        contactTitleTextLabel.textColor = theme.titleTextColor
        contactSubtitleTextLabel.textColor = theme.subTitleTextColor
    }
}
