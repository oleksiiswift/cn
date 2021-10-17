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
    @IBOutlet weak var progressContainerView: UIView!
    
    var progressRing: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
}

extension DeepCleanInfoTableViewCell {
    
    func setProgress(files count: Int) {
        
        let totalCheckedFilesComponentFont: UIFont = .systemFont(ofSize: 13, weight: .heavy)
        let totolCheckedFilesComponentTextColor: UIColor = theme.subTitleTextColor
        
        let totalCheckedFilesFont: UIFont = .systemFont(ofSize: 16, weight: .bold)
        let totalCheckedFilesColor: UIColor = theme.titleTextColor
        
        let totalFilesAttributes = [NSAttributedString.Key.font: totalCheckedFilesFont, NSAttributedString.Key.foregroundColor: totalCheckedFilesColor]
        let componentChecketAttributes = [NSAttributedString.Key.font: totalCheckedFilesComponentFont, NSAttributedString.Key.foregroundColor: totolCheckedFilesComponentTextColor]
        
        let textTitle = NSMutableAttributedString(string: String(count), attributes: totalFilesAttributes)
        textTitle.append(NSMutableAttributedString(string: " " + "files", attributes: componentChecketAttributes))
        
        infoCheckettotalFilesCountTextLabel.attributedText = textTitle
        totalSpaceTextLabel.text = "100 Gb"
    }
    
    func setRoundedProgress(value: CGFloat) {
        progressRing.progress = value
    }
}

extension DeepCleanInfoTableViewCell: Themeble {
    
    func setupUI() {
        
        mainInfoView.setCorner(12)
        
        infoTitleTextLabel.text = "checked"
        infoTitleTextLabel.font = .systemFont(ofSize: 12, weight: .regular)
        totalSpaceTextLabel.font = .systemFont(ofSize: 13, weight: .heavy)

        let xPosition = progressContainerView.center.x
        let yPosition = progressContainerView.center.y
        let position = CGPoint(x: xPosition, y: yPosition)
        
        progressRing = CircularProgressBar(radius: 30,
                                           position: position,
                                           innerTrackColor: theme.titleTextColor,
                                           outerTrackColor: theme.progressBackgroundColor,
                                           lineWidth: 6)
        
        progressRing.progressLabel.textColor = theme.titleTextColor
        progressRing.progressLabel.font = .systemFont(ofSize: 13, weight: .bold)
        progressRing.progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressRing.progressLabel.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 20))
        progressRing.progressLabel.center = position
        progressRing.progressLabel.textAlignment = .center
        
        progressContainerView.layer.addSublayer(progressRing)
    }
    
    func updateColors() {
        
        mainInfoView.backgroundColor = theme.contentBackgroundColor
        infoTitleTextLabel.textColor = theme.subTitleTextColor
        totalSpaceTextLabel.textColor = theme.subTitleTextColor
    }
}
