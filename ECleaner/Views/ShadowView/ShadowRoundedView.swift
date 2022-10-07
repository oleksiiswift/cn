//
//  ShadowRoundedView.swift
//  ECleaner
//
//  Created by alexey sorochan on 05.11.2021.
//

import UIKit

class ShadowRoundedView: UIView {
    
    let imageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
		self.setupUI()
		self.setupLayers()

    }
	
	public func setImage(_ image: UIImage?) {
		self.imageView.image = image
	}
	
	
	private func setupUI() {
		
		self.clipsToBounds = true
		self.layer.cornerRadius = self.frame.size.height / 2
		
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = self.frame.size.height / 2
		
		imageView.frame = self.bounds
		imageView.contentMode = .scaleToFill
		
		self.addSubview(imageView)
	}
	
	private func setupLayers() {
		
		switch theme {
				
			case .light:
				
				layer.applyShadow(color: theme.topShadowColor, alpha: 1.0, x: -9, y: -9, blur: 27, spread: 0)
				
				imageView.layer.applyShadow(color: theme.bottomShadowColor, alpha: 1.0, x: 9, y: 9, blur: 32, spread: 0)
				
			case .dark:
				self.backgroundColor = .clear
				imageView.backgroundColor = .clear
				
		}
	}
}
