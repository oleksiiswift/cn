//
//  Bundle+Version.swift
//  cisua
//
//  Created by admin on 04/04/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
