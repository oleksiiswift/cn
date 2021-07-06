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
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)! as NSDate
    }
}
