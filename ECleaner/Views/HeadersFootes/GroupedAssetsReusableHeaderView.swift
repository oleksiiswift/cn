//
//  GroupedAssetsReusableHeaderView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 30.06.2021.
//

import UIKit

class GroupedAssetsReusableHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var baseView: UIView!
	@IBOutlet weak var currentAssetsDate: UILabel!
	@IBOutlet weak var deleteSelectedButton: ShadowButtonWithImage!
	@IBOutlet weak var selectAllButton: ShadowButton!
	
	public var indexPath: IndexPath?
    public var onSelectAll: (() -> Void)?
	public var onDeleteSelected: (() -> Void)?
	
	public var mediaContentType: MediaContentType = .none
    
    override func prepareForReuse() {
        super.prepareForReuse()
		
		currentAssetsDate.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
    }
	
	@IBAction func didTapDeleteSelectedAssetsActionButton(_ sender: ShadowButtonWithImage) {
		onDeleteSelected?()
	}
	
    @IBAction func didTapSelectAllActionButton(_ sender: ShadowButton) {
        onSelectAll?()
    }
}

extension GroupedAssetsReusableHeaderView: Themeble {
    
    public func setupUI() {
		
		let deletedText = "delete selected".uppercased()
		let image = I.systemItems.defaultItems.trashBin
		deleteSelectedButton.contentType = mediaContentType
		selectAllButton.contentType = mediaContentType
		deleteSelectedButton.setMainButton(text: deletedText, image: image)
				
		currentAssetsDate.font = .systemFont(ofSize: 14, weight: .bold)
		currentAssetsDate.textColor = theme.helperTitleTextColor
	}
	
	public func handleSelectableAsstes(to select: Bool) {
		
		let handledImage = !select ? I.systemItems.selectItems.circleMark : I.systemItems.selectItems.roundedCheckMark
		selectAllButton.setImage(handledImage, enabled: select)
	}
	
	public func handleDeleteAssets(to select: Bool) {
		
		deleteSelectedButton.updateColors(for: select)
		deleteSelectedButton.isEnabled = select
	}
	
	public func setGroupDate(_ date: Date?) {
			
		if let date = date {
			let headerTitle = Date().convertDateFormatterFromDate(date: date, format: C.dateFormat.monthDateYear)
			currentAssetsDate.text = headerTitle
		} else {
			currentAssetsDate.text = "-"
		}
	}
    
    public func updateColors() {}
}
