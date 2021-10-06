//
//  DeepCleanInfoTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import UIKit

class DeepCleanInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var infoTitleTextLabel: UILabel!
    @IBOutlet weak var infoCheckettotalFilesCountTextLabel: UILabel!
    @IBOutlet weak var totalSpaceTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
}

extension DeepCleanInfoTableViewCell {
    
    func setProgress(files count: Int) {
        
        let totalCheckedFilesComponentFont: UIFont = .systemFont(ofSize: 13, weight: .heavy)
        let totolCheckedFilesComponentTextColor: UIColor = currentTheme.subTitleTextColor
        
        let totalCheckedFilesFont: UIFont = .systemFont(ofSize: 16, weight: .bold)
        let totalCheckedFilesColor: UIColor = currentTheme.titleTextColor
        
        let totalFilesAttributes = [NSAttributedString.Key.font: totalCheckedFilesFont, NSAttributedString.Key.foregroundColor: totalCheckedFilesColor]
        let componentChecketAttributes = [NSAttributedString.Key.font: totalCheckedFilesComponentFont, NSAttributedString.Key.foregroundColor: totolCheckedFilesComponentTextColor]
        
        let textTitle = NSMutableAttributedString(string: String(count), attributes: totalFilesAttributes)
        textTitle.append(NSMutableAttributedString(string: " " + "files", attributes: componentChecketAttributes))
        
        infoCheckettotalFilesCountTextLabel.attributedText = textTitle
        totalSpaceTextLabel.text = "100 Gb"
    }
}

extension DeepCleanInfoTableViewCell: Themeble {
    
    func setupUI() {
        
        mainInfoView.setCorner(12)
        
        infoTitleTextLabel.text = "checked"
        infoTitleTextLabel.font = .systemFont(ofSize: 12, weight: .regular)
        totalSpaceTextLabel.font = .systemFont(ofSize: 13, weight: .heavy)
    }
    
    func updateColors() {
        
        mainInfoView.backgroundColor = currentTheme.contentBackgroundColor
        infoTitleTextLabel.textColor = currentTheme.subTitleTextColor
        totalSpaceTextLabel.textColor = currentTheme.subTitleTextColor
    }
}
