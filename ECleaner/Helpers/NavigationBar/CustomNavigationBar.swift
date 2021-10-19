//
//  CustomNavigationBar.swift
//  CustomNavigationBar
//
//  Created by iMac_1 on 18.10.2021.
//

import UIKit

class CustomNavigationBar: UIView {
  
  var className: String {
    return "CustomNavigationBar"
  }

  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var leftBarButton: UIButton!
  @IBOutlet weak var rightBarButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.load()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.load()
  }
  
  func load() {
    
    Bundle.main.loadNibNamed(self.className, owner: self, options: nil)
  }

  func configure() {
    
    containerView.backgroundColor = .clear
    backgroundColor = .clear
    addSubview(self.containerView)
    containerView.frame = self.bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    leftBarButton.clipsToBounds = true
    leftBarButton.layer.cornerRadius = 10
    
    rightBarButton.clipsToBounds = true
    rightBarButton.layer.cornerRadius = 10
    
//    titleLabel.font = UIFont(font: FontManager.robotoBlack, size: 16.0)
  }
  
  func setUpNavigation(title: String, leftImage: UIImage, rightImage: UIImage) {
    
    titleLabel.text = title
    leftBarButton.setImage(leftImage, for: .normal)
    rightBarButton.setImage(rightImage, for: .normal)
  }


}
