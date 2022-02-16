////
////  CellBlock 52.swift
////  ECleaner
////
////  Created by alexey sorochan on 03.11.2021.
////
//
//import Foundation
//import UIKit
//import SnapKit
//import AVFoundation
////extension ContactsManagerOLD {
////
//////    use only with know country
////    func phonesValidatibg(_ contact: CNContact) -> Int {
////
////        let numbers = contact.phoneNumbers.compactMap( { phoneNumber -> String? in
////            guard let label = phoneNumber.label else { return nil}
////            return phoneNumber.value.stringValue
////        })
////        let phoneNumbers = self.phoneNumberKit.parse(numbers, ignoreType: true, shouldReturnFailedEmptyNumbers: false)
////
////        return phoneNumbers.count
////    }
////}
//
//
////extension ContactsManagerOLD {
////    
////    
////    func mergeAllDuplicates(_ duplicates: [CNContact]) -> CNContact {
////        
////        var givenName: [String] = []
////        var familyName: [String] = []
////        var organizationName: [String] = []
////        var notes: [String] = []
////        
////        var phoneNumbers: [CNLabeledValue<CNPhoneNumber>] = []
////        var emailAddresses: [CNLabeledValue<NSString>] = []
////        var postalAddresses: [CNLabeledValue<CNPostalAddress>] = []
////        var urlAddresses: [CNLabeledValue<NSString>] = []
////        
////        
////        for contact in duplicates {
////            givenName.append(contact.givenName)
////            familyName.append(contact.familyName)
////            organizationName.append(contact.organizationName)
////            notes.append(contact.note)
////            
////            contact.phoneNumbers.forEach { phoneNumbers.append($0) }
////            contact.emailAddresses.forEach { emailAddresses.append($0) }
////            contact.postalAddresses.forEach { postalAddresses.append($0) }
////            contact.urlAddresses.forEach { urlAddresses.append($0) }
////        }
////        
////        let newContact = CNMutableContact()
////        newContact.givenName = givenName.bestElement ?? ""
////        newContact.familyName = familyName.bestElement ?? ""
////        newContact.organizationName = organizationName.bestElement ?? ""
////        newContact.note = notes.joined(separator: "\n")
////        
////        newContact.phoneNumbers = phoneNumbers
////        newContact.emailAddresses = emailAddresses
////        newContact.postalAddresses = postalAddresses
////        newContact.urlAddresses = urlAddresses
////        
////        return newContact
////    }
////}
//
//
////extension ContactsManagerOLD {
////
////    public func specialContacts() {
////        
////        
////        lazy var contacts: [CNContact] = {
////            let contactStore = CNContactStore()
//////            let keysToFetch = [
//////                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
//////                CNContactEmailAddressesKey,
//////                CNContactPhoneNumbersKey,
//////                CNContactImageDataAvailableKey,
//////                CNContactThumbnailImageDataKey] as [Any]
////            // Get all the containers
////            var allContainers: [CNContainer] = []
////            do {
////                allContainers = try contactStore.containers(matching: nil)
////            } catch {
////                print("Error fetching containers")
////            }
////
////            var results: [CNContact] = []
////
////            // Iterate all containers and append their contacts to our results array
////            for container in allContainers {
////                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
////
////                do {
////                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
////                    results.append(contentsOf: containerResults)
////                } catch {
////                    print("Error fetching results for container")
////                }
////            }
////
////            return results
////        }()
////        
////        
////        
////        debugPrint(contacts)
////    }
////}
//
//class CompareImage {
//
//    /// Value in range 0...100 %
//    typealias Percentage = Float
//
//    // See: https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
//    public func compare(tolerance: Percentage, expected: Data, observed: Data) -> Bool {
//        guard let expectedUIImage = UIImage(data: expected), let observedUIImage = UIImage(data: observed) else {
//            return false
//        }
//        guard let expectedCGImage = expectedUIImage.cgImage, let observedCGImage = observedUIImage.cgImage else {
//            return false
//        }
//        guard let expectedColorSpace = expectedCGImage.colorSpace, let observedColorSpace = observedCGImage.colorSpace else {
//            return false
//        }
//        if expectedCGImage.width != observedCGImage.width || expectedCGImage.height != observedCGImage.height {
//            return false
//        }
//        let imageSize = CGSize(width: expectedCGImage.width, height: expectedCGImage.height)
//        let numberOfPixels = Int(imageSize.width * imageSize.height)
//
//        // Checking that our `UInt32` buffer has same number of bytes as image has.
//        let bytesPerRow = min(expectedCGImage.bytesPerRow, observedCGImage.bytesPerRow)
//        assert(MemoryLayout<UInt32>.stride == bytesPerRow / Int(imageSize.width))
//
//        let expectedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
//        let observedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
//
//        let expectedPixelsRaw = UnsafeMutableRawPointer(expectedPixels)
//        let observedPixelsRaw = UnsafeMutableRawPointer(observedPixels)
//
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        guard let expectedContext = CGContext(data: expectedPixelsRaw, width: Int(imageSize.width), height: Int(imageSize.height),
//                                              bitsPerComponent: expectedCGImage.bitsPerComponent, bytesPerRow: bytesPerRow,
//                                              space: expectedColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
//            expectedPixels.deallocate()
//            observedPixels.deallocate()
//            return false
//        }
//        guard let observedContext = CGContext(data: observedPixelsRaw, width: Int(imageSize.width), height: Int(imageSize.height),
//                                              bitsPerComponent: observedCGImage.bitsPerComponent, bytesPerRow: bytesPerRow,
//                                              space: observedColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
//            expectedPixels.deallocate()
//            observedPixels.deallocate()
//            return false
//        }
//
//        expectedContext.draw(expectedCGImage, in: CGRect(origin: .zero, size: imageSize))
//        observedContext.draw(observedCGImage, in: CGRect(origin: .zero, size: imageSize))
//
//        let expectedBuffer = UnsafeBufferPointer(start: expectedPixels, count: numberOfPixels)
//        let observedBuffer = UnsafeBufferPointer(start: observedPixels, count: numberOfPixels)
//
//        var isEqual = true
//        if tolerance == 0 {
//            isEqual = expectedBuffer.elementsEqual(observedBuffer)
//        } else {
//            // Go through each pixel in turn and see if it is different
//            var numDiffPixels = 0
//            for pixel in 0 ..< numberOfPixels where expectedBuffer[pixel] != observedBuffer[pixel] {
//                // If this pixel is different, increment the pixel diff count and see if we have hit our limit.
//                numDiffPixels += 1
//                let percentage = 100 * Float(numDiffPixels) / Float(numberOfPixels)
//                if percentage > tolerance {
//                    isEqual = false
//                    break
//                }
//            }
//        }
//
//        expectedPixels.deallocate()
//        observedPixels.deallocate()
//
//        return isEqual
//    }
//}
//
//class Animator {
//	var currentProgress: CGFloat = 0
//
//	fileprivate var displayLink: CADisplayLink?
//	fileprivate var fromProgress: CGFloat = 0
//	fileprivate var toProgress: CGFloat = 0
//	fileprivate var startTimeInterval: TimeInterval = 0
//	fileprivate var endTimeInterval: TimeInterval = 0
//
//	fileprivate var completion: ((Bool) -> Void)?
//	fileprivate let onProgress: (CGFloat, CGFloat) -> Void
//	fileprivate let timing: (CGFloat) -> (CGFloat)
//
//	required init(onProgress: @escaping (CGFloat, CGFloat) -> Void,
//				  easing: Easing<CGFloat> = .linear) {
//
//		self.currentProgress = .zero
//		self.onProgress = onProgress
//		self.timing = easing.function
//	}
//}
//
//// MARK: - ThumbnailFlowLayout.ModeAnimator impl
//extension Animator {
//
//	func animate(duration: TimeInterval, completion: ((Bool) -> Void)?) {
//		if displayLink != nil {
//			self.completion?(false)
//		}
//		self.completion = completion
//		fromProgress = currentProgress
//		toProgress = 1
//		startTimeInterval = CACurrentMediaTime()
//		endTimeInterval = startTimeInterval + duration * TimeInterval(abs(toProgress - fromProgress))
//
//		displayLink?.invalidate()
//		displayLink = CADisplayLink(target: self, selector: #selector(onProgressChanged(link:)))
//		displayLink?.add(to: .main, forMode: .common)
//	}
//
//	func cancel() {
//		if displayLink != nil {
//			self.completion?(false)
//		}
//		displayLink?.invalidate()
//		displayLink = nil
//	}
//}
//
//// MARK: - progress updating timer handler
//extension Animator {
//	@objc func onProgressChanged(link: CADisplayLink) {
//		let currentTime = CACurrentMediaTime()
//		var currentProgress = CGFloat((currentTime - startTimeInterval) / (endTimeInterval - startTimeInterval))
//
//		currentProgress = min(1, currentProgress)
//
//		let tick = timing(currentProgress) - timing(self.currentProgress)
//		self.currentProgress = fromProgress + (toProgress - fromProgress) * currentProgress
//
//		onProgress(timing(self.currentProgress), tick)
//
//		if self.currentProgress >= 1 {
//			displayLink?.invalidate()
//			displayLink = nil
//			completion?(true)
//		}
//	}
//}
//
//class DeleteAnimation: NSObject {
//	let preview: PreviewLayout
//	let thumbnails: ThumbnailLayout
//	let indexPath: IndexPath
//
//	init(thumbnails: ThumbnailLayout, preview: PreviewLayout, index: IndexPath) {
//		self.preview = preview
//		self.thumbnails = thumbnails
//		self.indexPath = index
//		super.init()
//	}
//
//	func run(with completion: @escaping () -> Void) {
//
//		let collapse = Animator(onProgress: { current, _ in
//			self.collapseItem(at: self.indexPath, with: current)
//		})
//
//		collapse.animate(duration: 0.15) { _ in
//
//			let delete = Animator(onProgress: { current, _ in
//				self.deleteItem(at: self.indexPath, with: current)
//			})
//
//			delete.animate(duration: 0.15) { _ in
//				self.thumbnails.config.updates = [:]
//				completion()
//			}
//		}
//	}
//}
//
//private extension DeleteAnimation {
//
//	func collapseItem(at indexPath: IndexPath, with rate: CGFloat) {
//		let update: ThumbnailLayout.UpdateType = .collapse(rate)
//		let previousUpdate = thumbnails.config.updates[indexPath]
//		thumbnails.config.updates[indexPath] = update.closure + previousUpdate
//		thumbnails.invalidateLayout()
//	}
//
//	func deleteItem(at indexPath: IndexPath, with rate: CGFloat) {
//		guard let collectionView = thumbnails.collectionView else { return }
//
//		let direction = { () -> ThumbnailLayout.Cell.Direction in
//			if indexPath.row + 1 >= collectionView.numberOfItems(inSection: 0) {
//				return .left
//			} else {
//				return .right
//			}
//		}()
//
//		let expandingIndexPath = { () -> IndexPath in
//			switch direction {
//			case .left:
//				return IndexPath(row: indexPath.row - 1, section: 0)
//			case .right:
//				return IndexPath(row: indexPath.row + 1, section: 0)
//			}
//		}()
//		deleteItem(at: indexPath, with: rate, expandingIndexPath: expandingIndexPath, animationDirection: direction)
//	}
//
//	func deleteItem(at indexPath: IndexPath,
//					with rate: CGFloat,
//					expandingIndexPath: IndexPath,
//					animationDirection: ThumbnailLayout.Cell.Direction) {
//
//		let delete: ThumbnailLayout.UpdateType = .delete(rate, animationDirection)
//		let expand: ThumbnailLayout.UpdateType = .expand(rate)
//
//		zip([indexPath, expandingIndexPath], [delete, expand]).forEach { index, update in
//			let previousUpdate = thumbnails.config.updates[index]
//			thumbnails.config.updates[index] = update.closure + previousUpdate
//		}
//		self.thumbnails.invalidateLayout()
//	}
//}
//
//class MoveAnimation: NSObject {
//	let preview: PreviewLayout
//	let thumbnails: ThumbnailLayout
//	let indexPath: IndexPath
//
//	init(thumbnails: ThumbnailLayout, preview: PreviewLayout, index: IndexPath) {
//		self.preview = preview
//		self.thumbnails = thumbnails
//		self.indexPath = index
//		super.init()
//	}
//
//	func run(with completion: @escaping () -> Void) {
//		guard let collectionView = thumbnails.collectionView else { return }
//		let fromOffset = collectionView.contentOffset.x
//		let floatIndex = CGFloat(indexPath.row)
//		let cellWithInsetsWidth = thumbnails.itemSize.width + thumbnails.config.distanceBetween
//		let toOffset = floatIndex * cellWithInsetsWidth - thumbnails.farInset
//
//		let fromIndex = IndexPath(row: thumbnails.nearestIndex, section: 0)
//
//		preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//		thumbnails.config.expandingRate = .zero
//		let animator = Animator(onProgress: { current, _ in
//			let offset = fromOffset + (toOffset - fromOffset) * current
//			collectionView.contentOffset.x = offset
//
//			self.thumbnails.config.updates[self.indexPath] = {
//				$0.updated(by: .expand(current))
//			}
//			self.thumbnails.config.updates[fromIndex] = {
//				$0.updated(by: .expand(1 - current))
//			}
//		}, easing: .easeInOut)
//
//		animator.animate(duration: 0.3) { _ in
//			self.thumbnails.config.expandingRate = 1
//			self.thumbnails.config.updates.removeValue(forKey: self.indexPath)
//			self.thumbnails.config.updates.removeValue(forKey: fromIndex)
//			completion()
//		}
//	}
//}
//class ScrollAnimation: NSObject {
//	let preview: PreviewLayout
//	let thumbnails: ThumbnailLayout
//	let type: Type
//
//	init(thumbnails: ThumbnailLayout, preview: PreviewLayout, type: Type) {
//		self.preview = preview
//		self.thumbnails = thumbnails
//		self.type = type
//		super.init()
//	}
//
//	func run(completion: @escaping () -> Void) {
//		let toValue: CGFloat = self.type == .beign ? 0 : 1
//		let currentExpanding = thumbnails.config.expandingRate
//		let duration = TimeInterval(0.15 * abs(currentExpanding - toValue))
//
//		let animator = Animator(onProgress: { current, _ in
//			let rate = currentExpanding + (toValue - currentExpanding) * current
//			self.thumbnails.config.expandingRate = rate
//			self.thumbnails.invalidateLayout()
//		}, easing: .easeInOut)
//
//		animator.animate(duration: duration) { _ in
//			completion()
//		}
//	}
//}
//
//extension ScrollAnimation {
//
//	enum `Type` {
//		case beign
//		case end
//	}
//}
//
//
//class ThumbnailCollectionViewCell: UICollectionViewCell & ImageCell {
//
//	private(set) var imageView = UIImageView()
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		setupUI()
//		createConstraints()
//		imageView.contentMode = .scaleAspectFill
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//}
//
//
//class PreviewCollectionViewCell: UICollectionViewCell & ImageCell {
//
//	private(set) var imageView = UIImageView()
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		setupUI()
//		createConstraints()
//		imageView.contentMode = .scaleAspectFit
//	}
//
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		guard let imageSize = imageView.image?.size else { return }
//		let imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
//
//		let path = UIBezierPath(rect: imageRect)
//		let shapeLayer = CAShapeLayer()
//		shapeLayer.path = path.cgPath
//		layer.mask = shapeLayer
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//		guard let attrs = layoutAttributes as? ParallaxLayoutAttributes else {
//			return super.apply(layoutAttributes)
//		}
//		let parallaxValue = attrs.parallaxValue ?? 0
//		let transition = -(bounds.width * 0.3 * parallaxValue)
//		imageView.transform = CGAffineTransform(translationX: transition, y: .zero)
//	}
//}
//
//
//protocol ImageCell: UICollectionViewCell, SnapView {
//	var imageView: UIImageView { get }
//}
//
//extension ImageCell {
//	func createConstraints() {
//		imageView.snp.makeConstraints {
//			$0.edges.equalToSuperview()
//		}
//	}
//
//	func setupUI() {
//		addSubview(imageView)
//		clipsToBounds = true
//	}
//}
