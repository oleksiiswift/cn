//
//  ClusteringManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import CoreLocation
import MapKit

protocol ClusterManagerDelegate {
	func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool
}

extension ClusterManagerDelegate {
	func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool { return true }
}

class ClusterManager {
	
	var tree = QuadTree(rect: .world)
	public internal(set) var zoomLevel: Double = 0
	public var maxZoomLevel: Double = 20
	public var minCountForClustering: Int = 2
	public var shouldRemoveInvisibleAnnotations: Bool = true
	public var shouldDistributeAnnotationsOnSameCoordinate: Bool = true
	public var distanceFromContestedLocation: Double = 3
	
	public enum ClusterPosition {
		case center
		case nearCenter
		case average
		case first
	}
	
	public var clusterPosition: ClusterPosition = .first

	public var annotations: [MKAnnotation] {
		return dispatchQueue.sync {
			tree.annotations(in: .world)
		}
	}

	public var visibleAnnotations = [MKAnnotation]()
	public var visibleNestedAnnotations: [MKAnnotation] {
		return dispatchQueue.sync {
			visibleAnnotations.reduce([MKAnnotation](), { $0 + (($1 as? ClusterAnnotation)?.annotations ?? [$1]) })
		}
	}
	
	let operationQueue = OperationQueue.serial
	let dispatchQueue = DispatchQueue(label: Constants.key.dispatch.clusteringQueue, attributes: .concurrent)
	
	public var delegate: ClusterManagerDelegate?
	
	public init() {}

	public func add(_ annotation: MKAnnotation) {
		operationQueue.cancelAllOperations()
		dispatchQueue.async(flags: .barrier) { [weak self] in
			self?.tree.add(annotation)
		}
	}

	public func add(_ annotations: [MKAnnotation]) {
		operationQueue.cancelAllOperations()
		dispatchQueue.async(flags: .barrier) { [weak self] in
			for annotation in annotations {
				self?.tree.add(annotation)
			}
		}
	}

	public func remove(_ annotation: MKAnnotation) {
		operationQueue.cancelAllOperations()
		dispatchQueue.async(flags: .barrier) { [weak self] in
			self?.tree.remove(annotation)
		}
	}
	
	public func remove(_ annotations: [MKAnnotation]) {
		operationQueue.cancelAllOperations()
		dispatchQueue.async(flags: .barrier) { [weak self] in
			for annotation in annotations {
				self?.tree.remove(annotation)
			}
		}
	}

	public func removeAll() {
		operationQueue.cancelAllOperations()
		dispatchQueue.async(flags: .barrier) { [weak self] in
			self?.tree = QuadTree(rect: .world)
		}
	}

	public func reload(_ mapView: MKMapView, visibleMapRect: MKMapRect) {
		reload(mapView: mapView)
	}
	
	public func reload(mapView: MKMapView, completion: @escaping (Bool) -> Void = { finished in }) {
		
		let mapBounds = mapView.bounds
		let visibleMapRect = mapView.visibleMapRect
		let visibleMapRectWidth = visibleMapRect.size.width
		let zoomScale = Double(mapBounds.width) / visibleMapRectWidth
		operationQueue.cancelAllOperations()
		operationQueue.addBlockOperation { [weak self, weak mapView] operation in
			guard let self = self, let mapView = mapView else { return completion(false) }
			autoreleasepool {
				let (toAdd, toRemove) = self.clusteredAnnotations(zoomScale: zoomScale, visibleMapRect: visibleMapRect, operation: operation)
				DispatchQueue.main.async { [weak self, weak mapView] in
					guard let self = self, let mapView = mapView else { return completion(false) }
					self.display(mapView: mapView, toAdd: toAdd, toRemove: toRemove)
					completion(true)
				}
			}
		}
	}
	
	public func clusteredAnnotations(zoomScale: Double, visibleMapRect: MKMapRect, operation: Operation? = nil) -> (toAdd: [MKAnnotation], toRemove: [MKAnnotation]) {
		var isCancelled: Bool { return operation?.isCancelled ?? false }
		
		guard !isCancelled else { return (toAdd: [], toRemove: []) }
		
		let mapRects = self.mapRects(zoomScale: zoomScale, visibleMapRect: visibleMapRect)
		
		guard !isCancelled else { return (toAdd: [], toRemove: []) }
		
		if shouldDistributeAnnotationsOnSameCoordinate {
			distributeAnnotations(tree: tree, mapRect: visibleMapRect)
		}
		
		let allAnnotations = dispatchQueue.sync {
			clusteredAnnotations(tree: tree, mapRects: mapRects, zoomLevel: zoomLevel)
		}
		
		guard !isCancelled else { return (toAdd: [], toRemove: []) }
		
		let before = visibleAnnotations
		let after = allAnnotations
		
		var toRemove = before.subtracted(after)
		let toAdd = after.subtracted(before)
		
		if !shouldRemoveInvisibleAnnotations {
			let toKeep = toRemove.filter { !visibleMapRect.contains($0.coordinate) }
			toRemove.subtract(toKeep)
		}
		
		dispatchQueue.async(flags: .barrier) { [weak self] in
			self?.visibleAnnotations.subtract(toRemove)
			self?.visibleAnnotations.add(toAdd)
		}
		
		return (toAdd: toAdd, toRemove: toRemove)
	}
	
