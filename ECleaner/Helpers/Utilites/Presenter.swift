//
//  Presenter.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

typealias P = UIHelperPresenter
open class UIHelperPresenter {
    
    public static func showIndicator(in viewController: UIViewController?) {
        
        CustomActivityIndicator.showActivityIndicator(ifNeedPresentCoontroller: viewController)
    }
    
    public static func showIndicator() {
        
        CustomActivityIndicator.showActivityIndicator()
    }
    
    public static func hideIndicator() {
        
        CustomActivityIndicator.hideActivityIndicator()
    }
}
