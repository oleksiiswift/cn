//
//  PHAssetAnnotationView.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import MapKit

class PHAssetAnnotationView: MKAnnotationView {
	
	private var imageView: UIImageView!
	
	public var delegate: AnnotationViewSelectDelegate?
	
	override var image: UIImage? {
		get {
			return self.imageView.image
		} set {
			self.imageView.image = newValue
		}
	}
	
	let bubleSize: CGFloat = 70
	let offset: CGFloat = 3
	
	var lineWidth:    CGFloat = 1
	var cornerRadius: CGFloat = 10
	var triangleSize: CGFloat = 5
	var fillColor:    UIColor = .clear
	var strokeColor:  UIColor = .clear
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		
		configure()
	}
		
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		
		self.frame = CGRect(x: 0, y: 0, width: bubleSize, height: bubleSize + 5)
		self.backgroundColor = .clear
		
		let bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: bubleSize, height: bubleSize + 5))
		self.addSubview(bubbleView)
		bubbleView.translatesAutoresizingMaskIntoConstraints = false
		bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
 
		let imageSize: CGFloat = bubleSize - (offset * 2)
		self.imageView = UIImageView(frame: CGRect(x: offset, y: offset, width: imageSize, height: imageSize))
		self.imageView.contentMode = .scaleAspectFill
		self.imageView.setCorner(5)
		self.addSubview(self.imageView)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapSelectAnnotation))
		self.addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc func didTapSelectAnnotation() {
		self.delegate?.didSelectClusterAnnotation(self)
	}
}
