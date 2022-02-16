//
//  SettingsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var tableView: UITableView!
	
	private var settingsViewModel: SettingsViewModel!
	private var settingsDataSource: SettingsDataSource!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViewModel()
		setupNavigateion()
		setupTableView()
		setupDelegate()
		updateColors()
    }
}

extension SettingsViewController {
	
	private func setupViewModel() {
		
		let firstSectionCells =  SettingsSection(cells: [.premium])
		let secondSectionCells = SettingsSection(cells: [.restore], headetHeight: 40)
		
		let thirdSectionsCells = SettingsSection(cells: [.largeVideos,
														 .dataStorage,
														 .permissions],
												 headerTitle: "settings one sections title",
												 headetHeight: 40)
		
		let fouthSectionsCells = SettingsSection(cells: [.support,
														 .share,
														 .rate,
														 .privacypolicy,
														 .termsOfUse],
												 headerTitle: "settings optional title two",
												 headetHeight: 40)
		
		let sections: [SettingsSection] = [firstSectionCells, secondSectionCells, thirdSectionsCells, fouthSectionsCells]
		
		self.settingsViewModel = SettingsViewModel(sections: sections)
		self.settingsDataSource = SettingsDataSource(settingsViewModel: self.settingsViewModel)
	}
}

extension SettingsViewController {
	
	private func setupNavigateion() {
		
		navigationBar.setupNavigation(title: settingsViewModel.controllerTitle,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: .none,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	private func setupTableView() {
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.bannerCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.helperBannerCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
		
		self.tableView.delegate = settingsDataSource
		self.tableView.dataSource = settingsDataSource
		
		self.tableView.separatorStyle = .none
		let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
		view.backgroundColor = .clear
		self.tableView.tableHeaderView = view
	}
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
	}
}

extension SettingsViewController: Themeble {
	
	func setupUI() {}
	
	func updateColors() {
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = .clear
	}
}

extension SettingsViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}