	func clusteredAnnotations(tree: QuadTree, mapRects: [MKMapRect], zoomLevel: Double) -> [MKAnnotation] {
		
		var allAnnotations = [MKAnnotation]()
		for mapRect in mapRects {
			var annotations = [MKAnnotation]()
			
			// add annotations
			for node in tree.annotations(in: mapRect) {
				if delegate?.shouldClusterAnnotation(node) ?? true {
					annotations.append(node)
				} else {
					allAnnotations.append(node)
				}
			}
			
			// handle clustering
			let count = annotations.count
			if count >= minCountForClustering, zoomLevel <= maxZoomLevel {
				let cluster = ClusterAnnotation()
				cluster.coordinate = coordinate(annotations: annotations, position: clusterPosition, mapRect: mapRect)
				cluster.phassets = annotations.compactMap({$0 as? Annotation}).map({$0.phasset})
				cluster.annotations = annotations
				allAnnotations += [cluster]
			} else {
				allAnnotations += annotations
			}
		}
		return allAnnotations
	}
	
	func distributeAnnotations(tree: QuadTree, mapRect: MKMapRect) {
		let annotations = dispatchQueue.sync {
			tree.annotations(in: mapRect)
		}
		let hash = Dictionary(grouping: annotations) { $0.coordinate }
		dispatchQueue.async(flags: .barrier) {
			for value in hash.values where value.count > 1 {
				for (index, annotation) in value.enumerated() {
					tree.remove(annotation)
					let radiansBetweenAnnotations = (.pi * 2) / Double(value.count)
					let bearing = radiansBetweenAnnotations * Double(index)
					(annotation as? MKPointAnnotation)?.coordinate = annotation.coordinate.coordinate(onBearingInRadians: bearing, atDistanceInMeters: self.distanceFromContestedLocation)
					tree.add(annotation)
				}
			}
		}
	}
	
	func coordinate(annotations: [MKAnnotation], position: ClusterPosition, mapRect: MKMapRect) -> CLLocationCoordinate2D {
		switch position {
		case .center:
			return MKMapPoint(x: mapRect.midX, y: mapRect.midY).coordinate
		case .nearCenter:
			let coordinate = MKMapPoint(x: mapRect.midX, y: mapRect.midY).coordinate
			let annotation = annotations.min { coordinate.distance(from: $0.coordinate) < coordinate.distance(from: $1.coordinate) }
			return annotation!.coordinate
		case .average:
			let coordinates = annotations.map { $0.coordinate }
			let totals = coordinates.reduce((latitude: 0.0, longitude: 0.0)) { ($0.latitude + $1.latitude, $0.longitude + $1.longitude) }
			return CLLocationCoordinate2D(latitude: totals.latitude / Double(coordinates.count), longitude: totals.longitude / Double(coordinates.count))
		case .first:
			return annotations.first!.coordinate
		}
	}
	
	func mapRects(zoomScale: Double, visibleMapRect: MKMapRect) -> [MKMapRect] {
		guard !zoomScale.isInfinite, !zoomScale.isNaN else { return [] }
		
		zoomLevel = zoomScale.zoomLevel
		let scaleFactor = zoomScale / cellSize(for: zoomLevel)
		
		let minX = Int(floor(visibleMapRect.minX * scaleFactor))
		let maxX = Int(floor(visibleMapRect.maxX * scaleFactor))
		let minY = Int(floor(visibleMapRect.minY * scaleFactor))
		let maxY = Int(floor(visibleMapRect.maxY * scaleFactor))
		
		var mapRects = [MKMapRect]()
		for x in minX...maxX {
			for y in minY...maxY {
				var mapRect = MKMapRect(x: Double(x) / scaleFactor, y: Double(y) / scaleFactor, width: 1 / scaleFactor, height: 1 / scaleFactor)
				if mapRect.origin.x > MKMapPointMax.x {
					mapRect.origin.x -= MKMapPointMax.x
				}
				mapRects.append(mapRect)
			}
		}
		return mapRects
	}
	
	public func display(mapView: MKMapView, toAdd: [MKAnnotation], toRemove: [MKAnnotation]) {
		assert(Thread.isMainThread, "This function must be called from the main thread.")
		mapView.removeAnnotations(toRemove)
		mapView.addAnnotations(toAdd)
	}
	
	func cellSize(for zoomLevel: Double) -> Double {
		switch zoomLevel {
		case 13...15:
			return 64
		case 16...18:
			return 32
		case 19...:
			return 16
		default:
			return 88
		}
	}
}
