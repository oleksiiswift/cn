//
//  CALayer+Position.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import UIKit

extension CALayer {

   func bringToFront() {
	  guard let sLayer = superlayer else {
		 return
	  }
	  removeFromSuperlayer()
	  sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
   }

   func sendToBack() {
	  guard let sLayer = superlayer else {
		 return
	  }
	  removeFromSuperlayer()
	  sLayer.insertSublayer(self, at: 0)
   }
}

