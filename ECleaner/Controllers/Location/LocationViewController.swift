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
	public var preloadedStartedAnnotations: [MKAnnotation] = []
	public var visibleAssetCollection: [PHAsset] = []
	private var locationManager = CLLocationManager()
	private var photoManager = PhotoManager.shared
	
	lazy var manager: ClusterManager = { [unowned self] in
		let manager = ClusterManager()
		manager.delegate = self
		manager.maxZoomLevel = 17
		manager.minCountForClustering = 2
		manager.clusterPosition = .nearCenter
		return manager
	}()
	
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
		
		manager.add(self.preloadedStartedAnnotations)
		manager.reload(mapView: mapView)
		
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
		
		let removeOperation = photoManager.removeSelectedPhassetLocation(assets: selectedPhassets) { removed in
			
			if removed {
				let annotations = self.manager.annotations.compactMap({$0 as? Annotation}).map({$0})
				let filteredAnnotation = annotations.enumerated().filter({selectedPhassets.contains($0.element.phasset)}).map({$0.element})
				Utils.UI {
					self.manager.remove(filteredAnnotation)
					self.manager.reload(mapView: self.mapView)
					
					removed ? Vibration.success.vibrate() : Vibration.error.vibrate()
					
					U.delay(0.1) {
						completionHandler(removed)
					}
				}
			} else {
				completionHandler(removed)
			}
		}
		self.photoManager.serviceUtilityOperationsQueuer.addOperation(removeOperation)
	}
}

extension LocationViewController: AnnotationViewSelectDelegate {
	
	func didSelectClusterAnnotation(_ view: MKAnnotationView) {
		
		if let phassetAnnotionView = view as? PHAssetAnnotationView {
			if let annotation = phassetAnnotionView.annotation as? Annotation {
				self.performSegue(withIdentifier: Constants.identifiers.segue.location, sender: annotation.phasset)
			}
		} else if let clusterAnnotationView = view as? ClusterAnnotationView {
			if let annotation = clusterAnnotationView.annotation as? ClusterAnnotation {
				if !annotation.annotations.isEmpty {
					let annotationCollection = annotation.annotations.compactMap({$0 as? Annotation}).map({$0})
					let phassetCollectionInCluster = annotationCollection.map({$0.phasset})
					self.setupGridLocationList(with: phassetCollectionInCluster)
					self.locationViewLayout = .grid
				}
			}
		}
	}
}

extension LocationViewController: MKMapViewDelegate {
		
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if let annotation = annotation as? ClusterAnnotation {
			let identifier = Constants.identifiers.mapAnnotation.cluster
			let clusterAnnotationView = mapView.annotationView(of: ClusterAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
			clusterAnnotationView.delegate = self
			clusterAnnotationView.phassets = annotation.phassets
			return clusterAnnotationView
		} else {
			let phassetAnnotation = annotation as! Annotation
			let identifier = Constants.identifiers.mapAnnotation.pin
			let annotationView = mapView.annotationView(of: PHAssetAnnotationView.self, annotation: phassetAnnotation, reuseIdentifier: identifier)
			annotationView.delegate = self
			annotationView.image = phassetAnnotation.image
			return annotationView
		}
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		manager.reload(mapView: mapView) { _ in }
	}
	
	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		let clusterAnnotationCollection = manager.visibleAnnotations.compactMap({$0 as? ClusterAnnotation}).map({$0})
		let clusterViews = clusterAnnotationCollection.compactMap({mapView.view(for: $0) as? ClusterAnnotationView})
		let clusterAnnotations = clusterViews.compactMap({$0.annotation as? ClusterAnnotation}).map({$0})
		let clusterPHAssets = Array(clusterAnnotations.compactMap({$0.phassets}).joined())
		
		let annotationCollection = manager.visibleAnnotations.compactMap({$0 as? Annotation}).map({$0})
		let annotationViews = annotationCollection.compactMap({mapView.view(for: $0) as? PHAssetAnnotationView})
		let annotations = annotationViews.compactMap({$0.annotation as? Annotation}).map({$0})
		let phassets = annotations.compactMap({$0.phasset})
		self.visibleAssetCollection = clusterPHAssets
		self.visibleAssetCollection.append(contentsOf: phassets)
	}
	
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		views.forEach { $0.alpha = 0 }
		views.forEach { annotationView in
			UIView.transition(with: annotationView, duration: 0.35, options: .curveEaseInOut) {
				annotationView.alpha = 1
			} completion: { _ in }
		}
	}
}

extension LocationViewController: ClusterManagerDelegate {

	func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
		return !(annotation is ClusterAnnotation)
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
		mapView.showsCompass = false
		mapView.showsUserLocation = false
		mapView.overrideUserInterfaceStyle = .dark
	}
	func updateColors() {}

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
	
	func setupDelegate() {
		
		self.mapView.delegate = self
		self.navigationBar.delegate = self
		self.locationGridViewController.delegate = self
	}
}

