//
//  DropDownMenuTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 05.07.2021.
//

import UIKit

class DropDownMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var menuTitileTextLabel: UILabel!
    
    lazy var simpleSeparatorView = UIView()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
}

extension DropDownMenuTableViewCell {
    
    public func configure(with menuItem: MenuItem, row position: RowPosition) {
        
        thumbnailImageView.image = menuItem.thumbnail
        menuTitileTextLabel.text = menuItem.title
        menuTitileTextLabel.font = menuItem.titleFont
        
        if position != .bottom {
            setupSeparatorView()
        }
		
		menuTitileTextLabel.alpha = menuItem.selected ? 1 : 0.5
		thumbnailImageView.alpha = menuItem.selected ? 1 : 0.5
    }
    
    private func setupSeparatorView() {
        
        self.baseView.addSubview(simpleSeparatorView)
        simpleSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        simpleSeparatorView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20).isActive = true
        simpleSeparatorView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 0).isActive = true
        simpleSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        simpleSeparatorView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 0).isActive = true
    }
}

extension DropDownMenuTableViewCell: Themeble {
    
    private func setupUI() {
        
        selectionStyle = .none
    }
    
    func updateColors() {
        
        menuTitileTextLabel.textColor = theme.titleTextColor
        thumbnailImageView.tintColor = theme.titleTextColor
        simpleSeparatorView.backgroundColor = theme.separatorMainColor
    }
}
