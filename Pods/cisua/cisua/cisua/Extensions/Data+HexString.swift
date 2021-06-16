//
//  Data+HexString.swift
//  cisua
//
//  Created by admin on 02/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

extension Data {
    func hexString() -> String {
        return self.reduce("") {
            $0 + String(format: "%02X", $1)
        }
    }
}
