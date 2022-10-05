//
//  CarouselItemView.swift
//  ECleaner
//
//  Created by alekseii sorochan on 21.07.2021.
//

import UIKit

class CarouselItemView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeWithNib()
    }

    convenience init(image: UIImage) {
        self.init()
        
        imageView.image = image
    }
    
    private func initializeWithNib() {
        
        Bundle.main.loadNibNamed(C.identifiers.xibs.carouselView, owner: self, options: nil)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
    }
}
