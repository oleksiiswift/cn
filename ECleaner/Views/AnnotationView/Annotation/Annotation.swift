//
//  Annotation.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import MapKit
import Photos

class Annotation: MKPointAnnotation {

	public var phasset: PHAsset = PHAsset()
	public var annotationID: String?
	public var image: UIImage?
	
	public convenience init(coordinate: CLLocationCoordinate2D) {
		self.init()
		self.coordinate = coordinate
	}
}
