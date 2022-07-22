//
//  ContactsInfoViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import UIKit
import Contacts

class ContactsInfoViewController: UIViewController {

	@IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var closeButton: UIButton!
	
	public var contact: CNContact?
	public var contactViewModel: ContactViewModel!
	public var contactDataSource: ContactDataSource!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		dataSourceSetup()
		tableViewSetup()
		setupUI()
		updateColors()
		setupDelegate()
    }
	
	@IBAction func didTapCloseActionButton(_ sender: Any) {
		self.dismiss(animated: true)
	}
}

extension ContactsInfoViewController {
	
	private func dataSourceSetup() {
		
		if let contact = self.contact {
			
			var sections: [ContactSection] = []
			
			var contactImage: UIImage {
				if contact.imageDataAvailable {
					if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
						return image
					} else {
						return Images.personalisation.contacts.unavailibleThumb
					}
				} else {
					return Images.personalisation.contacts.unavailibleThumb
				}
			}
			
			let thumbnailBlank: ContactModel = .thumbnailImageData(contactImage)
			let thumbnailSection = ContactSection(contactModelFields: [thumbnailBlank], headerTitle: Localization.empty, headerHeight: 200)
			   sections.append(thumbnailSection)
			
			let fullName = CNContactFormatter.string(from: contact, style: .fullName)
			let modelName: ContactModel = .fullName(fullName ?? "empty name")
			let nameSection = ContactSection(contactModelFields: [modelName], headerTitle: "contact localized name", headerHeight: 60)
			sections.append(nameSection)
			
			if !contact.phoneNumbers.isEmpty {
			
				let phoneNumbers: [ContactModel] = contact.phoneNumbers.map({.phoneNumbers($0)})
				let phoneSection = ContactSection(contactModelFields: phoneNumbers, headerTitle: "phone numbers", headerHeight: 60)
				sections.append(phoneSection)
			}
			
			if !contact.emailAddresses.isEmpty {
				let emails: [ContactModel] = contact.emailAddresses.map({.emailAddresses($0)})
				let emailSection = ContactSection(contactModelFields: emails, headerTitle: "emails", headerHeight: 60)
				sections.append(emailSection)
			}
			
			if !contact.urlAddresses.isEmpty {
				let urls: [ContactModel] = contact.urlAddresses.map({.urlAddresses($0)})
				let urlsSection = ContactSection(contactModelFields: urls, headerTitle: "urls", headerHeight: 60)
				sections.append(urlsSection)
			}
			
			self.contactViewModel = ContactViewModel(contactSection: sections)
			self.contactDataSource = ContactDataSource(viewModel: self.contactViewModel)
			
		} else {
			self.dismiss(animated: true) {
				debugPrint("Show Error Alert")
			}
		}
	}
}

extension ContactsInfoViewController {
	
	private func tableViewSetup() {
		
		self.tableView.register(UINib(nibName: Constants.identifiers.xibs.contactThumbnail, bundle: nil), forCellReuseIdentifier: Constants.identifiers.cells.contactThumbnail)
		
		self.tableView.register(UINib(nibName: Constants.identifiers.xibs.contactInfo, bundle: nil), forCellReuseIdentifier: Constants.identifiers.cells.contactInfo)
		
		self.tableView.delegate = self.contactDataSource
		self.tableView.dataSource = self.contactDataSource
		
		self.tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
		
		if #available(iOS 15.0, *) {
			self.tableView.sectionHeaderTopPadding = 0
		}
		
		self.tableView.separatorStyle = .none
		let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
		view.backgroundColor = .clear
		self.tableView.tableHeaderView = view
	}
}


extension ContactsInfoViewController: Themeble {
	

	private func setupUI() {
		
		closeButton.setImage(Images.systemItems.defaultItems.xmark, for: .normal)
		closeButton.tintColor = theme.contactsTintColor
	}
	
	private func setupDelegate() {
		
	}
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = .clear
	}
}
