//
//  BaseCollectionFlowLayout.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

class BaseCarouselFlowLayout: UICollectionViewLayout {

    private var chacheIndexPathAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private let itemSize: CGSize = CGSize(width: 163, height: 290)
    private let spacing: CGFloat = 6
    private let focusedSpacing: CGFloat = 6
    
    private var focusIndex: CGFloat {
        guard let collectionView = collectionView else { return 0}
        let contentCollectionOffset: CGFloat = collectionView.bounds.width / 2 + collectionView.contentOffset.x - itemSize.width / 2
        return contentCollectionOffset / (itemSize.width + spacing)
    }
    
    override var collectionViewContentSize: CGSize {
        let leftEdge = chacheIndexPathAttributes.values.map({$0.frame.minX}).min() ?? 0
        let rightEdge = chacheIndexPathAttributes.values.map({$0.frame.maxX}).max() ?? 0
        return CGSize(width: rightEdge - leftEdge, height: itemSize.height)
    }
    
    private func updateInsets() {
        guard let collectionView = collectionView else { return }
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16
    }
    
    override open func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        updateInsets()
        
        guard chacheIndexPathAttributes.isEmpty else { return }
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        
        for item in 0..<itemsCount {
            let indexPath = IndexPath(item: item, section: 0)
            chacheIndexPathAttributes[indexPath] = attributesForItem(at: indexPath)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return chacheIndexPathAttributes
            .map { $0.value}
            .filter { $0.frame.intersects(rect)}
            .map({self.shiftAttributes(from: $0)})
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.size != collectionView?.bounds.size {
            chacheIndexPathAttributes.removeAll()
        }
        return true
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateDataSourceCounts {
            chacheIndexPathAttributes.removeAll()
        }
        super.invalidateLayout(with: context)
    }

    private func attributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.frame.size = itemSize
        attributes.frame.origin.x = CGFloat(indexPath.item) * (itemSize.width + spacing)
        attributes.frame.origin.y = 0
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let attributes = chacheIndexPathAttributes[indexPath] else {
            fatalError()
        }
        return shiftAttributes(from: attributes)
    }
        
    private func shiftAttributes(from attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let attributes = attributes.copy() as? UICollectionViewLayoutAttributes else {
            fatalError()
        }
        
        let roundedFocusedIndex = round(focusIndex)
        
        guard attributes.indexPath.item != Int(roundedFocusedIndex) else {
            return attributes
        }
        
        let shiftArea = (roundedFocusedIndex - 0.5)...(roundedFocusedIndex + 0.5)
        let distanceClosePoint = min(focusIndex - shiftArea.lowerBound, abs(focusIndex - shiftArea.upperBound))
        let shiftFactor = distanceClosePoint * 2
        let translation = (focusedSpacing - spacing) * shiftFactor
        let direction: CGFloat = attributes.indexPath.item < Int(roundedFocusedIndex) ? -1 : 1
        attributes.transform = CGAffineTransform(translationX: direction * translation, y: 0)
        return attributes
    }
    
    private func closeAttributes(position: CGFloat) -> UICollectionViewLayoutAttributes? {
        
        guard let collectionView = collectionView else {
            return nil
        }
        
        let rect = CGRect(x: position - collectionView.bounds.width,
                          y: collectionView.bounds.minY,
                          width: collectionView.bounds.width * 2,
                          height: collectionView.bounds.height)
        return layoutAttributesForElements(in: rect)?.min(by: { abs($0.center.x - position) < abs($1.center.x - position)})
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return
                super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        let midX: CGFloat = collectionView.bounds.size.width / 2
        
        guard let closeAttribute = closeAttributes(position: proposedContentOffset.x + midX) else {
            return
                super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        return CGPoint(x: closeAttribute.center.x - midX, y: proposedContentOffset.y)
    }
}
