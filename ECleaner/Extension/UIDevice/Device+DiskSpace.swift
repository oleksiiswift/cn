//
//  Device+DiskSpace.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import UIKit

extension UIDevice {
    
    func MBConverter(_ bytes: Int64) -> String {
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
}
