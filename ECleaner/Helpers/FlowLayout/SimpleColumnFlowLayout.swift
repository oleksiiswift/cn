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
        itemSize = CGSize(width: itemWidth, height: itemHieght)
        
    }
    
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}


class CustomCircularCollectionViewLayout: UICollectionViewLayout {
    
    var itemSize = CGSize(width: 200, height: 150)
    var attributesList = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        
        guard let section = collectionView?.numberOfSections else { return }
        
        for sec in 0...section - 1 {
            
            let itemNo = collectionView?.numberOfItems(inSection: sec) ?? 0
            
            let length = (collectionView!.frame.width - 40)/3
            itemSize = CGSize(width: length, height: length)
            
            attributesList = (0..<itemNo).map { (i) -> UICollectionViewLayoutAttributes in
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: sec))
                
                attributes.size = self.itemSize
                
                var x = CGFloat(i%3)*(itemSize.width+10) + 10
                var y = CGFloat(i/3)*(itemSize.width+10) + 10
                
                if i > 2 {
                    y += (itemSize.width+10)
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
                } else if i == 0 {
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width*2+10, height: itemSize.height*2+10)
                } else {
                    x = itemSize.width*2 + 30
                    if i == 2 {
                        y += itemSize.height + 10
                    }
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
                }
                debugPrint(attributes)
                debugPrint(attributesList)
            return attributes
               
            }
            
            
        }
    }
        
    
    override var collectionViewContentSize : CGSize {
        
        return CGSize(width: collectionView!.bounds.width, height: (itemSize.height + 10)*CGFloat(ceil(Double(collectionView!.numberOfItems(inSection: 0))/3))+(itemSize.height + 20))
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < attributesList.count
        {
            return attributesList[indexPath.section]
        }
        
//        if let index = indexPath(sec)
        return nil
//        return attributesList[indexPath(
        
      
        
    
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
