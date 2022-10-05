//
//  UpdateColorsProtocolol.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import Foundation

typealias Themeble = UpdateColorsDelegate & ThemeObservingDelegate

protocol ThemeObservingDelegate: AnyObject {}

protocol UpdateColorsDelegate {
    func updateColors()
}

extension ThemeObservingDelegate {
    
    func addColorThemeObserver(notificationCenter: NotificationCenter = U.notificationCenter) {
        notificationCenter.addObserver(forName: .colorDidChange, object: nil, queue: nil) { [weak self] _ in
            if let updatebleObject = self as? UpdateColorsDelegate {
                updatebleObject.updateColors()
            }
        }
    }
    
    func removeThemeObserver(notificationCenter: NotificationCenter = U.notificationCenter) {
        notificationCenter.removeObserver(self, name: .colorDidChange, object: nil)
    }
}




