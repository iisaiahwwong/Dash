//
//  SpeechActions.swift
//  Dash
//
//  Created by Isaiah Wong on 6/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

// Enum for SpeechVC Controls
enum SpeechAction {
    case record
    case stop
    case delete
    case createSection
    case highlight
    case endHighlight
    
    func name() -> String {
        switch self {
        case .record:
            return "record"
        case .stop:
            return "stop"
        case .delete:
            return "delete"
        case .createSection:
            return "createSection"
        case .highlight:
            return "highlight"
        case .endHighlight:
            return "endHighlight"
        }
    }
    
    func toggleRecordStop(_ action: SpeechAction) -> String {
        switch(action) {
        case .record:
            return "stop"
        case .stop:
            return "record"
        default:
            return ""
        }
    }
}


