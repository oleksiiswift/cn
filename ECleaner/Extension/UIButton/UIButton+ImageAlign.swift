//
//  UIButton+ImageAlign.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit

extension UIButton {
    
    func setSpacing(spacing: CGFloat) {
        let inset = spacing / 2
        let direction = U.application.userInterfaceLayoutDirection
        let factor: CGFloat = direction == .leftToRight ? 1 : -1
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -inset * factor, bottom: 0, right: inset * factor)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: inset * factor, bottom: 0, right: -inset * factor)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func addLeftImageWithFixLeft(spacing: CGFloat, size: CGSize, image: UIImage) {
		removePreviousImage()
        addImageWithFix(spacing: spacing, isLeft: true, imageWidth: size.width, imageHeight: size.height, image: image)
    }
    
    func addRighttImageWithFixRight(spacing: CGFloat, size: CGSize, image: UIImage) {
		removePreviousImage()
        addImageWithFix(spacing: spacing, isLeft: false, imageWidth: size.width, imageHeight: size.height, image: image)
    }

    func addLeftImage(image: UIImage, size: CGSize, spacing: CGFloat) {
        addImage(image: image, imageWidth: size.width, imageHeight: size.height, spacing: spacing, isLeft: true)
    }
    
    
    func addRightImage(image: UIImage, size: CGSize, spacing: CGFloat) {
        addImage(image: image, imageWidth: size.width, imageHeight: size.height, spacing: spacing, isLeft: false)
    }
    
    func addCenterImage(image: UIImage, imageWidth: CGFloat, imageHeight: CGFloat, spacing: CGFloat = 0) {
        
        let imageView = UIImageView(image: image)
		imageView.tag = 100500
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: spacing).isActive = true
    }

    
    private func addImage(image: UIImage, imageWidth: CGFloat, imageHeight: CGFloat, spacing: CGFloat, isLeft: Bool) {
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        if isLeft {
            titleEdgeInsets.left += imageWidth
            imageView.trailingAnchor.constraint(equalTo: self.titleLabel!.leadingAnchor, constant: -spacing).isActive = true
            
        } else {
            titleEdgeInsets.right += imageWidth
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: spacing).isActive = true
        }
    
        imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
    }

    private func addImageWithFix(spacing: CGFloat, isLeft: Bool, imageWidth: CGFloat, imageHeight: CGFloat, image: UIImage) {

        let imageView = UIImageView(image: image)
        imageView.tag = 66613
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        if isLeft {
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing).isActive = true
        } else {
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: spacing).isActive = true
        }
        
        imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
    }
    
    public func hideTemporaryImage(_ hide: Bool) {
        
        if let imageView = self.subviews.first(where: {$0.tag == 66613}) as? UIImageView {
            imageView.isHidden = hide
        }
    }
	
	private func removePreviousImage() {
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) as? UIImageView {
			imageView.removeFromSuperview()
		}
	}
}

