//
//  CGSize+pixel.swift
//  ECleaner
//
//  Created by alexey sorochan on 07.02.2022.
//

import UIKit

public extension CGSize {
	
	func toPixel() -> CGSize {
		let scale = UIScreen.main.scale
		return CGSize(width: self.width * scale, height: self.height * scale)
	}
}
