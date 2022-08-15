//
//  EmptyContactListDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 18.11.2021.
//

import Foundation
import UIKit
import Contacts

class EmptyContactListDataSource: NSObject {
    
    public var emptyContactGroupListViewModel: ContactGroupListViewModel
    public var isContactAvailable: ((Bool) -> (Void)) = {_ in}
    public var didSelectContact: ((ContactListViewModel) -> Void) = {_ in}
	public var didSelectViewContactInfo: ((_ contact: CNContact,_ indexPath: IndexPath) -> Void) = {_,_ in}
    public var contactContentIsEditing: Bool = false
    public var contentType: PhotoMediaType = .none
	
	public var delegate: ContactDataSourceDelegate?
    
    init(viewModel: ContactGroupListViewModel, contentType: PhotoMediaType) {
        self.emptyContactGroupListViewModel = viewModel
        self.contentType = contentType
    }
}

extension EmptyContactListDataSource {
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
    
        guard let contact = emptyContactGroupListViewModel.getContact(at: indexPath) else { return }
        cell.contactEditingMode = self.contactContentIsEditing
        cell.updateContactCell(contact, contentType: self.contentType)
    }
	
	private func checkForEditingMode(cell: ContactTableViewCell, at indexPath: IndexPath) {
		
		guard let contact = emptyContactGroupListViewModel.getContactOnRow(at: indexPath) else { return }
		cell.contactEditingMode = self.contactContentIsEditing
		cell.checkForContactsImageDataAndSelectableMode(for: contact)
	}
    
    private func didSelectDeselectContact() {
        U.notificationCenter.post(name: .selectedContactsCountDidChange, object: nil)
    }
	
	private func didSelectViewContactInfo(at indexPath: IndexPath) {
		if let contact = emptyContactGroupListViewModel.getContact(at: indexPath) {
			didSelectViewContactInfo(contact, indexPath)
		}
	}
}

extension EmptyContactListDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.emptyContactGroupListViewModel.numbersOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emptyContactGroupListViewModel.numbersOfRows(at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! ContactTableViewCell
        self.cellConfigure(cell: cell, at: indexPath)
        return cell
    }
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else { return }
		self.checkForEditingMode(cell: cell, at: indexPath)
	}
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return emptyContactGroupListViewModel.setSectionTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = ThemeManager.theme.backgroundColor
        header.contentView.alpha = 0.8
        header.textLabel?.textColor = ThemeManager.theme.sectionTitleTextColor
		header.textLabel?.font = FontManager.contactsFont(of: .headetTitle)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return AppDimensions.ContactsController.Collection.headerHeight
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return AppDimensions.ContactsController.Collection.contactsCellHeight
	}
    
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if contactContentIsEditing {
			if SubscriptionManager.instance.purchasePremiumStatus() == .nonPurchased {
				if tableView.indexPathsForSelectedRows?.count == LimitAccessType.selectAllContacts.selectAllLimit {
					self.delegate?.showEmptyContactsLimitSelectExceededStatus()
					return nil
				} else {
					return indexPath
				}
			} else {
				return indexPath
			}
		} else {
			self.didSelectViewContactInfo(at: indexPath)
			return nil
		}
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.didSelectDeselectContact()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.didSelectDeselectContact()
    }
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
				
		guard !contactContentIsEditing, let contact = emptyContactGroupListViewModel.getContactOnRow(at: indexPath) else { return  nil}
		let identifier = IndexPath(row: indexPath.row, section: indexPath.section) as NSCopying
		let image = self.handleContactImageData(contact)
		
		return UIContextMenuConfiguration(identifier: identifier) {
			return ImagePreviewViewController(item: image)
		} actionProvider: { _ in
			return self.createCellContextMenu(for: contact, at: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		DispatchQueue.main.async {
			if let window = U.application.windows.first {
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UICutoutShadowView") {
					view.isHidden = true
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPortalView") {
					view.rounded()
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.rounded()
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterClippingView") {
					view.rounded()
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.rounded()
				}
			}
		}
	}
}

extension EmptyContactListDataSource {

	func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		
		guard let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else { return nil }
		
		let params = UIPreviewParameters()
		params.backgroundColor = .clear
		let targetPrteview = UITargetedPreview(view: cell.shadowRoundedReuseView.imageView, parameters: params)
		
		return targetPrteview
	}
	
	func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		
		guard let indexPath = configuration.identifier as? IndexPath, let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell  else { return nil }
		let targetPrteview = UITargetedPreview(view: cell.shadowRoundedReuseView.imageView)
		targetPrteview.parameters.backgroundColor = .clear
		return targetPrteview
	}
}

extension EmptyContactListDataSource {
	
	private func handleContactImageData(_ contact: CNContact) -> UIImage {
		
		if contact.imageDataAvailable {
			if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
				return image
			}
		}
		return I.personalisation.contacts.unavailibleThumb
	}

	private func createCellContextMenu(for contactac: CNContact, at indexPath: IndexPath) -> UIMenu {
		let viewActionImage = I.systemElementsItems.person
		let shareActionImage = I.systemElementsItems.share
		let deleteActionImage = I.systemElementsItems.trashBtn
		
		let viewAction = UIAction(title: LocalizationService.Buttons.getButtonTitle(of: .view), image: viewActionImage) { _ in
			self.delegate?.viewContact(at: indexPath)
		}
		
		let shareAction = UIAction(title: LocalizationService.Buttons.getButtonTitle(of: .share), image: shareActionImage) { _ in
			self.delegate?.shareContact(at: indexPath)
		}
		
		let deleteAction = UIAction(title: LocalizationService.Buttons.getButtonTitle(of: .delete), image: deleteActionImage, attributes: .destructive) {_ in
			self.delegate?.deleteContact(at: indexPath)
		}
		
		return UIMenu(title: "", children: [viewAction, shareAction, deleteAction])
	}
}
