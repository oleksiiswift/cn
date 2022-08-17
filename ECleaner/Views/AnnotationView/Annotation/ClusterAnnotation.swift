//
//  ClusterAnnotation.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import MapKit
import Photos

class ClusterAnnotation: Annotation {
	
	var annotations = [MKAnnotation]()
	var phassets: [PHAsset] = []
	
	override func isEqual(_ object: Any?) -> Bool {
		guard let object = object as? ClusterAnnotation else { return false }
		
		if self === object {
			return true
		}
		
		if coordinate != object.coordinate {
			return false
		}
		
		if annotations.count != object.annotations.count {
			return false
		}
		
		return annotations.map { $0.coordinate } == object.annotations.map { $0.coordinate }
	}
}
