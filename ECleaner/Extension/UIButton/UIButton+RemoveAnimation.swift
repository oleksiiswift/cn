//
//  UIButton+RemoveAnimation.swift
//  ECleaner
//
//  Created by alekseii sorochan on 30.06.2021.
//

import UIKit

extension UIButton {
    func setTitleWithoutAnimation(title: String?) {
        
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)

        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}
