//
//  Device.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import Foundation
import UIKit

public struct Device {
    
    /// return `true`for iPad
    static public var isiPad: Bool {
        return ( UIDevice.current.userInterfaceIdiom == .pad )
    }

    /// return `true` for iPhone-s
    static public var isPhone: Bool {
        return !isiPad
    }
    
    /// return if device has top notch
    static public var isSafeAreaDevice: Bool {
        
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        
        let safeAreaInsets = window.safeAreaInsets
        
        let hasSafeArea = (safeAreaInsets.top != 0 && safeAreaInsets.top != 20) || safeAreaInsets.bottom != 0 || safeAreaInsets.left != 0 || safeAreaInsets .right != 0
        
        return hasSafeArea
    }
    
    /// return `true` if iphone has top notch
    static public var isSafeAreaiPhone: Bool {
        return Device.isPhone && isSafeAreaDevice
    }
    
    /// return `true` if ipad didn't have borders
    static public var isSafeAreaiPad: Bool {
        return Device.isiPad && isSafeAreaDevice
    }
}

extension Device {
    
    static var freeDiskSpaceInBytes: Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
                return freeSpace!
            } catch {
                return 0
            }
        }
    }
    
    static public var totalDiskSpaceInGB: String {
		return U.getSpaceFromInt(self.totalDiskSpaceInBytes)
    }
        
    static public var freeDiskSpaceInGB: String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    static public var usedDiskSpaceInGB: String {
		return U.getSpaceFromInt(self.usedDiskSpaceInBytes)
    }
    
    static public var totalDiskSpaceInMB: String {
        return UIDevice().MBConverter(totalDiskSpaceInBytes)
    }
    
    static public var freeDiskSpaceInMB: String {
        return UIDevice().MBConverter(freeDiskSpaceInBytes)
    }
    
    static public var usedDiskSpaceInMB: String {
        return UIDevice().MBConverter(usedDiskSpaceInBytes)
    }
    
    
    static public var totalDiskSpaceInBytes: Int64 {
        get {
            do {
                guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                      let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
                return space
            }
        }
    }
    
    static public var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}
