//
//  SpeechControl.swift
//  Dash
//
//  Created by Isaiah Wong on 6/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation


enum SpeechCommand: String {
    case delete = "delete"
    case none = "none"
    case invalid = "invalid"
    
    func command() -> String {
        switch self {
        case .none:
            return "none"
        case .delete:
            return "delete"
        case .invalid:
            return "invalid"
        }
    }
    
    static func map(_ command: String) -> SpeechCommand {
        switch command {
        case SpeechCommand.none.rawValue:
            return .none
        case SpeechCommand.delete.rawValue:
            return .delete
        default:
            return .invalid
        }
    }
}

