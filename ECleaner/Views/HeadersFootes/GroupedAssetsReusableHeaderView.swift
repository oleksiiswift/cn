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
        
//        assetsSelectedCountTextLabel.text = ""
//        selectAllButtonTextLabel.text = "select all"
		
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
	

    
//    public func setSelectDeselectButton(_ isSelectAll: Bool) {
//        
////        self.selectAllButtonTextLabel.text = isSelectAll ? "deselect all" : "select all"
//		
//    }
	
//	public func changeSelectableAssets(to select: Bool) {
//		
//		deleteSelectedButton.updateColors(for: select)
//		
//		if !select {
//			deleteSelectedButton.isEnabled = false
//			selectAllButton.setImage(I.systemItems.selectItems.circleMark, enabled: false)
//			
//		} else {
//			deleteSelectedButton.isEnabled = true
//			selectAllButton.setImage(I.systemItems.selectItems.roundedCheckMark, enabled: true)
//		}
//	}
//	
	
	public func handleSelectableAsstes(to select: Bool) {
		
		let handledImage = !select ? I.systemItems.selectItems.circleMark : I.systemItems.selectItems.roundedCheckMark
		selectAllButton.setImage(handledImage, enabled: select)
	}
	
	public func handleDeleteAssets(to select: Bool) {
		
		deleteSelectedButton.updateColors(for: select)
		deleteSelectedButton.isEnabled = select
	}
	
	
	
	public func setGroupTitle(title: String) {
			
		currentAssetsDate.text = title
	}
    
    public func updateColors() {
        
//        assetsSelectedCountTextLabel.textColor = theme.titleTextColor
//        selectAllButtonTextLabel.textColor = theme.titleTextColor
    }
}
