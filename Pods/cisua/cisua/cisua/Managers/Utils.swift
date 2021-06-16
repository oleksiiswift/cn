//
//  Utils.swift
//  cisua
//
//  Created by admin on 10/01/2019.
//  Copyright © 2019 cisua. All rights reserved.
//

import Foundation

internal class Utils {
    
    internal class func cachesDirectory() -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        return documentDir.appendingPathComponent("cisuaads")
    }
    
    internal class func getTopViewController() -> UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    internal class func tryToPresentPendingController(_ controller: UIViewController) {
        if Utils.getTopViewController()?.presentationController?.description.contains("UIAlertControllerAlert") == false {
            Utils.getTopViewController()?.present(controller, animated: true, completion: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tryToPresentPendingController(controller)
            }
        }
    }
}
