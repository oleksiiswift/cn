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
	@IBOutlet weak var deleteSelectedButton: ShadowMultiplyerButton!
	@IBOutlet weak var selectAllButton: ShadowButton!
	
	public var indexPath: IndexPath?
    public var onSelectAll: (() -> Void)?
	public var onDeletteSelected: (() -> Void)?
	
	public var mediaContentType: MediaContentType = .none
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        assetsSelectedCountTextLabel.text = ""
//        selectAllButtonTextLabel.text = "select all"
		deleteSelectedButton.setHelperText(nil)
		currentAssetsDate.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
    }
	
	@IBAction func didTapDeleteSelectedAssetsActionButton(_ sender: Any) {
	
	}
	
    @IBAction func didTapSelectAllActionButton(_ sender: Any) {
        
        onSelectAll?()
    }
}

extension GroupedAssetsReusableHeaderView: Themeble {
    
    public func setupUI() {
		
		let deletedText = "delete selected".uppercased()
		deleteSelectedButton.contentType = mediaContentType
		deleteSelectedButton.setMainButton(text: deletedText, with: mediaContentType.screenAcentTintColor, tintColor: theme.cellBackGroundColor)
		
		deleteSelectedButton.updateColors()
	
		selectAllButton.addImage(mediaContentType.selectedAllImage)
		
		currentAssetsDate.font = .systemFont(ofSize: 14, weight: .bold)
		currentAssetsDate.textColor = theme.helperTitleTextColor
	}
    
    public func setSelectDeselectButton(_ isSelectAll: Bool) {
        
//        self.selectAllButtonTextLabel.text = isSelectAll ? "deselect all" : "select all"
    }
	
	public func changeSelectableAssets(_ count: Int) {
		
		if count == 0 {
			deleteSelectedButton.isEnabled = false
			deleteSelectedButton.setHelperText(String(""))
		} else {
			deleteSelectedButton.isEnabled = true
			deleteSelectedButton.setHelperText(String("\(count)"))
		}
	}
	
	public func setGroupTitle(title: String) {
			
		currentAssetsDate.text = title
	}
    
    public func updateColors() {
        
//        assetsSelectedCountTextLabel.textColor = theme.titleTextColor
//        selectAllButtonTextLabel.textColor = theme.titleTextColor
    }
}
