//
//  UIDevice+Enviroment.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit

extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}
