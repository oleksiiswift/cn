//
//  LocationHeaderCollectionReusableView.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.08.2022.
//

import UIKit
import CoreLocation

protocol LocationHeaderCollectionDelegate {
	func removeLocation(at section: Int)
}

class LocationHeaderCollectionReusableView: UICollectionReusableView {
	
	@IBOutlet weak var locationTitleTextLabel: UILabel!
	@IBOutlet weak var dateComponentsTextLabel: UILabel!
	@IBOutlet weak var removeAllLocationButton: ShadowButton!
	
	private var locationManager = CLLocationManager()
	private var calendar = Calendar.current
	private var mediaContentType: MediaContentType = .userPhoto
	
	public var delegate: LocationHeaderCollectionDelegate?
	
	private var section: Int?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		locationTitleTextLabel.text = nil
		dateComponentsTextLabel.text = nil
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
    }
		
	@IBAction func didTapRemoveAllLocationActionButton(_ sender: ShadowButton) {
		removeAllLocationButton.animateButtonTransform()
		if let section = section {
			delegate?.removeLocation(at: section)
		}
	}   
}

extension LocationHeaderCollectionReusableView {
	
	public func configureHeader(with location: CLLocation?, dateComponents: DateComponents, section: Int) {
		
		self.section = section
		
		location?.placemark(completion: { placemark, error in
	
			if let placemark = placemark {
				debugPrint(placemark)
				var fullAdrtess: String {
					if let street = placemark.postalAddress?.street, !street.isEmpty, let city = placemark.city, !city.isEmpty {
						return street + ", " + city
					} else if let city = placemark.city, !city.isEmpty, let country = placemark.county, !country.isEmpty {
						return city + ", " + country
					} else if  let country = placemark.county, !country.isEmpty {
						return country
					} else {
						if let location = location {
							return location.coordinate.dms.longitude + L.whitespace + location.coordinate.dms.latitude
						}
					}
					return L.empty
				}
				self.locationTitleTextLabel.text = fullAdrtess
 			} else {
				if let location = location {
					let readableCoordinates = location.coordinate.dms.latitude + " " + location.coordinate.dms.longitude
					debugPrint(readableCoordinates)
					self.locationTitleTextLabel.text = readableCoordinates
				} else {
					self.locationTitleTextLabel.text = L.empty
				}
			}
		})
		
		let date = calendar.date(from: dateComponents)
		
		if let date = date {
			let stringDate = date.convertDateFormatterFromDate(date: date, format: Constants.dateFormat.dateFormat)
			dateComponentsTextLabel.text = Utils.displayDate(from: stringDate)
		} else {
			dateComponentsTextLabel.text = ""
		}
		
		removeAllLocationButton.setImage(Images.location.slashPin, enabled: true)
	}
}

extension LocationHeaderCollectionReusableView: Themeble {
	
	func setupUI() {
	
		removeAllLocationButton.contentType = mediaContentType
		
		locationTitleTextLabel.font = FontManager.contactsFont(of: .cellGroupCellHeaderTitle)
		dateComponentsTextLabel.font = FontManager.contactsFont(of: .headetTitle)
	}
	
	func updateColors() {
		
		locationTitleTextLabel.textColor = mediaContentType.screenAcentTintColor
		dateComponentsTextLabel.textColor = theme.helperTitleTextColor
	}
}
