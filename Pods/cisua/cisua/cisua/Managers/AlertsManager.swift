//
//  UIAlertManager.swift
//  cisua
//
//  Created by admin on 28/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

internal class AlertsManager {
    
    class func show(title: String? = nil, message: String? = nil, action: String? = nil, completion: @escaping ((_ cancelled: Bool) -> ())) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(title: Localizator.cancel, style: .cancel) { (_) in
                completion(true)
            }
        )
        if let action = action {
            controller.addAction(
                UIAlertAction(title: Localizator.localize(action), style: .default) { (_) in
                    completion(false)
                }
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Utils.tryToPresentPendingController(controller)
        }
    }
    
    
}
