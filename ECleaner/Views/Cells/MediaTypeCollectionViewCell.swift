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
	@IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var horizontalProgressBar: HorizontalProgressBar!
	
	private lazy var loadingActivityIndicatorView = UIActivityIndicatorView()

	private var photoManager = PhotoManager.shared
    public var mediaTypeCell: MediaContentType = .none
	
	private var spaceViewIndicatorSize: CGSize {
		switch Screen.size {
			case .small:
				return CGSize(width: 15, height: 15)
			default:
				return CGSize(width: 25, height: 25)
		}
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hideActivityIndicatorAndAddSpace()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
        handleContentSize()
		horizontalProgressBar.isHidden = true
		horizontalProgressBar.progress = 0
		horizontalProgressBar.setNeedsDisplay()
		setupProgressBar()
    }
}

extension MediaTypeCollectionViewCell: Themeble {
    
    private func setupUI() {
        
        loadingActivityIndicatorView.color = .red
        loadingActivityIndicatorView.tag = 666
		horizontalProgressBar.direction = .vertical
        mainView.setCorner(12)
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
	
	public func setProgress(_ progress: CGFloat) {
		
//		horizontalProgressBar.isHidden = progress == 0 || progress > 0.95
//		horizontalProgressBar.state = progress != 0 || progress < 0.95 ? .progress : .sleeping
//		self.horizontalProgressBar.progress = progress
//		self.horizontalProgressBar.layoutIfNeeded()
	}
	
	private func setupProgressBar() {
		self.horizontalProgressBar.setCorner(12)
//		self.horizontalProgressBar.alpha = 
	}
    
    private func showActivityIndicator() {
        
        diskSpaceImageView.isHidden = true
        mediaSpaceTitleTextLabel.isHidden = true
        
        guard !infoSpaceStackView.subviews.contains(where: {$0.tag == 666}) else { return }
        
		loadingActivityIndicatorView.frame = CGRect(origin: .zero, size: spaceViewIndicatorSize)
		
        infoSpaceStackView.addSubview(loadingActivityIndicatorView)
        
        loadingActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingActivityIndicatorView.leadingAnchor.constraint(equalTo: infoSpaceStackView.leadingAnchor).isActive = true
        loadingActivityIndicatorView.trailingAnchor.constraint(equalTo: infoSpaceStackView.trailingAnchor).isActive = true
        loadingActivityIndicatorView.topAnchor.constraint(equalTo: infoSpaceStackView.topAnchor).isActive = true
        loadingActivityIndicatorView.bottomAnchor.constraint(equalTo: infoSpaceStackView.bottomAnchor).isActive = true
		loadingActivityIndicatorView.heightAnchor.constraint(equalToConstant: spaceViewIndicatorSize.width).isActive = true
		
		Screen.size == .small ? loadingActivityIndicatorView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) : ()
		
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
		spaceView.frame = CGRect(origin: .zero, size: spaceViewIndicatorSize)
        infoSpaceStackView.addSubview(spaceView)
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        spaceView.leadingAnchor.constraint(equalTo: infoSpaceStackView.leadingAnchor).isActive = true
        spaceView.trailingAnchor.constraint(equalTo: infoSpaceStackView.trailingAnchor).isActive = true
        spaceView.topAnchor.constraint(equalTo: infoSpaceStackView.topAnchor).isActive = true
        spaceView.bottomAnchor.constraint(equalTo: infoSpaceStackView.bottomAnchor).isActive = true
		spaceView.heightAnchor.constraint(equalToConstant: spaceViewIndicatorSize.width).isActive = true
        infoSpaceStackView.layoutIfNeeded()
    }

	private func handleContentSize() {
		
		switch Screen.size {
			case .small:
				mainStackView.spacing = 8
			case .medium:
				mainStackView.spacing = 11
			case .plus:
				mainStackView.spacing = 12
			case .large:
				mainStackView.spacing = 14
			case .modern:
				mainStackView.spacing = 16
			case .max:
				mainStackView.spacing = 18
			case .madMax:
				mainStackView.spacing = 20
		}
		
		switch Screen.size {
			case .small:
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 12, weight: .bold)
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
			case .medium:
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 13, weight: .medium)
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 13, weight: .medium)
			default:
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 18, weight: .bold)
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 14, weight: .medium)
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 14, weight: .medium)
		}
	}
    
    func updateColors() {
        
        mainView.backgroundColor = .clear
        mediaContentTitleTextLabel.textColor = theme.titleTextColor
        mediaContentSubTitleTextLabel.textColor = theme.subTitleTextColor
        mediaSpaceTitleTextLabel .textColor = theme.titleTextColor
		horizontalProgressBar.progressColor = theme.progressBackgroundColor
    }
}
