////
////  thumb.swift
////  ECleaner
////
////  Created by alexey sorochan on 15.02.2022.
////
//
//import UIKit
//
//extension ThumbnailLayout {
//
//	struct Configuration {
//		let maxAspectRatio: CGFloat = 5
//		let minAspectRatio: CGFloat = 0.2
//		let defaultAspectRatio: CGFloat = 0.5
//
//		let distanceBetween: CGFloat = 4
//		let distanceBetweenFocused: CGFloat = 20
//
//		var expandingRate: CGFloat = 1
//		var updates: [IndexPath: CellUpdate] = [:]
//	}
//}
//
//class ThumbnailLayout: UICollectionViewFlowLayout {
//
//	var config: Configuration
//	var dataSource: ((Int) -> CGFloat)
//	var layoutHandler: LayoutChangeHandler?
//
//	init(dataSource: ((Int) -> CGSize)?, config: Configuration = Configuration()) {
//		self.config = config
//		self.dataSource = { index in
//			dataSource?(index).aspectRatio ?? config.defaultAspectRatio
//		}
//		super.init()
//		scrollDirection = .horizontal
//		minimumInteritemSpacing = 0
//		minimumLineSpacing = 0
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	func changeOffset(relative offset: CGFloat) {
//		collectionView?.contentOffset.x = collectionViewContentSize.width * offset - farInset
//	}
//}
//
//// MARK: - shortcuts
//extension ThumbnailLayout {
//
//	var itemsCount: Int {
//		collectionView?.numberOfItems(inSection: 0) ?? 0
//	}
//
//	var offset: CGPoint {
//		collectionView?.contentOffset ?? .zero
//	}
//
//	var offsetWithoutInsets: CGPoint {
//		CGPoint(x: offset.x + farInset, y: offset.y)
//	}
//
//	var insets: UIEdgeInsets {
//		UIEdgeInsets(top: .zero, left: farInset, bottom: .zero, right: farInset)
//	}
//
//	var farInset: CGFloat {
//		guard let collection = collectionView else { return .zero }
//		return (collection.bounds.width - itemSize.width - config.distanceBetween) / 2
//	}
//
//	var relativeOffset: CGFloat {
//		guard let collection = collectionView else { return .zero }
//		return (collection.contentOffset.x + collection.contentInset.left) / collectionViewContentSize.width
//	}
//
//	var nearestIndex: Int {
//		let offset = relativeOffset
//		let floatingIndex = offset * CGFloat(itemsCount) + 0.5
//		return max(0, min(Int(floor(floatingIndex)), itemsCount - 1))
//	}
//}
//
//// MARK: - UICollectionViewFlowLayout overrides
//extension ThumbnailLayout {
//
//	override func prepare() {
//		super.prepare()
//		if let collectionView = collectionView, let layoutHandler = layoutHandler {
//			if layoutHandler.needsUpdateOffset {
//				let size = CGSize(
//					width: collectionView.bounds.height * config.defaultAspectRatio,
//					height: collectionView.bounds.height)
//				itemSize = size
//				collectionView.contentOffset = targetContentOffset(forProposedContentOffset: offset)
//				collectionView.contentInset = insets
//			}
//		}
//	}
//
//	final override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
//		super.prepare(forCollectionViewUpdates: updateItems)
//		CATransaction.begin()
//		CATransaction.setDisableActions(true)
//	}
//
//	final override func finalizeCollectionViewUpdates() {
//		CATransaction.commit()
//	}
//
//	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//
//		let cells = (0 ..< itemsCount)
//			.map { IndexPath(row: $0, section: 0) }
//			.map { cell(for: $0, offsetX: offsetWithoutInsets.x) }
//			.map { cell -> Cell in
//				if let update = self.config.updates[cell.indexPath] {
//					return update(cell)
//				}
//				return cell
//		}
//		return cells.compactMap { $0.attributes(from: self, with: cells) }
//	}
//
//	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
//									  withScrollingVelocity velocity: CGPoint) -> CGPoint {
//		guard let collection = collectionView else {
//			return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
//											 withScrollingVelocity: velocity)
//		}
//		let cellWithSpacing = itemSize.width + config.distanceBetween
//		let relative = (proposedContentOffset.x + collection.contentInset.left) / cellWithSpacing
//		let leftIndex = max(0, floor(relative))
//		let rightIndex = min(ceil(relative), CGFloat(itemsCount))
//		let leftCenter = leftIndex * cellWithSpacing - collection.contentInset.left
//		let rightCenter = rightIndex * cellWithSpacing - collection.contentInset.left
//
//		if abs(leftCenter - proposedContentOffset.x) < abs(rightCenter - proposedContentOffset.x) {
//			return CGPoint(x: leftCenter, y: proposedContentOffset.y)
//		} else {
//			return CGPoint(x: rightCenter, y: proposedContentOffset.y)
//		}
//	}
//
//	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//		let targetOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
//		guard let layoutHandler = layoutHandler else {
//			return targetOffset
//		}
//		let offset = CGFloat(layoutHandler.targetIndex) / CGFloat(itemsCount)
//		return CGPoint(
//			x: collectionViewContentSize.width * offset - farInset,
//			y: targetOffset.y)
//	}
//
//	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//		return true
//	}
//
//	override var collectionViewContentSize: CGSize {
//		let width = CGFloat(itemsCount) * (itemSize.width + config.distanceBetween)
//		return CGSize(width: width, height: itemSize.height)
//	}
//}
//
//// MARK: - private
//private extension ThumbnailLayout {
//
//	func cell(for index: IndexPath, offsetX: CGFloat) -> Cell {
//
//		let cell = Cell(
//			indexPath: index,
//			dims: Cell.Dimensions(
//				defaultSize: itemSize,
//				aspectRatio: dataSource(index.row),
//				inset: config.distanceBetween,
//				insetAsExpanded: config.distanceBetweenFocused),
//			state: .default)
//
//		guard let attribute = cell.attributes(from: self, with: []) else { return cell }
//
//		let cellOffset = attribute.center.x - itemSize.width / 2
//		let widthWithOffset = itemSize.width + config.distanceBetween
//		if abs(cellOffset - offsetX) < widthWithOffset {
//			let expanding = 1 - abs(cellOffset - offsetX) / widthWithOffset
//			return cell.updated(by: .expand(expanding * config.expandingRate))
//		}
//		return cell
//	}
//}
//
//internal func+<T>(lhs: @escaping (T) -> T,
//				  rhs: ((T) -> T)?) -> (T) -> T {
//	return { lhs(rhs?($0) ?? $0) }
//}
//
//extension ThumbnailLayout {
//
//	typealias CellUpdate = (Cell) -> Cell
//
//	enum UpdateType {
//		case expand(CGFloat)
//		case collapse(CGFloat)
//		case delete(CGFloat, Cell.Direction)
//
//		var closure: CellUpdate {
//			return { $0.updated(by: self) }
//		}
//	}
//}
//
//// MARK: - updates api
//extension ThumbnailLayout.Cell {
//
//	func updated(by update: ThumbnailLayout.UpdateType) -> ThumbnailLayout.Cell {
//		switch update {
//		case .collapse(let rate):
//			return updated(new: state.collapsed(by: rate))
//		case .expand(let rate):
//			return updated(new: state.expanded(by: rate))
//		case .delete(let rate, let direction):
//			return updated(new: state.deleting(by: rate, with: direction))
//		}
//	}
//}
//
//// MARK: - builders
//private extension ThumbnailLayout.Cell.State {
//	typealias State = ThumbnailLayout.Cell.State
//
//	func expanded(by rate: CGFloat) -> State {
//		return State(
//			expanding: rate,
//			collapsing: collapsing,
//			deleting: deleting,
//			deletingDirection: deletingDirection)
//	}
//
//	func collapsed(by rate: CGFloat) -> State {
//		return State(
//			expanding: expanding,
//			collapsing: rate,
//			deleting: deleting,
//			deletingDirection: deletingDirection)
//	}
//
//	func deleting(by rate: CGFloat,
//				  with direction: ThumbnailLayout.Cell.Direction) -> State {
//		return State(
//			expanding: expanding,
//			collapsing: collapsing,
//			deleting: rate,
//			deletingDirection: direction)
//	}
//}
//
//
//extension ThumbnailLayout {
//	struct Cell {
//		let indexPath: IndexPath
//
//		let dims: Dimensions
//		let state: State
//
//		func updated(new state: State) -> Cell {
//			return Cell(indexPath: indexPath, dims: dims, state: state)
//		}
//	}
//}
//
//extension ThumbnailLayout.Cell {
//
//	enum Direction {
//		case left
//		case right
//
//		var inversed: Direction {
//			self == .left ? .right : .left
//		}
//	}
//
//	struct Dimensions {
//		let defaultSize: CGSize
//		let aspectRatio: CGFloat
//		let inset: CGFloat
//		let insetAsExpanded: CGFloat
//	}
//
//	struct State {
//		let expanding: CGFloat
//		let collapsing: CGFloat
//		let deleting: CGFloat
//		let deletingDirection: Direction
//
//		static fileprivate var `default`: State {
//			State(expanding: .zero, collapsing: .zero, deleting: .zero, deletingDirection: .left)
//		}
//	}
//}
//
//// MARK: - layout attributes creation
//extension ThumbnailLayout.Cell {
//
//	func attributes(from layout: ThumbnailLayout,
//					with sideCells: [ThumbnailLayout.Cell]) -> UICollectionViewLayoutAttributes? {
//		let attributes = layout.layoutAttributesForItem(at: indexPath)
//
//		attributes?.size = size
//		attributes?.alpha = 1 - state.collapsing
//		attributes?.center = center
//
//		let translate = sideCells.reduce(0) { (current, cell) -> CGFloat in
//			if indexPath < cell.indexPath {
//				return current - cell.leftShift
//			}
//			if indexPath > cell.indexPath {
//				return current + cell.rightShift
//			}
//			return current
//		}
////		attributes?.transform = CGAffineTransform(translationX: translate, y: .zero)
//
//		return attributes
//	}
//}
//
//// MARK: - geometry utils
//private extension ThumbnailLayout.Cell {
//
//	var additionalWidth: CGFloat {
//		(dims.defaultSize.height * dims.aspectRatio - dims.defaultSize.width) * state.expanding
//	}
//
//	func shift(from direction: ThumbnailLayout.Cell.Direction) -> CGFloat {
//		let symmetricShift = (additionalWidth + dims.insetAsExpanded * state.expanding) / 2 * (1 - state.deleting)
//
//		switch direction {
//		case .left:
//			return symmetricShift
//		case .right:
//			return symmetricShift - dims.defaultSize.width * state.deleting
//		}
//	}
//
//	var size: CGSize {
//		return CGSize(width: 200, height: 200)
////		CGSize(width: ceil((dims.defaultSize.width + additionalWidth) * (1 - state.collapsing)),
////			   height: dims.defaultSize.height * (1 - state.collapsing))
//	}
//
//	var leftShift: CGFloat {
//		shift(from: state.deletingDirection.inversed)
//	}
//
//	var rightShift: CGFloat {
//		shift(from: state.deletingDirection)
//	}
//
//	var center: CGPoint {
//		CGPoint(x: CGFloat(indexPath.row) * (dims.defaultSize.width + dims.inset) + dims.defaultSize.width / 2,
//				y: dims.defaultSize.height / 2)
//	}
//}
