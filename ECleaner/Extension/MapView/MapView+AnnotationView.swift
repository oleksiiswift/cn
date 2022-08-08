//
//  MapView+AnnotationView.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import MapKit

private let radiusOfEarth: Double = 6372797.6

extension MKMapView {
	
	func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
		guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
			return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		}
		annotationView.annotation = annotation
		return annotationView
	}
}

extension MKPolyline {
	
	convenience init(mapRect: MKMapRect) {
		let points = [
			MKMapPoint(x: mapRect.minX, y: mapRect.minY),
			MKMapPoint(x: mapRect.maxX, y: mapRect.minY),
			MKMapPoint(x: mapRect.maxX, y: mapRect.maxY),
			MKMapPoint(x: mapRect.minX, y: mapRect.maxY),
			MKMapPoint(x: mapRect.minX, y: mapRect.minY)
		]
		self.init(points: points, count: points.count)
	}
}

extension CLLocationCoordinate2D {
	
	var location: CLLocation {
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	func coordinate(onBearingInRadians bearing: Double, atDistanceInMeters distance: Double) -> CLLocationCoordinate2D {
		let distRadians = distance / radiusOfEarth // earth radius in meters
		
		let lat1 = latitude * .pi / 180
		let lon1 = longitude * .pi / 180
		
		let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
		let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
		
		return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
	}

	func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		return location.distance(from: coordinate.location)
	}
}
