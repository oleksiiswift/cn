//
//  Date+DateFormatter.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import Foundation

extension Date {
    
    func convertDateFormatterFromDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func convertDateFormatterFromSrting(stringDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = C.dateFormat.dateFormat
        
        if let date = dateFormatter.date(from: stringDate) {
            dateFormatter.dateFormat = C.dateFormat.dmy
            return dateFormatter.string(from: date)
        } else {
            return stringDate
        }
    }
    
    func convertDateFormatterToDisplayString(stringDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = C.dateFormat.dmy
        
        if let date = dateFormatter.date(from: stringDate) {
            dateFormatter.dateFormat = C.dateFormat.dateFormat
            return dateFormatter.string(from: date)
        } else {
            return stringDate
        }
    }
    
    func getDateFromString(stringDate: String, format: String = C.dateFormat.dateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let str = dateFormatter.date(from: stringDate) {
            return str
        } else {
            return nil
        }
    }
}
