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
    @IBOutlet weak var infoSpaceStackView: UIStackView!
    @IBOutlet weak var diskSpaceImageView: UIImageView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    private var photoManager = PhotoManager()
    public var mediaTypeCell: MediaContentType = .none
    
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
                
                mediaSpaceTitleTextLabel.isHidden = true
                diskSpaceImageView.isHidden = true
                
                let spaceView = UIView()
                spaceView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                infoSpaceStackView.addSubview(spaceView)
                spaceView.translatesAutoresizingMaskIntoConstraints = false
                spaceView.leadingAnchor.constraint(equalTo: infoSpaceStackView.leadingAnchor).isActive = true
                spaceView.trailingAnchor.constraint(equalTo: infoSpaceStackView.trailingAnchor).isActive = true
                spaceView.topAnchor.constraint(equalTo: infoSpaceStackView.topAnchor).isActive = true
                spaceView.bottomAnchor.constraint(equalTo: infoSpaceStackView.bottomAnchor).isActive = true
                spaceView.heightAnchor.constraint(equalToConstant: 25).isActive = true
                infoSpaceStackView.layoutIfNeeded()
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
