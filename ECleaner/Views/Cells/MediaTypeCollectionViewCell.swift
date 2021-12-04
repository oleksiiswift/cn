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
    
    private lazy var loadingActivityIndicatorView = UIActivityIndicatorView()

    private var photoManager = PhotoManagerOLD()
    public var mediaTypeCell: MediaContentType = .none
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hideActivityIndicatorAndAddSpace()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
        handleContentSize()
    }
}

extension MediaTypeCollectionViewCell: Themeble {
    
    private func setupUI() {
        
        loadingActivityIndicatorView.color = .red
        loadingActivityIndicatorView.tag = 666
        
        mainView.setCorner(12)
        mediaContentTitleTextLabel.font = UIFont(font: FontManager.robotoBold, size: 18.0)
        mediaContentSubTitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
        mediaSpaceTitleTextLabel.font = UIFont(font: FontManager.robotoMedium, size: 14.0)
    }
    
    public func configureCell(mediaType: MediaContentType, contentCount: Int?, diskSpace: Int64?) {
        
        switch mediaType {
            case .userPhoto:
                self.handleIndicator(diskSpace)
                mediaContentView.imageView.image = I.mainStaticItems.photo
                mediaContentTitleTextLabel.text = "PHOTOS_TITLE".localized()

                if let photosCount = contentCount {
                    mediaContentSubTitleTextLabel.text = String("\(photosCount) \("FILES".localized())")
                } else {
                    mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : "NO CONTENT"
                }
            case .userVideo:
                self.handleIndicator(diskSpace)
                mediaContentView.imageView.image = I.mainStaticItems.video
                mediaContentTitleTextLabel.text = "VIDEOS_TITLE".localized()
                
                if let videosCount = contentCount {
                  mediaContentSubTitleTextLabel.text = String("\(videosCount) \("FILES".localized())")
                } else {
                    mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : "NO CONTENT"
                }
                
            case .userContacts:
                self.handleIndicator(0)
                mediaContentView.imageView.image = I.mainStaticItems.contacts
                mediaContentTitleTextLabel.text = "CONTACTS_TITLE".localized()
        
                if let contactsCount = contentCount {
                    mediaContentSubTitleTextLabel.text = String("\(contactsCount) contacts")
                } else {
                    mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : "NO CONTACTS"
                }
            case .none:
                debugPrint("none")
        }
    }
    
    private func handleIndicator(_ space: Int64?) {
        if space == nil {
            showActivityIndicator()
        } else if space == 0 {
            hideActivityIndicatorAndAddSpace()
        } else {
            hideActivityIndicatorAndShowData()
            mediaSpaceTitleTextLabel.text = String("\(U.getSpaceFromInt(space ?? 0))")
        }
    }
    
    private func showActivityIndicator() {
        
        diskSpaceImageView.isHidden = true
        mediaSpaceTitleTextLabel.isHidden = true
        
        guard !infoSpaceStackView.subviews.contains(where: {$0.tag == 666}) else { return }
        
        loadingActivityIndicatorView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        infoSpaceStackView.addSubview(loadingActivityIndicatorView)
        
        loadingActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: infoSpaceStackView.leadingAnchor).isActive = true
        loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: infoSpaceStackView.trailingAnchor).isActive = true
        loadingActivityIndicatorView.topAnchor.constraint(equalTo: infoSpaceStackView.topAnchor).isActive = true
        loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: infoSpaceStackView.bottomAnchor).isActive = true
        loadingActivityIndicatorView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        loadingActivityIndicatorView.startAnimating()
        infoSpaceStackView.layoutIfNeeded()
    }
    
    private func hideActivityIndicatorAndAddSpace() {
        if infoSpaceStackView.subviews.contains(where: {$0.tag == 666}) {
            loadingActivityIndicatorView.removeFromSuperview()
        }
        diskSpaceImageView.isHidden = true
        mediaSpaceTitleTextLabel.isHidden = true
        addDimmerSpaceClearView()
    }
    
    private func hideActivityIndicatorAndShowData() {
        loadingActivityIndicatorView.removeFromSuperview()
        diskSpaceImageView.isHidden = false
        mediaSpaceTitleTextLabel.isHidden = false
    }
    
    private func addDimmerSpaceClearView() {
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
    }

    private func handleContentSize() {
        
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
    
    func updateColors() {
        
        mainView.backgroundColor = .clear
        mediaContentTitleTextLabel.textColor = theme.titleTextColor
        mediaContentSubTitleTextLabel.textColor = theme.subTitleTextColor
        mediaSpaceTitleTextLabel .textColor = theme.titleTextColor
    }
}
