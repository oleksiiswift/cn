//
//  CustomNavigationBar.swift
//  CustomNavigationBar
//
//  Created by iMac_1 on 18.10.2021.
//

import UIKit

protocol CustomNavigationBarDelegate: AnyObject {
    
    func didTapLeftBarButton(_sender: UIButton)
    func didTapRightBarButton(_sender: UIButton)
}

class CustomNavigationBar: UIView {
    
    var className: String {
        return "CustomNavigationBar"
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftBarButton: PrimaryButton!
    @IBOutlet weak var rightBarButton: PrimaryButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: CustomNavigationBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
        
        leftBarButton.addTarget(self, action: #selector(didTapLeftBarButton(sender:)), for: .touchUpInside)
        rightBarButton.addTarget(self, action: #selector(didTapRightBarButton(sender:)), for: .touchUpInside)
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
    }
    
    func setUpNavigation(title: String?, leftImage: UIImage?, rightImage: UIImage?) {
        
        if let title = title {
            titleLabel.isHidden = false
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }
        
        if let rightImage = rightImage {
            rightBarButton.isHidden = false
            rightBarButton.setImage(rightImage, for: .normal)
        } else {
            rightBarButton.isHidden = true
        }
        
        if let leftImage = leftImage {
            leftBarButton.isHidden = false
            leftBarButton.setImage(leftImage, for: .normal)
        } else {
            leftBarButton.isHidden = true
        }
    }
    
    @objc func didTapLeftBarButton(sender: UIButton) {
        delegate?.didTapLeftBarButton(_sender: sender)
    }
    
    @objc func didTapRightBarButton(sender: UIButton) {
        delegate?.didTapRightBarButton(_sender: sender)
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


