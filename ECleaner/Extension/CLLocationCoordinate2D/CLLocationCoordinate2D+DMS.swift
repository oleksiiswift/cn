//
//  CLLocationCoordinate2D+DMS.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.08.2022.
//

import MapKit

extension CLLocationCoordinate2D {
	
	var latitudeMinutes: Double { return (latitude * 3600).truncatingRemainder(dividingBy: 3600) / 60 }
	var latitudeSeconds: Double { return ((latitude * 3600).truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60) }
	
	var longitudeMinutes: Double { return (longitude * 3600).truncatingRemainder(dividingBy: 3600) / 60 }
	var longitudeSeconds: Double { return ((longitude * 3600).truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60) }
	
	var degrees: (latitude: String, longitude: String) {
		(String(format: "%.5f°", latitude), String(format: "%.5f°", longitude))
	}
	
	var dms: (latitude: String, longitude: String) {
		(String(format: "%d° %d' %.1f\" %@",
				Int(abs(latitude)),
				Int(abs(latitudeMinutes)),
				abs(latitudeSeconds),
				latitude >= 0 ? "N" : "S"),
		 String(format: "%d° %d' %.1f\" %@",
				Int(abs(longitude)),
				Int(abs(longitudeMinutes)),
				abs(longitudeSeconds),
				longitude >= 0 ? "E" : "W"))
	}
	
	var ddm: (latitude: String, longitude: String) {
		(String(format: "%d° %.3f' %@",
				Int(abs(latitude)),
				abs(latitudeMinutes),
				latitude >= 0 ? "N" : "S"),
		 String(format: "%d° %.3f' %@",
				Int(abs(longitude)),
				abs(longitudeMinutes),
				longitude >= 0 ? "E" : "W"))
	}
}
