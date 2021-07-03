//
//  TimeIInterval.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import Foundation

extension Date {
    
    func secondsFromBeginningOfTheDay() -> TimeInterval {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60 + dateComponents.second!
        return TimeInterval(dateSeconds)
    }

    func timeOfDayInterval(toDate date: Date) -> TimeInterval {
        let date1Seconds = self.secondsFromBeginningOfTheDay()
        let date2Seconds = date.secondsFromBeginningOfTheDay()
        return date2Seconds - date1Seconds
    }
}
