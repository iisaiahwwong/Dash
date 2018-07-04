//
//  NSDate.swift
//  Countdown
//
//  Created by Isaiah Wong on 29/9/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self)
    }
    
    //Method for different format Dates
    //K: Might be redundant method, remove if see fit.
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static func getDifferenceInDays(first: Date, second: Date) -> Int? {
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: first)
        let date2 = calendar.startOfDay(for: second)
        return calendar.dateComponents([.day], from: date1, to: date2).day
    }
}
