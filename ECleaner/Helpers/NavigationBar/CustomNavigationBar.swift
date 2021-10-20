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
  @IBOutlet weak var leftBarButton: PrimaryButton!
  @IBOutlet weak var rightBarButton: PrimaryButton!
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
  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    addDropShadow()
//  }

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

//class PrimaryImageView: UIImageView {
//
//  let layer1 = CALayer(), layer2 = CALayer()
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//
//    image = I.navigationItems.settings
//
//    layer1.backgroundColor = UIColor().colorFromHexString("E9EFF2").cgColor
//    layer1.cornerRadius = 10
//    [layer1, layer2].forEach {
//      $0.masksToBounds = false
//      $0.frame = layer.bounds
//      layer.insertSublayer($0, at: 0)
//    }
//
//    layer.applySketchShadow(
//      color: .red,//UIColor().colorFromHexString("FFFFFF"),
//      alpha: 1.0,
//      x: -9,
//      y: -9,
//      blur: 27,
//      spread: 0)
//
//
//    layer2.applySketchShadow(
//      color: .black,//UIColor().colorFromHexString("A4B5C4"),
//      alpha: 1.0,
//      x: 9,
//      y: 9,
//      blur: 32,
//      spread: -1)
//  }
//}

class PrimaryButton: UIButton {

  let layer1 = CALayer(), layer2 = CALayer()
//  let primaryImageView = PrimaryImageView()

  override func layoutSubviews() {
    super.layoutSubviews()
    
//    imageView?.addSubview(primaryImageView) //= primaryImageView
    
    layer1.backgroundColor = UIColor().colorFromHexString("E9EFF2").cgColor
    layer1.cornerRadius = 10
    [layer1, layer2].forEach {
      $0.masksToBounds = false
      $0.frame = layer.bounds
      layer.insertSublayer($0, at: 0)
    }

    layer.applySketchShadow(
      color: UIColor().colorFromHexString("D1DAE8"),
      alpha: 1.0,
      x: 6,
      y: 6,
      blur: 10,
      spread: 0)

    layer2.applySketchShadow(
      color: UIColor().colorFromHexString("FFFFFF"),
      alpha: 1.0,
      x: -2,
      y: -5,
      blur: 19,
      spread: -1)
  }
}


