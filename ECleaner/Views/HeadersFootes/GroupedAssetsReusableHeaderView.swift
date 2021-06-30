//
//  GroupedAssetsReusableHeaderView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 30.06.2021.
//

import UIKit

class GroupedAssetsReusableHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var assetsSelectedCountTextLabel: UILabel!
    @IBOutlet weak var selectAllButtonTextLabel: UILabel!
    
    public var onSelectAll: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        assetsSelectedCountTextLabel.text = ""
        selectAllButtonTextLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
    
    @IBAction func didTapSelectAllActionButton(_ sender: Any) {
        onSelectAll?()
    }
}

extension GroupedAssetsReusableHeaderView: Themeble {
    
    private func setupUI() {}
    
    public func setSelectDeselectButton(_ isSelectAll: Bool) {
        selectAllButtonTextLabel.text = isSelectAll ? "select all" : "deselect all"
    }
    
    public func updateColors() {
        
        assetsSelectedCountTextLabel.textColor = currentTheme.titleTextColor
        selectAllButtonTextLabel.textColor = currentTheme.titleTextColor
    }
}
