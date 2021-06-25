//
//  MediaTypeCollectionViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

class MediaTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mediaContentThumbnailImageView: UIImageView!
    @IBOutlet weak var mediaContentImageView: UIImageView!
    @IBOutlet weak var mediaContentTitleTextLabel: UILabel!
    @IBOutlet weak var mediaContentSubTitleTextLabel: UILabel!
    
    private var photoManager = PhotoManager()
    public var mediaTypeCell: MediaContentType = .none
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mediaContentImageView.image = nil
        mediaContentThumbnailImageView.image = nil
        mediaContentTitleTextLabel.text = nil
        mediaContentSubTitleTextLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
}

extension MediaTypeCollectionViewCell: Themeble {

    private func setupUI() {
        
        mainView.setCorner(12)
        mediaContentTitleTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
        mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    public func configureCell(mediaType: MediaContentType, contentCount: Int?, diskSpace: Int64?) {
        
        #warning("LOCO add localization in future")
        switch mediaType {
            case .userPhoto:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.photo
                mediaContentTitleTextLabel.text = "Photo"
                
                if let photosCount = contentCount, let space = diskSpace {
                    let spaceMessage = space != 0 ? String("• \(U.getSpaceFromInt(space))") : "• calculated"
                    mediaContentSubTitleTextLabel.text = String("\(photosCount) files \(spaceMessage)")
                } else {
                    mediaContentSubTitleTextLabel.text = "no content"
                }
            case .userVideo:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.video
                mediaContentTitleTextLabel.text = "Video"
                if let videosCount = contentCount, let space = diskSpace {
                    let spaceMessage = space != 0 ? String("• \(U.getSpaceFromInt(space))") : "• calculated"
                    mediaContentSubTitleTextLabel.text = String("\(videosCount) files \(spaceMessage)")
                } else {
                    mediaContentSubTitleTextLabel.text = "no content"
                }
                
            case .userContacts:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.contacts
                mediaContentTitleTextLabel.text = "Contacts"
                if let contactsCount = contentCount {
                    mediaContentSubTitleTextLabel.text = String("\(contactsCount) contacts")
                } else {
                    mediaContentSubTitleTextLabel.text = "no contacts"
                }
            case .none:
                debugPrint("none")
        }
    }
    
    func updateColors() {
        
        mainView.backgroundColor = currentTheme.contentBackgroundColor
        mediaContentThumbnailImageView.tintColor = currentTheme.tintColor
        mediaContentTitleTextLabel.textColor = currentTheme.titleTextColor
        mediaContentSubTitleTextLabel.textColor = currentTheme.subTitleTextColor
    }
}
