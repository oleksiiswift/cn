//
//  ClusterAnnotationView.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import MapKit
import Photos

class ClusterAnnotationView: MKAnnotationView {
	
	private var imageView: UIImageView!
	public var phassets: [PHAsset] = []
	
	override var image: UIImage? {
		get {
			return self.imageView.image
		} set {
			self.imageView.image = newValue
		}
	}
	 
	lazy var countLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .clear
		label.font = .boldSystemFont(ofSize: 10)
		label.textColor = .white
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		label.baselineAdjustment = .alignCenters
		self.addSubview(label)
		return label
	}()

	let bubleSize:   CGFloat = 70
	let offset:      CGFloat = 3
	let bubleOffset: CGFloat = 5
	let annotationSize: CGSize = CGSize(width: 80, height: 80)
	
	open override var annotation: MKAnnotation? {
		didSet {
			configure()
		}
	}
	
	open func configure() {
		
		guard let annotation = annotation as? ClusterAnnotation else { return }
	
		self.frame = CGRect(x: 0, y: 0, width: bubleSize + (bubleOffset * 2), height: bubleSize + (bubleOffset * 2))
		self.backgroundColor = UIColor.clear
		
		let bubbleView = BubbleView(frame: CGRect(x: bubleOffset, y: bubleOffset, width: bubleSize, height: bubleSize + 5))
		self.addSubview(bubbleView)
		
		let imageSize: CGFloat = bubleSize - (offset * 2)
		self.imageView = UIImageView(frame: CGRect(x: offset + bubleOffset, y: offset + bubleOffset, width: imageSize, height: imageSize))
		self.imageView.setCorner(5)
		self.imageView.contentMode = .scaleAspectFill
		self.addSubview(self.imageView)
		
		if let fronAnnotation = annotation.annotations.first as? Annotation {
			self.imageView.image = fronAnnotation.image
		}
		
		let count = annotation.annotations.count
		countLabel.text = "\(count)"
		
		let labelContainerview = UIView()
		labelContainerview.backgroundColor = theme.photoTintColor
		labelContainerview.setCorner(5)
		self.addSubview(labelContainerview)
		labelContainerview.translatesAutoresizingMaskIntoConstraints = false
		labelContainerview.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		labelContainerview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		labelContainerview.heightAnchor.constraint(equalToConstant: 20).isActive = true
		labelContainerview.widthAnchor.constraint(equalToConstant: 25).isActive = true
		
		labelContainerview.addSubview(countLabel)
		countLabel.translatesAutoresizingMaskIntoConstraints = false
		countLabel.topAnchor.constraint(equalTo: labelContainerview.topAnchor).isActive = true
		countLabel.bottomAnchor.constraint(equalTo: labelContainerview.bottomAnchor).isActive = true
		countLabel.leadingAnchor.constraint(equalTo: labelContainerview.leadingAnchor).isActive = true
		countLabel.trailingAnchor.constraint(equalTo: labelContainerview.trailingAnchor).isActive = true
	}
}


