//
//  LocationInfoViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.08.2022.
//

import UIKit
import Photos

class LocationInfoViewController: UIViewController {

	@IBOutlet weak var previewImageView: UIImageView!
	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var navigationBar: StartingNavigationBar!
	@IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonMenuHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var locationContainerView: UIView!
	
	public var removeSelectedPHAsset: ((_ phasset:  PHAsset) -> Void)?
	
	public var currentPhasset: PHAsset?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
		setupNavigation()
		updateColors()
		setupLocationData()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
	}
}

extension LocationInfoViewController {
	
	public func setupLocationData() {
		
		guard let phasset = self.currentPhasset else { return }
		
		previewImageView.image = phasset.getImage
		previewImageView.contentMode = .scaleAspectFill
		
		if let location = phasset.location {
			
			var models: [LocationDescriptionModel] = []
			
			let readableCoordinates = location.coordinate.dms
			let latitude = readableCoordinates.latitude
			let longitude = readableCoordinates.longitude
			let latitudeModel = LocationDescriptionModel(title: LocationInfo.latitude.title, info: latitude, locationInfo: .latitude)
			models.append(latitudeModel)
			let longitudeModel = LocationDescriptionModel(title: LocationInfo.longitude.title, info: longitude, locationInfo: .longitude)
			models.append(longitudeModel)
			
			var altStingValue: String {
				let alt = location.altitude.description
				if let index = alt.firstIndex(of: ".") {
					let distanceIndex: Int = alt.distance(from: alt.description.startIndex, to: index) + 5
					return alt == "0.0" ? alt : alt.chopSuffix(alt.description.count - distanceIndex)
				} else {
					return "0.0"
				}
			}
					
			let altitude = LocationDescriptionModel(title: LocationInfo.altitude.title, info: altStingValue, locationInfo: .altitude)
			models.append(altitude)
			
			location.placemark { placemark, error in
				var address: String = ""
				
				if let postal = placemark?.postalAddressFormatted {
					address.append(contentsOf: postal.replacingOccurrences(of: "\n", with: ", "))
				} else {
					
					if let streetName = placemark?.streetName {
						address.append(contentsOf: streetName)
						address.append(contentsOf: ", ")
					}
					
					if let number = placemark?.streetNumber {
						address.append(contentsOf: number)
						address.append(contentsOf: ", ")
					}
					
					if let city = placemark?.city {
						address.append(contentsOf: city)
						address.append(contentsOf: ",\n")
					} else {
						address.append(contentsOf: "\n")
					}
					
					if let state = placemark?.state {
						address.append(contentsOf: state)
						address.append(contentsOf: ", ")
					}
					
					if let country = placemark?.county {
						address.append(contentsOf: country)
						address.append(contentsOf: ",\n")
					}
					
					if let zipCode = placemark?.zipCode {
						address.append(contentsOf: zipCode)
					}
				}
				
				let locationAdressModel = LocationDescriptionModel(title: LocationInfo.location.title, info: address, locationInfo: .location)
				models.append(locationAdressModel)
				self.locationDataSetup(with: models)
			}
		}
	}
	
	private func locationDataSetup(with model: [LocationDescriptionModel]) {
		
		var infoViews: [LocationInfoView] = []
		
		model.forEach {
			let view = LocationInfoView()
			view.configureView(with: $0)
			infoViews.append(view)
		}
		
		let stackView = UIStackView(arrangedSubviews: infoViews)
		stackView.frame = self.locationContainerView.bounds
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.locationContainerView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: self.locationContainerView.topAnchor, constant: 10).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.locationContainerView.bottomAnchor, constant: -10).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.locationContainerView.leadingAnchor, constant: 20).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.locationContainerView.trailingAnchor, constant:  -20).isActive = true
	}
}

extension LocationInfoViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		guard let phasset = currentPhasset else { return }
		
		self.dismiss(animated: true) {
			self.removeSelectedPHAsset?(phasset)
		}
	}
}

extension LocationInfoViewController: StartingNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {}
	
	func didTapRightBarButton(_sender: UIButton) {
		self.dismiss(animated: true)
	}
}

extension LocationInfoViewController: Themeble {
	
	func setupUI() {
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		let containerHeight: CGFloat = AppDimensions.ModalControllerSettings.mainContainerHeight
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContainerHeightConstraint.constant = containerHeight
		
		bottomButtonMenuHeightConstraint.constant = AppDimensions.BottomButton.bottomBarDefaultHeight
		bottomButtonView.title(LocalizationService.Buttons.getButtonTitle(of: .removeLocation).uppercased())
		bottomButtonView.setImage(Images.location.pin)
		
		bottomButtonView.delegate = self
	}
	
	func setupNavigation() {
		
		navigationBar.setUpNavigation(title: self.title, rightImage: I.systemItems.navigationBarItems.dissmiss, targetImageScaleFactor: 0.4, imageTintColor: .clear)
		navigationBar.topShevronEnable = true
		navigationBar.delegate = self
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		
		bottomButtonView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonView.buttonColor = theme.photoTintColor
		bottomButtonView.updateColorsSettings()
	}
}
