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
		
		
		mapView.register(ImageAnnotation.self, forAnnotationViewWithReuseIdentifier: "imageAnnotation")
		
//		mapView.register(UINib(nibName: "PhotoLocationPinView", bundle: nil).self, forAnnotationViewWithReuseIdentifier: "PhotoLocationPinView")
		
//		mapView.register(PhotoLocationPinView.self , forAnnotationViewWithReuseIdentifier: "PhotoLocationPinView")
//		mapView.register(SnapshotAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		
//		mapView.register(PhotoLocationPinView.self, forAnnotationViewWithReuseIdentifier: "SomeRandomIdentifier")
//		Map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "SomeRandomIdentifier")
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
				
//
//			if let location = asset.location?.coordinate {
//				let annotation = MKPointAnnotation()
////				annotation.imageName = "backupContactsItem"
////				annotation.image = asset.thumbnail
//
//				annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//				annotations.append(annotation)
//			}
//			}
				if let location = asset.location?.coordinate {
										let annotation = ImageAnnotation()
					annotation.coordinate = location
					annotation.image = asset.thumbnail
					annotation.colour = .white
					annotation.title = "hello"
			//				annotation.image = UIImage(data: data!, scale: UIScreen.main.scale)
			//				annotation.title = "Toronto"
			//				annotation.subtitle = "Yonge & Bloor"
					annotations.append(annotation)
				}
			
			
			}
			
				
	//
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
		if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
			return nil  //Default is to let the system handle it.
		}

		if !annotation.isKind(of: ImageAnnotation.self) {  //Handle non-ImageAnnotations..
			var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
			if pinAnnotationView == nil {
				pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
			}
			return pinAnnotationView
		}

		//Handle ImageAnnotations..
		var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
		if view == nil {
			view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
		}

		let annotation = annotation as! ImageAnnotation
		view?.image = annotation.image
		view?.annotation = annotation

		return view
	}
	
//	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
//
//		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
//			pinView = MapPinView(annotation: annotation, reuseIdentifier: "pin")
//			return pinView
//		if !(annotation is SnapshotAnnotationView) {
//			  return nil
//		  }
//
//		  let reuseId = "SnapshotAnnotationView"
//
//		var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
//		  if anView == nil {
//			  anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//			  anView!.canShowCallout = true
//		  }
//		  else {
//			  anView?.annotation = annotation
//		  }
//
//		  //Set annotation-specific properties **AFTER**
//		  //the view is dequeued or created...
//
//		let cpa = annotation as! SnapshotAnnotationView
////		anView?.image = cpa.image
//
//
////		UIImage(named:cpa.imageName)
//
//		  return anView

//	}

}


extension LocationViewController: Themeble {
	
	func setupUI() {
		
		self.overrideUserInterfaceStyle = .dark
	}

	func setupNavigationBar() {
		
		navigationBar.setupNavigation(title: self.title,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: .userPhoto,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	func updateColors() {
		
	}
	
	func setupDelegate() {
		
		self.mapView.delegate = self
//		self.locationManager.delegate = self
		
		self.navigationBar.delegate = self
	}
}




class ImageAnnotation : NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var image: UIImage?
	var colour: UIColor?

	override init() {
		self.coordinate = CLLocationCoordinate2D()
		self.title = nil
		self.subtitle = nil
		self.image = nil
		self.colour = UIColor.white
	}
}

class ImageAnnotationView: MKAnnotationView {
	private var imageView: UIImageView!

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		self.addSubview(self.imageView)

		self.imageView.layer.cornerRadius = 5.0
		self.imageView.layer.masksToBounds = true
		
		self.backgroundColor = .red
	}

	override var image: UIImage? {
		get {
			return self.imageView.image
		}

		set {
			self.imageView.image = newValue
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//class ViewController: UIViewController, MKMapViewDelegate {
//
//	var mapView: MKMapView!
//	var locationManager: CLLocationManager!
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//
//		self.initControls()
//		self.doLayout()
//		self.loadAnnotations()
//	}
//
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//	}
//
//	func initControls() {
//		self.mapView = MKMapView()
//
//		self.mapView.isRotateEnabled = true
//		self.mapView.showsUserLocation = true
//		self.mapView.delegate = self
//
//		let center = CLLocationCoordinate2DMake(43.761539, -79.411079)
//		let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.005, 0.005))
//		self.mapView.setRegion(region, animated: true)
//	}
//
//	func doLayout() {
//		self.view.addSubview(self.mapView)
//		self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//		self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//		self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//		self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//		self.mapView.translatesAutoresizingMaskIntoConstraints = false
//	}
//
//	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//		if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
//			return nil  //Default is to let the system handle it.
//		}
//
//		if !annotation.isKind(of: ImageAnnotation.self) {  //Handle non-ImageAnnotations..
//			var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
//			if pinAnnotationView == nil {
//				pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
//			}
//			return pinAnnotationView
//		}
//
//		//Handle ImageAnnotations..
//		var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
//		if view == nil {
//			view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
//		}
//
//		let annotation = annotation as! ImageAnnotation
//		view?.image = annotation.image
//		view?.annotation = annotation
//
//		return view
//	}
//
//
//	func loadAnnotations() {
//		let request = NSMutableURLRequest(url: URL(string: "https://i.imgur.com/zIoAyCx.png")!)
//		request.httpMethod = "GET"
//
//		let session = URLSession(configuration: URLSessionConfiguration.default)
//		let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//			if error == nil {
//
//				let annotation = ImageAnnotation()
//				annotation.coordinate = CLLocationCoordinate2DMake(43.761539, -79.411079)
//				annotation.image = UIImage(data: data!, scale: UIScreen.main.scale)
//				annotation.title = "Toronto"
//				annotation.subtitle = "Yonge & Bloor"
//
//
//				DispatchQueue.main.async {
//					self.mapView.addAnnotation(annotation)
//				}
//			}
//		}
//
//		dataTask.resume()
//	}
//}

