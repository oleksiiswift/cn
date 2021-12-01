//
//  UIFont+Extension.swift
//  UIFont+Extension
//
//  Created by iMac_1 on 18.10.2021.
//

import UIKit

extension UIFont {
    /// Create a UIFont object with a `Font` enum
  public convenience init?(font: FontManager, size: CGFloat) {
    let fontIdentifier: String = font.rawValue
    self.init(name: fontIdentifier, size: size)
  }
}
