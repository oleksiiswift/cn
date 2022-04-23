//
//  DeepCleanInfoTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import UIKit

class DeepCleanInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoTotalFilesTextLabel: UILabel!
    @IBOutlet weak var infoTotalFilesTitleLabel: UILabel!
    
    @IBOutlet weak var totalSpaceTextLabel: UILabel!
    @IBOutlet weak var totalSpaceTitleLabel: UILabel!
    
    @IBOutlet weak var progressContainerView: UIView!
    
    var progressRing: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
		totalSpaceTextLabel.isHidden = true
		totalSpaceTitleLabel.isHidden = true
        setupUI()
        updateColors()
    }
}

extension DeepCleanInfoTableViewCell {
    
    func setProgress(files count: Int) {
        
		let totalCheckedFilesFont: UIFont = .systemFont(ofSize: 18, weight: .bold)
        let totalCheckedFilesColor: UIColor = theme.titleTextColor
        
        let totalFilesAttributes = [NSAttributedString.Key.font: totalCheckedFilesFont, NSAttributedString.Key.foregroundColor: totalCheckedFilesColor]
        
        let textTitle = NSMutableAttributedString(string: String(count), attributes: totalFilesAttributes)
        
        infoTotalFilesTextLabel.attributedText = textTitle
		totalSpaceTitleLabel.text = "after clean".localized().uppercased()
        infoTotalFilesTitleLabel.text = "FILES".localized()
    }
    
	func setRoundedProgress(value: CGFloat, futuredCleaningSpace: Int64?) {
        progressRing.progress = value
		
		if let futuredCleaningSpace = futuredCleaningSpace {
			let stringSpace = U.getSpaceFromInt(futuredCleaningSpace)
			totalSpaceTextLabel.text = stringSpace
		} else {
			totalSpaceTextLabel.text = "0"
		}
    }
}

extension DeepCleanInfoTableViewCell: Themeble {
    
    func setupUI() {

        let xPosition = progressContainerView.center.x
        let yPosition = progressContainerView.center.y
        let position = CGPoint(x: xPosition, y: yPosition)
        
        progressRing = CircularProgressBar(radius: 33,
                                           position: position,
                                           innerTrackColor: UIColor().colorFromHexString("FF845A"),//theme.titleTextColor,
                                           outerTrackColor: theme.progressBackgroundColor,
                                           lineWidth: 13)
        
        progressRing.progressLabel.textColor = UIColor().colorFromHexString("FF845A")//theme.titleTextColor
		progressRing.progressLabel.font = .systemFont(ofSize: 16, weight: .bold)
        progressRing.progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressRing.progressLabel.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 30))
        progressRing.progressLabel.center = position
        progressRing.progressLabel.textAlignment = .center
        
        progressContainerView.layer.addSublayer(progressRing)
        
		infoTotalFilesTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
		totalSpaceTextLabel.font = .systemFont(ofSize: 18, weight: .bold)
		totalSpaceTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func updateColors() {
        
        infoTotalFilesTextLabel.textColor = theme.titleTextColor
        infoTotalFilesTitleLabel.textColor = theme.subTitleTextColor
        totalSpaceTextLabel.textColor = theme.titleTextColor
        totalSpaceTitleLabel.textColor = theme.subTitleTextColor
    }
}
