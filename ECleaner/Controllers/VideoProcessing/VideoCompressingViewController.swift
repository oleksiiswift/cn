//
//  VideoCompressingViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import UIKit
import Photos

class VideoCompressingViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var navigationBarView: NavigationBar!
	@IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonViewHeightConstraint: NSLayoutConstraint!
	
	public var processingPHAsset: PHAsset?
	public let contentType: MediaContentType = .none
	public let mediaType: PhotoMediaType = .none
	
	private var compressionSettingsViewModel: CompressingSettingsViewModel!
	private var compressionSettingsDataSource: CompressingSettingsDataSource!
	private var compressionConfiguration = VideoCompressionConfig()
	private var currentCompressionModel: ComprssionModel?
	
	private var compressingManager = VideoCompressionManager.insstance
	private var photoManager = PhotoManager.shared
	private var shareManager = ShareManager.shared
	
	private var customFPS: Float = 0
	private var customBitrate: Int = 0
	private var customScale: CGSize = .zero

	private var popGesture: UIGestureRecognizer?
	
	public var updateCollectionWithNewCompressionPHAssets: ((_ updatedPHAssets: [PHAsset]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViewModel()
		setupUI()
		tableViewSetup()
		setupNavigation()
		updateColors()
		delegateSetup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		loadLastUsedSavedCompressedSettings()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
			self.popGesture = navigationController!.interactivePopGestureRecognizer
			self.navigationController!.view.removeGestureRecognizer(navigationController!.interactivePopGestureRecognizer!)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if let gesture = self.popGesture {
			self.navigationController!.view.addGestureRecognizer(gesture)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			case C.identifiers.segue.showCustomCompression:
				self.setupShowCustomCompressionSettingsController(segue: segue)
			default:
				break
		}
	}
}

extension VideoCompressingViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
	
		guard let asset = self.processingPHAsset, let model = self.currentCompressionModel else { return }
		
		U.notificationCenter.post(name: .compressionVideoDidStart, object: nil)
		
		switch model {
			case .custom(fps: _, bitrate: _, scale: _):
				startVideoCompressing(from: asset, with: self.compressionConfiguration)
			default:
				startVideoCompressing(from: asset, with: model)
		}
	}
}

extension VideoCompressingViewController {
	
	private func startVideoCompressing(from asset: PHAsset, with configuration: VideoCompressionConfig) {
		
		P.showIndicator()
		asset.getPhassetURL { responseURL in
			
			guard let url = responseURL else { return }
			
			self.compressingManager.compressVideo(from: url, with: configuration) { result in
				P.hideIndicator()
				switch result {
					case .success(let compressedVideoURL):
						self.compressVideoResultCompleted(with: compressedVideoURL)
					case .failure(let handler):
						handler.showErrorAlert {
							self.navigationController?.popViewController(animated: true)
						}
				}
			}
		}
	}
	
	private func startVideoCompressing(from asset: PHAsset, with compressingModel: ComprssionModel) {
		
		asset.getPhassetURL { responseURL in
			
			guard let url = responseURL else { return }
			
			self.compressingManager.compressVideo(from: url, quality: compressingModel) { result in
				switch result {
					case .success(let compressedVideoURL):
						self.compressVideoResultCompleted(with: compressedVideoURL)
					case .failure(let errorHandler):
						errorHandler.showErrorAlert {
							self.navigationController?.popViewController(animated: true)
						}
				}
			}
		}
	}
	
	private func compressVideoResultCompleted(with url: URL) {
		
		let fileSize = Int64(url.fileSize)
		let stringSize = U.getSpaceFromInt(fileSize)
		
		A.showCompressionVideoFileComplete(fileSize: stringSize) {
			self.shareVideo(with: url)
		} savedInPhotoLibraryCompletionHandler: {
			self.savedVideo(with: url)
		}
	}
	
