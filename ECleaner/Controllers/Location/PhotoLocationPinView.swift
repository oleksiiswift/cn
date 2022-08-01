//
//  PhotoLocationPinView.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.08.2022.
//

import UIKit
import MapKit


class PhotoLocationPinView: MKPointAnnotation {
	

	@IBOutlet weak var baseView: UIView!
	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

	
	var imageName: String!
	var image: UIImage!
}
