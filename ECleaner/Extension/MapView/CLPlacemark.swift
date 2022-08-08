//
//  CLPlacemark.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.08.2022.
//

import Foundation
import MapKit
import CoreLocation
import Contacts

extension CLPlacemark {
	
	var streetName: String? { thoroughfare }
	
	var streetNumber: String? { subThoroughfare }
	
	var city: String? { locality }
	
	var neighborhood: String? { subLocality }
	
	var state: String? { administrativeArea }
	
	var county: String? { subAdministrativeArea }
	
	var zipCode: String? { postalCode }

	var postalAddressFormatted: String? {
		guard let postalAddress = postalAddress else { return nil }
		return CNPostalAddressFormatter().string(from: postalAddress)
	}
}

extension CLLocation {
	
	func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
		CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
	}
}
