//
//  MapKit+Extesnsion.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import Foundation
import MapKit

let CLLocationCoordinate2DMax = CLLocationCoordinate2D(latitude: 90, longitude: 180)
let MKMapPointMax = MKMapPoint(CLLocationCoordinate2DMax)

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension MKMapRect {
	init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
		self.init(x: minX, y: minY, width: abs(maxX - minX), height: abs(maxY - minY))
	}
	init(x: Double, y: Double, width: Double, height: Double) {
		self.init(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: width, height: height))
	}
	func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
		return self.contains(MKMapPoint(coordinate))
	}
}

extension CLLocationCoordinate2D: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}

extension Double {
	var zoomLevel: Double {
		let maxZoomLevel = log2(MKMapSize.world.width / 256) // 20
		let zoomLevel = floor(log2(self) + 0.5) // negative
		return max(0, maxZoomLevel + zoomLevel) // max - current
	}
}

extension Array where Element: MKAnnotation {
	
	func subtracted(_ other: [Element]) -> [Element] {
		return filter { item in !other.contains { $0.isEqual(item) } }
	}
	
	mutating func subtract(_ other: [Element]) {
		self = self.subtracted(other)
	}
	
	mutating func add(_ other: [Element]) {
		self.append(contentsOf: other)
	}
	
	@discardableResult
	mutating func remove(_ item: Element) -> Element? {
		return firstIndex { $0.isEqual(item) }.map { remove(at: $0) }
	}
}
