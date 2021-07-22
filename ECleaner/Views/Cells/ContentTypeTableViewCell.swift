//
//  ContentTypeTableViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos

class ContentTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    @IBOutlet weak var selectedAssetsImageView: UIImageView!
    
    @IBOutlet weak var contentTypeTextLabel: UILabel!
    @IBOutlet weak var contentSubtitleTextLabel: UILabel!
    @IBOutlet weak var selectedContainerWidthConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentTypeTextLabel.text = nil
        contentSubtitleTextLabel.text = nil
        selectedAssetsImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellUI()
        updateColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension ContentTypeTableViewCell {
    
    /**
     - `cellConfig`use for default cell config
     - `setupCellSelected` use in deep cleaning part for show selected checkmark for clean
    */
    
    public func cellConfig(contentType: MediaContentType, indexPath: IndexPath, phasetCount: Int) {
        
        contentTypeTextLabel.text = contentType.getCellTitle(index: indexPath.row)
        
        switch contentType {
            case .userPhoto:
                contentSubtitleTextLabel.text = phasetCount != 0 ? String("\(phasetCount) files") : ""
            case .userVideo:
                contentSubtitleTextLabel.text = phasetCount != 0 ? String("\(phasetCount) files") : ""
            case .userContacts:
                contentSubtitleTextLabel.text = ""
            case .none:
                contentSubtitleTextLabel.text = ""
        }
    }

    public func setupCellSelected(at indexPath: IndexPath, isSelected: Bool) {
        
        selectedContainerWidthConstraint.constant = 50
    }
}

extension ContentTypeTableViewCell: Themeble {
    
    func setupCellUI() {
        
        selectionStyle = .none
        
        baseView.setCorner(12)
        contentTypeTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        contentSubtitleTextLabel.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    func updateColors() {
        baseView.backgroundColor = currentTheme.contentBackgroundColor
        contentTypeTextLabel.textColor = currentTheme.titleTextColor
        contentSubtitleTextLabel.textColor = currentTheme.subTitleTextColor
    }
}
