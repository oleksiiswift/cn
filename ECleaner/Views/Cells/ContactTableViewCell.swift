//
//  ContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.10.2021.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topShadowView: SectionShadowView!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        
        shhadowImageView.rounded()
        
//        backgroundView = UIView(frame: contentView.frame)
//        backgroundView?.clipsToBounds = false
//        backgroundView?.backgroundColor = .clear
    
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
        topShadowView.backgroundColor = .clear
        baseView.backgroundColor = .clear
        contactTitleTextLabel.textColor = theme.titleTextColor
        contactSubtitleTextLabel.textColor = theme.subTitleTextColor
    }
}


extension UITableView {
    func lastIndexpath() -> IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfRows(inSection: section) - 1, 0)

        return IndexPath(row: row, section: section)
    }
}
