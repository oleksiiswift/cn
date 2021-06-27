//
//  Date+CurrentDate.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import Foundation

extension Date {
    
    static func getCurrentDate() -> Double {
        let date = Date()
        return date.timeIntervalSince1970
    }
}
