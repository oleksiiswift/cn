//
//  UIViewController+Modal.swift
//  cisua
//
//  Created by Anton Litvinov on 3/4/19.
//

import UIKit

internal extension UIViewController {
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
    }
    
}
