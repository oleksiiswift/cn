//
//  SimpleColumnFlowLayout.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit

class SimpleColumnFlowLayout: UICollectionViewFlowLayout {
    
    var cellsPerRow: Int
    var itemHieght: CGFloat = 100
    var isSquare: Bool = false
    
    init(cellsPerRow: Int, minimumInterSpacing: CGFloat, minimumLineSpacing: CGFloat, inset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        
        super.init()
        
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumLineSpacing
        self.sectionInset = inset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let margInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - margInsets) / CGFloat(cellsPerRow).rounded(.down))
        if isSquare {
            itemSize = CGSize(width: itemWidth, height: itemWidth)
        } else {
            itemSize = CGSize(width: itemWidth, height: itemHieght)
        }
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
