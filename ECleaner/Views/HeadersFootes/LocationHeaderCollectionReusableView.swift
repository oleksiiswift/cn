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
				
				self.locationTitleTextLabel.text = placemark.postalAddress?.street ?? ""
 			} else {
				self.locationTitleTextLabel.text = "empty"
			}
		})
		
		
		let date = calendar.date(from: dateComponents)
		
		if let date = date {
			let stringDate = date.convertDateFormatterFromDate(date: date, format: Constants.dateFormat.dateFormat)
			dateComponentsTextLabel.text = Utils.displayDate(from: stringDate)
		} else {
			dateComponentsTextLabel.text = ""
		}
		
		removeAllLocationButton.setImage(UIImage(systemName: "mappin.slash")!, enabled: true)
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
