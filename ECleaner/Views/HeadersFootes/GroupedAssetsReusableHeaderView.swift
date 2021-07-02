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
        self.selectAllButtonTextLabel.text = isSelectAll ? "deselect all" : "select all"
        self.baseView.backgroundColor = isSelectAll ? .red : .black
    }
    
    public func updateColors() {
        
        assetsSelectedCountTextLabel.textColor = currentTheme.titleTextColor
        selectAllButtonTextLabel.textColor = currentTheme.titleTextColor
    }
}

extension GroupedAssetsReusableHeaderView: GroupedReusebleListener {
    
    func setSelectAllButtonState(index: Int, isSelectAllState: Bool) {
        debugPrint(index)
        self.setSelectDeselectButton(isSelectAllState)
    }
}
