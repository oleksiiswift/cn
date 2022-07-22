//
//  ContactDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import UIKit

class ContactDataSource: NSObject {
	
	private var contactViewModel: ContactViewModel
	
	init(viewModel: ContactViewModel) {
		self.contactViewModel = viewModel
	}
}

extension ContactDataSource {
	
	private func configureThumbnail(_ cell: ContactThumbnailTableViewCell, at indexPath: IndexPath) {
		
		let field = self.contactViewModel.getContactModel(at: indexPath)
		cell.configureCell(with: field)
	}
	
	private func configure(_ cell: ContactInfoTableViewCell, at indexPath: IndexPath) {
		
		let field = self.contactViewModel.getContactModel(at: indexPath)
		cell.configure(model: field)
	}
}

extension ContactDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.contactViewModel.numberOfSections()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.contactViewModel.numberOfRows(in: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.cells.contactThumbnail, for: indexPath) as! ContactThumbnailTableViewCell
				self.configureThumbnail(cell, at: indexPath)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.cells.contactInfo, for: indexPath) as! ContactInfoTableViewCell
				self.configure(cell, at: indexPath)
				return cell
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.contactViewModel.getHeaderTitle(in: section)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = ThemeManager.theme.backgroundColor
		header.contentView.alpha = 0.8
		header.textLabel?.textColor = ThemeManager.theme.sectionTitleTextColor
		header.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.contactViewModel.getHeightForRow(at: indexPath)
	}
}
