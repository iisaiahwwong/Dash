//
//  NSNumber.swift
//  Countdown
//
//  Created by Isaiah Wong on 4/10/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import Foundation

extension NSNumber {
    func convertStringToDate() -> Date {
        return Date(timeIntervalSince1970: self.doubleValue)
    }
}
