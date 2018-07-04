//
//  Intent.swift
//  Dash
//
//  Created by Isaiah Wong on 25/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import SwiftyJSON

class Intent {
    var fulfillment: String
    var resolvedQuery: String
    var highlightRange: NSRange?
    
    init() {
        self.fulfillment = ""
        self.resolvedQuery = ""
    }
    
    init(fulfillment: String, resolvedQuery: String) {
        self.fulfillment = fulfillment
        self.resolvedQuery = resolvedQuery
    }
    
    class func dictionaryToArray(_ intents: [Intent]) -> [[String : Any]] {
        var arr: [[String : Any]] = []
        for intent in intents {
            arr.append(intent.map())
        }
        return arr
    }
    
    func map() -> [String : Any] {
        return [
            "fulfilment" : self.fulfillment,
            "resolvedQuery": self.resolvedQuery
        ]
    }
}
