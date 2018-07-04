//
//  Stack.swift
//  Dash
//
//  Created by Isaiah Wong on 5/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

struct Stack<Element> {
    fileprivate var array: [Element] = []
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    func peek() -> Element? {
        return array.last
    }
}
