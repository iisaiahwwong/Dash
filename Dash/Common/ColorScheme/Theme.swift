//
//  Theme.swift
//  Dash
//
//  Created by Isaiah Wong on 26/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

enum Theme {
    case Speech
}

// MARK: Speech Styling
enum ExtractStyle: String {
    case highlight = "highlight"
    case normal = "normal"
    case invalid = "invalid"
    
    static func map(_ style: String) -> ExtractStyle {
        switch style {
        case ExtractStyle.normal.rawValue:
            return .normal
        case ExtractStyle.highlight.rawValue:
            return .highlight
        default:
            return .invalid
        }
    }
}
