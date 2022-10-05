//
//  NavigationBarDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.11.2021.
//

import Foundation
import UIKit

protocol StartingNavigationBarDelegate: AnyObject {
    
    func didTapLeftBarButton(_sender: UIButton)
    func didTapRightBarButton(_sender: UIButton)
}

protocol NavigationBarDelegate: AnyObject {
    
    func didTapLeftBarButton(_ sender: UIButton)
    func didTapRightBarButton(_ sender: UIButton)
}


protocol PremiumNavigationBarDelegate: AnyObject {
	
	func didTapLeftBarButton(_sender: UIButton)
	func didTapRightBarButton(_sender: UIButton)
}
