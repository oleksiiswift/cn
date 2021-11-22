//
//  CarouselCollectionViewCell.swift
//  ECleaner
//
//  Created by alekseii sorochan on 19.07.2021.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView = UIImageView()
    private lazy var selectedAssetView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
}

//  MARK: - setup ui -
extension CarouselCollectionViewCell {
    
    private func setupUI() {
        
        self.backgroundColor = .clear
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
    }
}

//      MARK: - cell configure -
extension CarouselCollectionViewCell {
    
    public func configureCell(image: UIImage?) {
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
    }
}

