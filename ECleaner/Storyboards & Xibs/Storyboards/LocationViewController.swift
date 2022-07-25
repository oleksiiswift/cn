//
//  LocationViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.07.2022.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
	
	
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		PHAssetFetchManager.shared.locationFetch { result in
			
			result.enumerateObjects { asset, index, object in
//				debugPrint(asset.location)
				
				if let location = asset.location?.coordinate {
					
					
				
					
					
				
					asset.location?.placemark(completion: { placemark, error in
						debugPrint(placemark?.city)
						debugPrint(placemark?.streetName)
						debugPrint(placemark?.streetNumber)
						
					})
				  let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
				  let region = MKCoordinateRegion(center: location, span: span)
					self.mapView.setRegion(region, animated: true)
					  
				  //3
					
					let annotation = MKPointAnnotation()
					annotation.coordinate = location
//					annotation.image = asset.getImage
					
					
//				  let annotation = MKPointAnnotation()
//				  annotation.coordinate = location
//				  annotation.title = "Big Ben"
//				  annotation.subtitle = "London"
					
				self.mapView.addAnnotation(annotation)
				}
				
			}
			
		}
        
		
		
    }
	
	func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
					-> Void ) {
		// Use the last reported location.
		if let lastLocation = self.locationManager.location {
			let geocoder = CLGeocoder()
				
			// Look up the location and pass it to the completion handler
			geocoder.reverseGeocodeLocation(lastLocation,
						completionHandler: { (placemarks, error) in
				if error == nil {
					let firstLocation = placemarks?[0]
					completionHandler(firstLocation)
				}
				else {
				 // An error occurred during geocoding.
					completionHandler(nil)
				}
			})
		}
		else {
			// No location was available.
			completionHandler(nil)
		}
	}
	
	func getCoordinate( addressString : String,
			completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressString) { (placemarks, error) in
			if error == nil {
				if let placemark = placemarks?[0] {
					let location = placemark.location!
						
					completionHandler(location.coordinate, nil)
					return
				}
			}
				
			completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
		}
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
		self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		self.addSubview(self.imageView)

		self.imageView.layer.cornerRadius = 5.0
		self.imageView.layer.masksToBounds = true
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

class ViewController: UIViewController, MKMapViewDelegate {

	var mapView: MKMapView!
	var locationManager: CLLocationManager!

	override func viewDidLoad() {
		super.viewDidLoad()


		self.initControls()
		self.doLayout()
		self.loadAnnotations()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	func initControls() {
		self.mapView = MKMapView()

		self.mapView.isRotateEnabled = true
		self.mapView.showsUserLocation = true
		self.mapView.delegate = self

//		let center = CLLocationCoordinate2DMake(43.761539, -79.411079)
//		let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.005, 0.005))
//		self.mapView.setRegion(region, animated: true)
	}

	func doLayout() {
		self.view.addSubview(self.mapView)
		self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
	}

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


	func loadAnnotations() {
		let request = NSMutableURLRequest(url: URL(string: "https://i.imgur.com/zIoAyCx.png")!)
		request.httpMethod = "GET"

		let session = URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
			if error == nil {

				let annotation = ImageAnnotation()
				annotation.coordinate = CLLocationCoordinate2DMake(43.761539, -79.411079)
				annotation.image = UIImage(data: data!, scale: UIScreen.main.scale)
				annotation.title = "Toronto"
				annotation.subtitle = "Yonge & Bloor"

				
				DispatchQueue.main.async {
					self.mapView.addAnnotation(annotation)
				}
			}
		}

		dataTask.resume()
	}
}


import Contacts
extension CLPlacemark {
	/// street name, eg. Infinite Loop
	var streetName: String? { thoroughfare }
	/// // eg. 1
	var streetNumber: String? { subThoroughfare }
	/// city, eg. Cupertino
	var city: String? { locality }
	/// neighborhood, common name, eg. Mission District
	var neighborhood: String? { subLocality }
	/// state, eg. CA
	var state: String? { administrativeArea }
	/// county, eg. Santa Clara
	var county: String? { subAdministrativeArea }
	/// zip code, eg. 95014
	var zipCode: String? { postalCode }
	/// postal address formatted
	@available(iOS 11.0, *)
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

//let location = CLLocation(latitude: 37.331676, longitude: -122.030189)
//location.placemark { placemark, error in
//	guard let placemark = placemark else {
//		print("Error:", error ?? "nil")
//		return
//	}
//	print(placemark.postalAddressFormatted ?? "")
//}
