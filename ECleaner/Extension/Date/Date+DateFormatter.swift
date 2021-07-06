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
        dateFormatter.timeZone = .current
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        let epochDate = date.timeIntervalSince1970
        let timeZoneEpochOffset = (epochDate + Double(timeZoneOffset))
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timeZoneEpochOffset).endOfDay
        return dateFormatter.string(from: timeZoneOffsetDate)
    }
    
    func convertDateFormatterFromSrting(stringDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = C.dateFormat.dateFormat
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: stringDate) {
            dateFormatter.dateFormat = C.dateFormat.fullDmy
            let timeZoneOffset = TimeZone.current.secondsFromGMT()
            let epochDate = date.timeIntervalSince1970
            let timeZoneEpochOffset = (epochDate + Double(timeZoneOffset))
            let timeZoneOffsetDate = Date(timeIntervalSince1970: timeZoneEpochOffset)
            dateFormatter.string(from: timeZoneOffsetDate)
            return dateFormatter.string(from: timeZoneOffsetDate)
        } else {
            return stringDate
        }
    }
    
    func convertDateFormatterToDisplayString(stringDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = C.dateFormat.fullDmy
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: stringDate) {
            dateFormatter.dateFormat = C.dateFormat.dateFormat
            return dateFormatter.string(from: date)
        } else {
            return stringDate
        }
    }
    
    func getDateFromString(stringDate: String, format: String = C.dateFormat.fullDmy) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = .current
        
        if let str = dateFormatter.date(from: stringDate) {
            let timeZoneOffset = TimeZone.current.secondsFromGMT()
            let epochDate = str.timeIntervalSince1970
            let timeZoneEpochOffset = (epochDate + Double(timeZoneOffset))
            let timeZoneOffsetDate = Date(timeIntervalSince1970: timeZoneEpochOffset).endOfDay
            return timeZoneOffsetDate
        } else {
            return nil
        }
    }
}

extension Date {

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
   }

    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}

