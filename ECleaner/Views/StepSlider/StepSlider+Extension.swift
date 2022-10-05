//
//  StepSlider+Extension.swift
//  ECleaner
//
//  Created by alexey sorochan on 14.04.2022.
//

import UIKit

extension StepSlider {
	
	public func addLeftLabel(with text: String, font: UIFont, color: UIColor, xOffset: CGFloat, yOffset: CGFloat) {
		
		let xDefaultOffset: CGFloat = 5
		let yDefaultOffset: CGFloat = 20
		
		let titleTextLabel = UILabel()
		titleTextLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
		titleTextLabel.font = font
		titleTextLabel.textColor = color
		titleTextLabel.textAlignment = .center
		titleTextLabel.text = text
		
		let width = titleTextLabel.intrinsicContentSize.width
		let height = titleTextLabel.intrinsicContentSize.height
		
		self.addSubview(titleTextLabel)

		titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
		
		titleTextLabel.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: xDefaultOffset + xOffset).isActive = true
		titleTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: yDefaultOffset + yOffset).isActive = true
		titleTextLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
		titleTextLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
		self.layoutIfNeeded()
	}
	
	public func addRightLabel(with text: String, font: UIFont, color: UIColor, xOffset: CGFloat, yOffset: CGFloat) {
		
		let xDefaultOffset: CGFloat = -5
		let yDefaultOffset: CGFloat = 20
		
		let titleTextLabel = UILabel()
		titleTextLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
		titleTextLabel.font = font
		titleTextLabel.textColor = color
		titleTextLabel.textAlignment = .center
		titleTextLabel.text = text
		
		let width = titleTextLabel.intrinsicContentSize.width
		let height = titleTextLabel.intrinsicContentSize.height
		
		self.addSubview(titleTextLabel)

		titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
		
		titleTextLabel.centerXAnchor.constraint(equalTo: self.rightAnchor, constant: xDefaultOffset + xOffset).isActive = true
		titleTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: yDefaultOffset + yOffset).isActive = true
		titleTextLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
		titleTextLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
		self.layoutIfNeeded()
	}
}
