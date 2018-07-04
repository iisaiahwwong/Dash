//
//  Entity.swift
//  Dash
//
//  Created by Isaiah Wong on 24/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

class Entity {
    var name: String
    var type: String
    
    init() {
        self.name = ""
        self.type = ""
    }
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}
