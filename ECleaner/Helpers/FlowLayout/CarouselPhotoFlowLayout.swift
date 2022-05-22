//
//  CarouselPhotoFlowLayout.swift
//  ECleaner
//
//  Created by alekseii sorochan on 19.07.2021.
//

import UIKit

public enum CarouselFlowLayoutSpacingMode {
	case fixed(spacing: CGFloat)
	case overlap(visibleOffset: CGFloat)
}

open class CarouselFlowLayout: UICollectionViewFlowLayout {
	
	fileprivate struct LayoutState {
		var size: CGSize
		var direction: UICollectionView.ScrollDirection
		func isEqual(_ otherState: LayoutState) -> Bool {
			return self.size.equalTo(otherState.size) && self.direction == otherState.direction
		}
	}
	
	@IBInspectable open var sideItemScale: CGFloat = 0.85
	@IBInspectable open var sideItemAlpha: CGFloat = 1.0
	@IBInspectable open var sideItemShift: CGFloat = 1.0
	
	open var spacingMode = CarouselFlowLayoutSpacingMode.fixed(spacing: 0)
	
	fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)
	
	override open func prepare() {
		super.prepare()
		let currentState = LayoutState(size: self.collectionView!.bounds.size, direction: self.scrollDirection)
		
		if !self.state.isEqual(currentState) {
			self.setupCollectionView()
			self.updateLayout()
			self.state = currentState
		}
	}
	
	fileprivate func setupCollectionView() {
		guard let collectionView = self.collectionView else { return }
		if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
			collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		}
	}
	
	fileprivate func updateLayout() {
		guard let collectionView = self.collectionView else { return }
		
		let collectionSize = collectionView.bounds.size
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let yInset = (collectionSize.height - self.itemSize.height) / 2
		let xInset = (collectionSize.width - self.itemSize.width) / 2
		self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
			
		let side = isHorizontal ? self.itemSize.width : self.itemSize.height
		let scaledItemOffset =  (side - side*self.sideItemScale) / 2
		switch self.spacingMode {
		case .fixed(let spacing):
			self.minimumLineSpacing = spacing - scaledItemOffset
		case .overlap(let visibleOffset):
			let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
			let inset = isHorizontal ? xInset : yInset
			self.minimumLineSpacing = inset - fullSizeSideItemOverlap
		}
	}
	
	override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
	override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let superAttributes = super.layoutAttributesForElements(in: rect),
			let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
			else { return nil }
		return attributes.map({ self.transformLayoutAttributes($0) })
	}
	
	

	
	fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		guard let collectionView = self.collectionView else { return attributes }
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let collectionCenter = isHorizontal ? collectionView.frame.size.width / 2 : collectionView.frame.size.height / 2
		let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
		let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
		
		let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
		let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
		let ratio = (maxDistance - distance)/maxDistance
		
		let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
		let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
		let shift = (1 - ratio) * self.sideItemShift
		attributes.alpha = alpha
		attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
		attributes.zIndex = Int(alpha * 10)
		
		if isHorizontal {
			attributes.center.y = attributes.center.y + shift
		} else {
			attributes.center.x = attributes.center.x + shift
		}
		
		return attributes
	}
	
	override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView , !collectionView.isPagingEnabled,
			let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
			else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
		
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
		let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
		
		var targetContentOffset: CGPoint
		if isHorizontal {
			let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
		}
		else {
			let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
		}
		
		return targetContentOffset
	}
}


open class PreviewCarouselFlowLayout: UICollectionViewFlowLayout {
	
	fileprivate struct LayoutState {
		var size: CGSize
		var direction: UICollectionView.ScrollDirection
		func isEqual(_ otherState: LayoutState) -> Bool {
			return self.size.equalTo(otherState.size) && self.direction == otherState.direction
		}
	}
	
	@IBInspectable open var sideItemScale: CGFloat = 1.0
	@IBInspectable open var sideItemAlpha: CGFloat = 1.0
	@IBInspectable open var sideItemShift: CGFloat = 1.0
	open var spacingMode = CarouselFlowLayoutSpacingMode.fixed(spacing: 5)
	
	fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)
	
	override open func prepare() {
		super.prepare()
		let currentState = LayoutState(size: self.collectionView!.bounds.size, direction: self.scrollDirection)
		
		if !self.state.isEqual(currentState) {
			self.setupCollectionView()
			self.updateLayout()
			self.state = currentState
		}
	}
	
	fileprivate func setupCollectionView() {
		guard let collectionView = self.collectionView else { return }
		if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
			collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		}
	}
	
	fileprivate func updateLayout() {
		guard let collectionView = self.collectionView else { return }
		
		let collectionSize = collectionView.bounds.size
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let yInset = (collectionSize.height - self.itemSize.height) / 2
		let xInset = (collectionSize.width - self.itemSize.width) / 2
//		self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
		self.sectionInset = UIEdgeInsets.init(top: yInset, left: 20, bottom: yInset, right: 0)
		
		
		let side = isHorizontal ? self.itemSize.width : self.itemSize.height
		let scaledItemOffset =  (side - side*self.sideItemScale) / 2
		switch self.spacingMode {
		case .fixed(let spacing):
			self.minimumLineSpacing = spacing - scaledItemOffset
		case .overlap(let visibleOffset):
			let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
			let inset = isHorizontal ? xInset : yInset
			self.minimumLineSpacing = inset - fullSizeSideItemOverlap
		}
	}
	
	override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
	override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let superAttributes = super.layoutAttributesForElements(in: rect),
			let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
			else { return nil }
		return attributes.map({ self.transformLayoutAttributes($0) })
	}
	
	fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		guard let collectionView = self.collectionView else { return attributes }
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let collectionCenter = isHorizontal ? collectionView.frame.size.width / 2 : collectionView.frame.size.height / 2
		let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
		let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
		
		let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
		let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
		let ratio = (maxDistance - distance)/maxDistance
		
		let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
		let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
		let shift = (1 - ratio) * self.sideItemShift
		attributes.alpha = alpha
		attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
		attributes.zIndex = Int(alpha * 10)
		
		if isHorizontal {
			attributes.center.y = attributes.center.y + shift
		} else {
			attributes.center.x = attributes.center.x + shift
		}
		
		return attributes
	}
	
	override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView , !collectionView.isPagingEnabled,
			let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
			else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
		
		let isHorizontal = (self.scrollDirection == .horizontal)
		
		let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
		let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
		
		var targetContentOffset: CGPoint
		if isHorizontal {
			let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
		}
		else {
			let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
		}
		
		return targetContentOffset
	}
}




class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    let activeDistance: CGFloat = 20
    var zoomFactor: CGFloat = 0.0

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 40
        itemSize = CGSize(width: 300, height: 160)
		sectionFootersPinToVisibleBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance

            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
