//
//  MediaTypeCollectionViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

class MediaTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: ShadowView!
    @IBOutlet weak var mediaContentView: ShadowRoundedView!
    @IBOutlet weak var mediaContentTitleTextLabel: UILabel!
    @IBOutlet weak var mediaContentSubTitleTextLabel: UILabel!
    @IBOutlet weak var mediaSpaceTitleTextLabel: UILabel!
  
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    private var photoManager = PhotoManager()
    public var mediaTypeCell: MediaContentType = .none
  
  var imV = ShadowRoundedView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mediaContentTitleTextLabel.text = nil
        mediaContentSubTitleTextLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
      
      switch Screen.size {
        case .small:
          debugPrint("")

        case .medium:
          debugPrint("")
          
        case .plus:
          debugPrint("")
          contentViewHeightConstraint.constant = 200
        case .large:
          debugPrint("")
          contentViewHeightConstraint.constant = 200
        case .modern:
          debugPrint("")
          contentViewHeightConstraint.constant = 200
        case .max:
          debugPrint("")
        case .madMax:
          debugPrint("")
      }
    }
}

extension MediaTypeCollectionViewCell: Themeble {

    private func setupUI() {
        
        mainView.setCorner(12)
        mediaContentTitleTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        mediaContentSubTitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
        mediaSpaceTitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
    }
    
    public func configureCell(mediaType: MediaContentType, contentCount: Int?, diskSpace: Int64?) {
        
        #warning("LOCO add localization in future")
        switch mediaType {
            case .userPhoto:
                mediaContentView.imageView.image = I.mainMenuThumbItems.photo
                mediaContentTitleTextLabel.text = "PHOTOS_TITLE".localized()
                
                if let photosCount = contentCount, let space = diskSpace {
                    let spaceMessage = space != 0 ? String("\(U.getSpaceFromInt(space))") : "calculate"
                    mediaContentSubTitleTextLabel.text = String("\(photosCount) \("FILES".localized())")
                    mediaSpaceTitleTextLabel.text = String("\(spaceMessage)")
                } else {
                    mediaContentSubTitleTextLabel.text = "NO CONTENT"
                }
            case .userVideo:
                mediaContentView.imageView.image = I.mainMenuThumbItems.video
                mediaContentTitleTextLabel.text = "VIDEOS_TITLE".localized()
                if let videosCount = contentCount, let space = diskSpace {
                    let spaceMessage = space != 0 ? String("\(U.getSpaceFromInt(space))") : "calculate"
                  mediaContentSubTitleTextLabel.text = String("\(videosCount) \("FILES".localized())")
                    mediaSpaceTitleTextLabel.text = String("\(spaceMessage)")
                } else {
                    mediaContentSubTitleTextLabel.text = "NO CONTENT"
                }
                
            case .userContacts:
                mediaContentView.imageView.image = I.mainMenuThumbItems.contacts
                mediaContentTitleTextLabel.text = "CONTACTS_TITLE".localized()
                if let contactsCount = contentCount {
                    mediaContentSubTitleTextLabel.text = String("\(contactsCount) contacts")
                } else {
                    mediaContentSubTitleTextLabel.text = "O CONTACTS"
                }
            case .none:
                debugPrint("none")
        }
    }
    
    func updateColors() {
        
        mainView.backgroundColor = .clear
        mediaContentTitleTextLabel.textColor = theme.titleTextColor
        mediaContentSubTitleTextLabel.textColor = theme.subTitleTextColor
        mediaSpaceTitleTextLabel .textColor = theme.titleTextColor
    }
}
