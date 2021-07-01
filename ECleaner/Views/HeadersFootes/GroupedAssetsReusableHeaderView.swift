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
    
    private func setupUI() {
        
        GroupedReusebleMediator.instance.setListener(listener: self)
    }
    
    public func setSelectDeselectButton(_ isSelectAll: Bool) {
        selectAllButtonTextLabel.text = isSelectAll ? "select all" : "deselect all"
    }
    
    public func updateColors() {
        
        assetsSelectedCountTextLabel.textColor = currentTheme.titleTextColor
        selectAllButtonTextLabel.textColor = currentTheme.titleTextColor
    }
}

extension GroupedAssetsReusableHeaderView: GroupedReusebleListener {
    
    func setSelectAllButtonState(index: Int, isSelectAllState: Bool) {
        
        if self.tag == index {
            
            self.setSelectDeselectButton(isSelectAllState)
        }
    }
}
