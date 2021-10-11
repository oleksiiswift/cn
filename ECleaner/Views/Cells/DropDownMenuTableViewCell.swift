//
//  DropDownMenuTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 05.07.2021.
//

import UIKit

class DropDownMenuTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var menuTitileTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension DropDownMenuTableViewCell {
    
    public func configure(with menuItem: DropDownOptionsMenuItem) {
        
        thumbnailImageView.image = menuItem.itemThumbnail
        menuTitileTextLabel.text = menuItem.titleMenu
        menuTitileTextLabel.font = menuItem.titleFont
    }
}

extension DropDownMenuTableViewCell: Themeble {
    
    private func setupUI() {
        
        selectionStyle = .none
    }
    
    func updateColors() {
        
        menuTitileTextLabel.textColor = theme.titleTextColor
        thumbnailImageView.tintColor = theme.tintColor
    }
}
