//
//  String+NSDate.swift
//  ECleaner
//
//  Created by alexey sorochan on 21.06.2021.
//

import Foundation

extension String {
    
    func NSDateConverter(format: String) -> NSDate {
        let dateFormatter = DateFormatter()
        let callendar = Calendar.current
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = callendar.timeZone
        
        if let date = dateFormatter.date(from: self) as NSDate? {
            return date
        } else {
            
            let time = convertDateFormatter(fromFormat: format, toFormat: format + " a", self)
            return dateFormatter.date(from: time)! as NSDate
        }
    }
    
    
    func convertDateFormatter(fromFormat:String,toFormat:String,_ dateString: String) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = fromFormat
        let date = formatter.date(from: dateString)
        formatter.dateFormat = toFormat
        return  date != nil ? formatter.string(from: date!) : ""
    }
}
