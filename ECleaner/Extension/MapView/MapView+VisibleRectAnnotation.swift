//
//  MapView+VisibleRectAnnotation.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.08.2022.
//

import MapKit

extension MKMapView {
	
	func visibleAnnotations() -> [MKAnnotation] {
		return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
	}
}
