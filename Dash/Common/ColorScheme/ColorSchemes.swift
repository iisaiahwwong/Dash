//
//  ColorSchemes.swift
//  Dash
//
//  Created by Isaiah Wong on 26/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

// Extenstion which specifies color scheme through out the application
extension UIColor {
    struct Palette {
        static let greyishWhite = UIColor(r: 248.0, g: 248.0, b: 248.0, a: 1.0)
        static let green = UIColor(r: 83.0, g: 238.0, b: 179.0, a: 1.0)
        static let lightGreen = UIColor(r: 5.0, g: 221, b:187, a: 1.0)
        static let dullBlue = UIColor(r: 67, g: 124, b: 181, a: 1.0)
        static let blue = UIColor(r: 95, g: 123, b: 251, a: 1.0)
        static let lightBlue = UIColor(r: 241, g: 249, b: 255, a: 1.0)
        static let orange = UIColor(r: 254, g: 209, b: 177, a: 1.0)
        static let lightGrey = UIColor(r: 248, g: 248, b: 248, a: 1.0)
    }
    
    struct ColorProfileFix {
        static let blue = UIColor(r: 75, g: 91, b: 254, a: 1.0)
    }
    
    struct Background {
        static let grey = UIColor(r: 248.0, g: 248.0, b: 248.0, a: 1.0)
        static let white =  UIColor(r: 255, g: 255.0, b: 255.0, a: 1.0)
    }
    
    struct Button {
        static let normal = UIColor(r: 95.0, g: 123.0, b: 251.0, a: 1.0)
        static let highlight = UIColor(r: 83.0, g: 238.0, b: 179.0, a: 1.0)
        static let assertive = UIColor(r: 255.0, g: 117.0, b: 161.0, a: 1.0)
    }
    
    // System Main Color
    struct PurpleBlue {
        // Purple
        static let upperBound = UIColor(r: 135.0, g: 98.0, b: 250.0, a: 1.0)
        // Blue
        static let lowerBound = UIColor(r: 95, g: 123, b: 251, a: 1.0)
    }
    
    struct PurplePink {
        // Purple
        static let upperBound = UIColor(r: 107.0, g: 122.0, b: 245.0, a: 1.0)
        // Pink
        static let lowerBound = UIColor(r: 235.0, g: 121.0, b: 204.0, a: 1.0)
    }
    
    struct PinkOrange {
        // Pink 
        static let upperBound = UIColor(r: 255, g: 110, b: 169, a: 1.0)
        // Orange
        static let lowerBound = UIColor(r: 255, g: 145, b: 131, a: 1.0)
    }
}



