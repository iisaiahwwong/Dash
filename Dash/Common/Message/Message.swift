//
//  Message.swift
//  Dash
//
//  Created by Isaiah Wong on 6/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

enum Message {
    case googleabandon
    func description() -> String {
        switch self {
        case .googleabandon:
            return "Google has Abandon Us."
        }
    }
}
