//
//  LocationViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.08.2022.
//

import UIKit
import Photos
import MapKit
import SwiftMessages

enum LocationViewLayout {
	case map
	case grid
}

class LocationViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var containerView: UIView!
	
	private var locationGridViewController = LocationGridViewController()
	
	private var locationViewLayout: LocationViewLayout = .map {
		didSet {
			self.setContainer(layout: self.locationViewLayout)
		}
	}
	
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	public var assetCollection: [PHAsset] = []
	public var visibleAssetCollection: [PHAsset] = []
	private var locationManager = CLLocationManager()
	private var photoManager = PhotoManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupDelegate()
		setupGridController()
		setupDataSource()
		setupUI()
		setupNavigationBar()
		updateColors()
		self.containerView.isHidden = true
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			case Constants.identifiers.segue.location:
				self.setupShowLocationInfoController(segue: segue, sender: sender)
			default:
				return
		}
	}
}

extension LocationViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {
		switch locationViewLayout {
			case .map:
				guard !self.visibleAssetCollection.isEmpty else { return }
				setupGridLocationList(with: self.visibleAssetCollection)
				locationViewLayout = .grid
			case .grid:
				setupGridLocationList(with: [])
				locationViewLayout = .map
		}
	}
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
	
	private func setupGridLocationList(with assets: [PHAsset]) {
		locationGridViewController.setupViewModel(with: assets)
	}
	
	private func setContainer(layout view: LocationViewLayout) {
		
		setupNavigationBar()
		
		self.containerView.isHidden = view == .map
	}
	
	private func setupShowLocationInfoController(segue: UIStoryboardSegue, sender: Any?) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: true)
		segue.interactiveHide = true
		segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
		segue.messageView.configureNoDropShadow()
		
		if let locationInfoViewController = segue.destination as? LocationInfoViewController {
			if let phasset = sender as? PHAsset {
				locationInfoViewController.currentPhasset = phasset
				if let date = phasset.creationDate {
					locationInfoViewController.title = Utils.getString(from: date, format: Constants.dateFormat.readableFormat)
				} else {
					locationInfoViewController.title = Localization.Main.Title.location
				}
				
				locationInfoViewController.removeSelectedPHAsset = { phasset in
					self.removeLocationOperation(with: [phasset]) { _ in }
				}
			}
		}
	}
}

extension LocationViewController: LocationGridDelegate {
	
	func removeLocations(at phassets: [PHAsset], completionHandler: @escaping ((Bool) -> Void)) {
		self.removeLocationOperation(with: phassets) { removed in
			Utils.UI {
				self.mapView.delegate?.mapViewDidChangeVisibleRegion?(self.mapView)
				removed ? self.setupGridLocationList(with: self.visibleAssetCollection) : ()
				
				if self.visibleAssetCollection.isEmpty {
					self.locationViewLayout = .map
				}
				completionHandler(removed)
			}
		}
	}
	
	private func removeLocationOperation(with selectedPhassets: [PHAsset], completionHandler: @escaping (_ removed: Bool) -> Void) {
		
		let removeOperation = photoManager.removeeSelectedPhassetLocation(assets: selectedPhassets) { removed in
			
			if removed {
				let mapAnnotations = self.mapView.annotations.compactMap({$0 as? PHAssetAnnotation}).map { $0}
				let filteredAnnotation = mapAnnotations.enumerated().filter({selectedPhassets.contains($0.element.phasset)}).map({$0.element})
				Utils.UI {
					self.mapView.removeAnnotations(filteredAnnotation)
					completionHandler(removed)
				}
			} else {
				completionHandler(removed)
			}
		}
		
		self.photoManager.serviceUtilityOperationsQueuer.addOperation(removeOperation)
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
			if let annotationView = view.annotation as? PHAssetAnnotation {
				let phasset = annotationView.phasset
				let sender: PHAsset = phasset
				self.performSegue(withIdentifier: Constants.identifiers.segue.location, sender: sender)
			}
		}
	}
	
	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		
		let visibleAnnotation = mapView.visiblePHAssetAnnotation()
		let phassets = visibleAnnotation.map({$0.phasset})
		self.visibleAssetCollection = phassets
	}
}

extension LocationViewController: Themeble {
	
	func setupGridController() {
		
		self.addChild(locationGridViewController)
		locationGridViewController.view.frame = containerView.bounds
		containerView.addSubview(locationGridViewController.view)
		locationGridViewController.didMove(toParent: self)
	}

	func setupUI() {
		mapView.register(PHAssetAnnotation.self, forAnnotationViewWithReuseIdentifier: Constants.identifiers.views.phassetAnnotation)
	}

	func setupNavigationBar() {
		navigationBar.setIsDropShadow = self.locationViewLayout == .grid
		let rightBarButtonScaleFactor: CGFloat = self.locationViewLayout == .grid ? 0.7 : 0.9
		let rightBarButtonImage: UIImage = self.locationViewLayout == .grid ? Images.location.map : Images.location.grid
		navigationBar.setupNavigation(title: self.title,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: rightBarButtonImage,
									  rightImageScaleFactor: rightBarButtonScaleFactor,
									  contentType: .userPhoto,
									  leftButtonTitle: nil, rightButtonTitle: nil)
	}
	
	func updateColors() {}
	
	func setupDelegate() {
		
		self.mapView.delegate = self
		self.navigationBar.delegate = self
		self.locationGridViewController.delegate = self
	}
}