	private func shareVideo(with url: URL) {
		
		self.shareManager.shareCompressedVideFile(with: url) {
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	private func savedVideo(with url: URL) {
		
		self.photoManager.saveVideoAsset(from: url) { isSaved in
			if isSaved {
				self.showPHAssetCollectionController()
			} else {
				ErrorHandler.shared.showCompressionErrorFor(.errorSavedFile, completion: {})
			}
		}
	}
	
	private func showPHAssetCollectionController() {
		self.photoManager.getVideoCollection { phassets in
			if !phassets.isEmpty {
				self.updateCollectionWithNewCompressionPHAssets?(phassets)
				self.navigationController?.popViewController(animated: true, completion: {
				})
			} else {
				ErrorHandler.shared.showEmptySearchResultsFor(.photoLibraryIsEmpty) {
					self.navigationController?.popViewController(animated: true)
				}
				
			}
		}
	}
}

extension VideoCompressingViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.closeViewController()
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

extension VideoCompressingViewController {
	
	private func setupViewModel() {
		
		guard let phasset = self.processingPHAsset else {
			ErrorHandler.shared.showCompressionErrorFor(.cantLoadFile) {
				self.navigationController?.popViewController(animated: false)
			}
			return
		}
		
		let previewSectionCell = CompressingSection(cells: [.videoPreview], compressingPHAsset: processingPHAsset)
		let settingsSectionsCell = CompressingSection(cells: [.low,
															  .medium,
															  .high,
															  .custom(fps: self.customFPS,
																	  bitrate: self.customBitrate, scale: self.customScale)],
													  headerTitle: "compression settings",
													  headerHeight: 40)
		
		let sections: [CompressingSection] = [previewSectionCell, settingsSectionsCell]
		self.compressionSettingsViewModel = CompressingSettingsViewModel(sections: sections, phasset: phasset)
		self.compressionSettingsDataSource = CompressingSettingsDataSource(compressionSettinsViewModel: self.compressionSettingsViewModel)
		
		if let asset = processingPHAsset {
			self.compressionSettingsDataSource.prefetch(asset)
		}
	}
	
	private func setupCustomConfiguration() {
		
		self.compressionConfiguration = CompressionSettingsConfiguretion.getSavedConfiguration()
	}
	
	private func tableViewSetup() {
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.videoPreivew, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.videoPreviewCell)
	 
		self.tableView.register(UINib(nibName: C.identifiers.xibs.compressionCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.compressionCell)
		
		self.tableView.delegate = self.compressionSettingsDataSource
		self.tableView.dataSource = self.compressionSettingsDataSource
		
		self.tableView.separatorStyle = .none
		self.tableView.allowsMultipleSelection = false
		
		self.tableView.contentInset.top = 0
		self.tableView.contentInset.bottom = 85
		
		
		let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
		view.backgroundColor = .clear
		self.tableView.tableHeaderView = view
	}
	
	private func loadLastUsedSavedCompressedSettings() {
		
		let index = CompressionSettingsConfiguretion.lastSelectedCompressionModel
		self.tableView.selectRow(at: IndexPath(row: index, section: 1), animated: false, scrollPosition: .none)
		
		switch index {
			case 0:
				self.currentCompressionModel = .low
			case 1:
				self.currentCompressionModel = .medium
			case 2:
				self.currentCompressionModel = .high
			case 3:
				self.currentCompressionModel = .custom(fps: 0, bitrate: 0, scale: .zero)
			default:
				return
		}
	}
}

extension VideoCompressingViewController: CompressionSettingsActionsDelegate {
	
	func setCompressionSettingsForValue(with model: ComprssionModel) {
		
		CompressionSettingsConfiguretion.lastSelectedCompressionModel = model.selectedIndex
		
		switch model {
			case .custom(fps: _, bitrate: _, scale: _):
				self.openCustomSettingsViewController()
			default:
				self.currentCompressionModel = model
		}
	}
	
	private func openCustomSettingsViewController() {
		performSegue(withIdentifier: C.identifiers.segue.showCustomCompression, sender: self)
	}
}

extension VideoCompressingViewController {
	
	private func closeViewController() {
		
		self.navigationController?.popViewController(animated: true)
	}
	
	private func setupShowCustomCompressionSettingsController(segue: UIStoryboardSegue) {
		
		guard let segue = segue as? ShowVideoCompressionCustomSettingsSelectorViewControllerSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: true)
		segue.interactiveHide = true
		
		segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
		segue.messageView.configureNoDropShadow()
		
		if let customSettingViewController = segue.destination as? VideoCompressionCustomSettingsViewController {
			customSettingViewController.asset = self.processingPHAsset
			customSettingViewController.selectVideoCompressingConfig = { config in
				self.compressionConfiguration = config
				self.currentCompressionModel = .custom(fps: 0, bitrate: 0, scale: .zero)
			}
		}
	}
}

extension VideoCompressingViewController: Themeble {
	
	private func setupUI() {
		
		bottomButtonBarView.title("compress")
		bottomButtonBarView.setImage(I.systemItems.defaultItems.compress, with: CGSize(width: 24, height: 22))
		
		self.bottomButtonViewHeightConstraint.constant = 75 + U.bottomSafeAreaHeight
	}
	
	private func setupNavigation() {
		
		navigationBarView.setupNavigation(title: "compressing video",
										  leftBarButtonImage: I.systemItems.navigationBarItems.back,
										  rightBarButtonImage: nil, contentType: .none, leftButtonTitle: nil, rightButtonTitle: nil)
		
	}
	
	private func delegateSetup() {
		
		navigationBarView.delegate = self
		bottomButtonBarView.delegate = self
		compressionSettingsDataSource.delegate = self
	}

	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = .clear
		self.bottomButtonBarView.backgroundColor = .clear
		
		bottomButtonBarView.buttonColor = contentType.screenAcentTintColor
		bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonBarView.activityIndicatorColor = theme.backgroundColor
		bottomButtonBarView.updateColorsSettings()
	}
}














