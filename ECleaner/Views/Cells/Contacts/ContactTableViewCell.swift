//
//  ContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.11.2021.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topShadowView: SectionShadowView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var contactTitleTextLabel: UILabel!
    @IBOutlet weak var contactSubtitleTextLabel: UILabel!
    @IBOutlet weak var shadowImageView: ShadowRoundedView!
    @IBOutlet weak var rightShevronImageView: UIImageView!
    
    @IBOutlet weak var topBaseViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBaseViewConstraint: NSLayoutConstraint!
    
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
    }
    
}


extension ContactTableViewCell {
    
    public func updateContactCell(_ contact: CNContact, contentType: PhotoMediaType) {
        
        if contentType == .allContacts {
            contactSubtitleTextLabel.isHidden = true
        }
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
        contactTitleTextLabel.text = contactFullName
        
    }
}


extension ContactTableViewCell: Themeble {
    
    private func setupUI() {}
    
    func updateColors() {}
    
    private func superPrepareForReuse() {
        
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
    }
}
