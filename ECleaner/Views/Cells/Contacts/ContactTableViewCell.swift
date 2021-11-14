//
//  ContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.11.2021.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {

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
        
    }
}


extension ContactTableViewCell: Themeble {
    
    private func setupUI() {
        
    }
    
    
    func updateColors() {
        
    }
}
