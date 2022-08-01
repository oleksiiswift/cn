//
//  LocationViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.08.2022.
//

import UIKit
import Photos
import MapKit

class LocationViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var mapView: MKMapView!
	
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	public var assetCollection: [PHAsset] = []
	
	private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupDelegate()
		setupDataSource()
		setupUI()
		setupNavigationBar()
		updateColors()
    }
}

extension LocationViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

extension LocationViewController {
	
	private func setupDataSource() {
		
		var annotations = [MKAnnotation]()

		for asset in assetCollection {
			autoreleasepool {
				
				if let location = asset.location?.coordinate {
					let annotation = PHAssetAnnotation()
					annotation.phasset = asset
					annotation.coordinate = location
					annotation.image = asset.thumbnail
					annotations.append(annotation)
				}
			}
		}
		
		self.mapView.addAnnotations(annotations)
		self.mapView.showAnnotations(self.mapView.annotations, animated: true)
		
		let currentMapRect = self.mapView.visibleMapRect
		let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
		self.mapView.setVisibleMapRect(currentMapRect, edgePadding: padding, animated: true)
	}
}

extension LocationViewController: MKMapViewDelegate {
		
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

		var annotationView: PHAssetAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.identifiers.views.phassetAnnotation) as? PHAssetAnnotationView
		if annotationView == nil {
			annotationView = PHAssetAnnotationView(annotation: annotation, reuseIdentifier: Constants.identifiers.views.phassetAnnotation)
		}

		let annotation = annotation as! PHAssetAnnotation
		annotationView?.image = annotation.image
		annotationView?.annotation = annotation

		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if view.isKind(of: PHAssetAnnotationView.self) {
			if let anno = view.annotation as? PHAssetAnnotation {
				debugPrint(anno.phasset?.location)
			}
		}
	}
}


extension LocationViewController: Themeble {
	
	func setupUI() {
		
		mapView.register(PHAssetAnnotation.self, forAnnotationViewWithReuseIdentifier: Constants.identifiers.views.phassetAnnotation)
	}

	func setupNavigationBar() {
		
		navigationBar.setIsDropShadow = false
		navigationBar.setupNavigation(title: self.title,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: .userPhoto,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
		
	}
	
	func updateColors() {
		
		self.overrideUserInterfaceStyle = .dark
	}
	
	func setupDelegate() {
		
		self.mapView.delegate = self
		self.navigationBar.delegate = self
	}
}
