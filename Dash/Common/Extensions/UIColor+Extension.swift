//
//  UIColor.swift
//  Countdown
//
//  Created by Isaiah Wong on 28/9/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat , b: CGFloat , a: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    public class func darkOrange() -> UIColor {
        return UIColor.init(r: 255.0 / 255.0, g: 81.0 / 255.0, b: 0.0, a: 1.0)
    }
    
    public class func darkGreen() -> UIColor {
        return UIColor.init(r: 81.0 / 255.0, g: 149.0 / 255.0, b: 156.0 / 255.0, a: 1.0)
    }
    
    public class func lightGreen() -> UIColor {
        return UIColor.init(r: 230.0 / 255.0, g: 237.0 / 255.0, b: 237.0 / 255.0, a: 1.0)
    }
    
    public class func darkYellow() -> UIColor {
        return UIColor.init(r: 250.0 / 255.0, g: 181.0 / 255.0, b: 27.0 / 255.0, a: 1.0)
    }
}
