//
//  MediaTypeCollectionViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

enum MediaContentType {
    case userPhoto
    case userVideo
    case userContacts
    case none
}

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
        
        photoManager.delegate = self
        setupUI()
        updateColors()
    }
}

extension MediaTypeCollectionViewCell: PhotoManagerDelegate {
    
    func getPhotoLibraryCount(count: Int) {
        if mediaTypeCell == .userPhoto {
            mediaContentSubTitleTextLabel.text = String("\(count) photo + size")
        }
    }
    
    func getVideoCount(count: Int) {
        if mediaTypeCell == .userVideo {
            mediaContentSubTitleTextLabel.text = String("\(count) video + size")
        }
    }
}

extension MediaTypeCollectionViewCell: Themeble {

    private func setupUI() {
        
        
        mainView.setCorner(12)
        mediaContentTitleTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
        mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    public func configureCell(mediaType: MediaContentType) {
        
        #warning("LOCO add localization in future")
        switch mediaType {
            case .userPhoto:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.photo
                mediaContentTitleTextLabel.text = "Photo"
                mediaContentSubTitleTextLabel.text = "calculate count photo and GB"
            case .userVideo:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.video
                mediaContentTitleTextLabel.text = "Video"
                mediaContentSubTitleTextLabel.text = "calculate video count and GB"
                
            case .userContacts:
                mediaContentThumbnailImageView.image = I.mainMenuThumbItems.contacts
                mediaContentTitleTextLabel.text = "Contacts"
                mediaContentSubTitleTextLabel.text = "count calculate"
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
