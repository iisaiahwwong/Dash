//
//  WeakRef.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

class WeakRef<T> where T: AnyObject {
    
    private(set) var value: T?
    
    init(value: T?) {
        self.value = value
    }
}
