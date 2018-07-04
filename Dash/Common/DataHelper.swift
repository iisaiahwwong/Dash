//
//  DataHelper.swift
//  SmartHealth
//
//  Created by Isaiah Wong on 1/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

class DataHelpers {
    
    func normalize(_ values: [Double?]) -> [Double] {
        let valuesWithDefaults = values.map({ (value) -> Double in
            guard let value = value else { return 0.0 }
            return value
        })
        
        guard let maxValue = valuesWithDefaults.max() , maxValue > 0.0 else {
            return valuesWithDefaults
        }
        
        return valuesWithDefaults.map({$0 / maxValue})
    }
    
}

