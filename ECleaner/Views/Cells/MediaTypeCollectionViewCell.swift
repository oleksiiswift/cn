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
	
	private lazy var loadingActivityIndicatorView = UIActivityIndicatorView()
	private lazy var circleprogress = CircleProgressView()
	
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
		setupProgressBar()
    }
}

extension MediaTypeCollectionViewCell: Themeble {
    
    private func setupUI() {
        
        loadingActivityIndicatorView.color = .red
        loadingActivityIndicatorView.tag = 666
        mainView.setCorner(12)
    }
    
	public func configureCell(mediaType: MediaContentType, contentCount: Int?, diskSpace: Int64?) {
        
		self.mediaTypeCell = mediaType
		self.mediaContentTitleTextLabel.text = mediaType.mediaContentTypeName
		
        switch mediaType {
            case .userPhoto:
				if PhotoLibraryPermissions().status == .authorized {
					if diskSpace != nil {
						self.handleIndicator(diskSpace)
					} else if S.phassetPhotoFilesSizes != nil {
						self.handleIndicator(S.phassetPhotoFilesSizes)
					} else {
						self.handleIndicator(nil)
					}
					self.mediaContentView.imageView.image = mediaType.mediaContenTypeImage
					
					if let photosCount = contentCount {
						self.mediaContentSubTitleTextLabel.text = String("\(photosCount) \(Localization.Main.ProcessingState.ByGrouping.files.uppercased())")
					} else {
						self.mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : Localization.Main.ProcessingState.ByEmptyState.noContent.uppercased()
					}
				} else {
					self.deniedModeForContect(type: mediaType)
				}
            case .userVideo:
				if PhotoLibraryPermissions().status == .authorized {
					if diskSpace != nil {
						self.handleIndicator(diskSpace)
					} else if S.phassetVideoFilesSizes != nil {
						self.handleIndicator(S.phassetVideoFilesSizes)
					} else {
						self.handleIndicator(nil)
					}
					self.mediaContentView.imageView.image = mediaType.mediaContenTypeImage
					
					if let videosCount = contentCount {
						self.mediaContentSubTitleTextLabel.text = String("\(videosCount) \(Localization.Main.ProcessingState.ByGrouping.files.uppercased())")
					} else {
						self.mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : Localization.Main.ProcessingState.ByEmptyState.noContent.uppercased()
					}
				} else {
					self.deniedModeForContect(type: mediaType)
				}
            case .userContacts:
				if ContactsPermissions().status == .authorized {
					self.handleIndicator(0)
					self.mediaContentView.imageView.image = mediaType.mediaContenTypeImage
					
					if let contactsCount = contentCount {
						self.mediaContentSubTitleTextLabel.text = String("\(contactsCount) \(Localization.Main.ProcessingState.ByGrouping.contacts.uppercased())")
					} else {
						self.mediaContentSubTitleTextLabel.text = contentCount == nil ? "" : Localization.Main.ProcessingState.ByEmptyState.noContacts.uppercased()
					}
				} else {
					self.deniedModeForContect(type: mediaType)
				}
            case .none:
                debugPrint("none")
        }
		
		circleprogress.startColor = mediaTypeCell.screeAcentGradientUICoror.first!
		circleprogress.endColor = mediaTypeCell.screeAcentGradientUICoror.last!
		circleprogress.gradientSetup(startPoint: CAGradientPoint.topLeft.point,
									 endPoint: CAGradientPoint.bottomRight.point,
									 gradientType: .axial)
    }
	
	private func deniedModeForContect(type: MediaContentType) {
		
		self.handleIndicator(0)
		
		let image = Utils.Manager().grayscaleImage(image: type.mediaContenTypeImage)
		self.self.mediaContentView.imageView.image = image
		self.mediaContentSubTitleTextLabel.text = Localization.Permission.Subtitle.denied
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
		U.animate(1) {
			self.circleprogress.isHidden = !(0.01...0.99).contains(progress)
		}

		guard self.circleprogress.progress < progress else { return }
			self.circleprogress.setProgress(progress: progress, animated: false)
			self.circleprogress.layoutIfNeeded()
	}
	
	private func setupProgressBar() {
		
		mainView.addSubview(circleprogress)
		circleprogress.translatesAutoresizingMaskIntoConstraints = false
		circleprogress.leadingAnchor.constraint(equalTo: mediaContentView.leadingAnchor, constant: -3).isActive = true
		circleprogress.trailingAnchor.constraint(equalTo: mediaContentView.trailingAnchor, constant: 3).isActive = true
		circleprogress.topAnchor.constraint(equalTo: mediaContentView.topAnchor, constant: -3).isActive = true
		circleprogress.bottomAnchor.constraint(equalTo: mediaContentView.bottomAnchor, constant: 3).isActive = true
		
		circleprogress.isHidden = true
		circleprogress.disableBackgrounShadow = true
		circleprogress.lineWidth = 2
		circleprogress.backgroundShapeColor = .clear
		circleprogress.startColor = mediaTypeCell.screeAcentGradientUICoror.first!
		circleprogress.endColor = mediaTypeCell.screeAcentGradientUICoror.last!
		circleprogress.percentLabel.isHidden = true
		circleprogress.alpha = 0.7
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
		circleprogress.isHidden = true
    }
    
    private func hideActivityIndicatorAndShowData() {
        loadingActivityIndicatorView.removeFromSuperview()
        diskSpaceImageView.isHidden = false
        mediaSpaceTitleTextLabel.isHidden = false
		circleprogress.isHidden = true
    }
	
	private func hideActivityIndicatorAndShowProgress() {
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
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 12, weight: .bold).monospacedDigitFont
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 10, weight: .medium).monospacedDigitFont
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 10, weight: .medium).monospacedDigitFont
			case .medium:
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 17, weight: .bold).monospacedDigitFont
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 13, weight: .medium).monospacedDigitFont
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 13, weight: .medium).monospacedDigitFont
			default:
				mediaContentTitleTextLabel.font = .systemFont(ofSize: 18, weight: .bold).monospacedDigitFont
				mediaContentSubTitleTextLabel.font = .systemFont(ofSize: 14, weight: .medium).monospacedDigitFont
				mediaSpaceTitleTextLabel.font = .systemFont(ofSize: 14, weight: .medium).monospacedDigitFont
		}
	}
    
    func updateColors() {
        
        mainView.backgroundColor = .clear
        mediaContentTitleTextLabel.textColor = theme.titleTextColor
        mediaContentSubTitleTextLabel.textColor = theme.subTitleTextColor
        mediaSpaceTitleTextLabel .textColor = theme.titleTextColor
    }
}
