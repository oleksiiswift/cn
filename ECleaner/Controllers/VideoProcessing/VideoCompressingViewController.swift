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
	
	private var customFPS: Float = 0
	private var customBitrate: Int = 0
	private var customScale: CGSize = .zero

	private var popGesture: UIGestureRecognizer?

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
	

}

extension VideoCompressingViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		debugPrint("compressVideo with settings")
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
		
		let previewSectionCell = CompressingSection(cells: [.videoPreview], compressingPHAsset: processingPHAsset)
		let settingsSectionsCell = CompressingSection(cells: [.low,
															  .medium,
															  .high,
															  .custom(fps: self.customFPS,
																	  bitrate: self.customBitrate, scale: self.customScale)],
													  headerTitle: "compression settings",
													  headerHeight: 40)
		
		let sections: [CompressingSection] = [previewSectionCell, settingsSectionsCell]
		self.compressionSettingsViewModel = CompressingSettingsViewModel(sections: sections)
		self.compressionSettingsDataSource = CompressingSettingsDataSource(compressionSettinsViewModel: self.compressionSettingsViewModel)
		
		if let asset = processingPHAsset {
			self.compressionSettingsDataSource.prefetch(asset)
		}
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
			self.tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .none)
			self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
	}
}

extension VideoCompressingViewController: CompressionSettingsActionsDelegate {
	
	func setCompressionSettingsForValue(with model: ComprssionModel) {
		switch model {
			case .low:
				self.setCompressionModel(of: .low)
			case .medium:
				self.setCompressionModel(of: .medium)
			case .high:
				self.setCompressionModel(of: .high)
			case .custom(fps: _, bitrate: _, scale: _):
				self.openCustomSettingsViewController()
			default:
				return
		}
	}
	
	private func setCompressionModel(of quality: VideoCompressionQuality) {
		
	}
	
	private func openCustomSettingsViewController() {
		
	}
}

extension VideoCompressingViewController {
	
	private func closeViewController() {
		
		self.navigationController?.popViewController(animated: true)
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











