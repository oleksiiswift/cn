//
//  BorderedImageView.swift
//  Camera Translator
//
//  Created by iMac 10 on 07.10.2020.
//  Copyright © 2020 iMac 10. All rights reserved.
//

import UIKit

class BorderedImageView: UIImageView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureBorder()
  }
  
  override init(image: UIImage?) {
    super.init(image: image)
    configureBorder()
  }
  
  override init(image: UIImage?, highlightedImage: UIImage?) {
    super.init(image: image, highlightedImage: highlightedImage)
    configureBorder()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureBorder()
  }
  
  private func configureBorder() {
    layer.borderWidth = 0.5
    layer.borderColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 0.2).cgColor
  }
}
