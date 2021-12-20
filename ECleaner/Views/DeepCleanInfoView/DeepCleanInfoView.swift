//
//  DeepCleanInfoView.swift
//  DeepCleanInfoView
//
//  Created by iMac_1 on 27.10.2021.
//

import Foundation
import UIKit

class DeepCleanInfoView: UIView {
    
    var className: String {
        return "DeepCleanInfoView"
    }
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var infoTotalFilesTextLabel: UILabel!
    @IBOutlet weak var infoTotalFilesTitleLabel: UILabel!
    
    @IBOutlet weak var freeSpaceTextLabel: UILabel!
    @IBOutlet weak var freeSpaceTitleLabel: UILabel!
    
    @IBOutlet weak var progressContainerView: UIView!
    
    var progressRing: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        
        setupUI()
        updateColors()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.load()
    }
    
    func load() {
        
        Bundle.main.loadNibNamed(self.className, owner: self, options: nil)
    }
    
    func configure() {
        
        containerView.backgroundColor = .clear
        backgroundColor = .clear
        addSubview(self.containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setProgress(files count: Int) {
        
        let totalCheckedFilesFont: UIFont = UIFont(font: FontManager.robotoBold, size: 18.0)!
        let totalCheckedFilesColor: UIColor = theme.titleTextColor
        
        let totalFilesAttributes = [NSAttributedString.Key.font: totalCheckedFilesFont, NSAttributedString.Key.foregroundColor: totalCheckedFilesColor]
        
        let textTitle = NSMutableAttributedString(string: String(count), attributes: totalFilesAttributes)
        
        infoTotalFilesTextLabel.attributedText = textTitle
    }
    
    func setRoundedProgress(value: CGFloat) {
        progressRing.progress = value
    }
    
}

extension DeepCleanInfoView: Themeble {
    
    func setupUI() {
        
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
        
        infoTotalFilesTitleLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)!
        freeSpaceTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)!
        freeSpaceTitleLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)!
        
        infoTotalFilesTitleLabel.text = "SCANNING_FILES".localized()
        freeSpaceTitleLabel.text = "FREE_SPACE".localized()
    }
    
    func updateColors() {
        
        infoTotalFilesTextLabel.textColor = theme.titleTextColor
        infoTotalFilesTitleLabel.textColor = theme.subTitleTextColor
        freeSpaceTextLabel.textColor = theme.titleTextColor
        freeSpaceTitleLabel.textColor = theme.subTitleTextColor
    }
}
