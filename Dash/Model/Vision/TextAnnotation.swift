//
//  TextAnnotation.swift
//  Dash
//
//  Created by Isaiah Wong on 30/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import Foundation

struct TextAnnotation {
    var description: String
    var boundingPoly: BoundingPoly?
    
    func map() -> [String : Any] {
        return [
            "description" : self.description,
        ]
    }
}

struct BoundingPoly {
    var vertices: [Vertices]
}

struct Vertices {
    var x: Double
    var y: Double
}
