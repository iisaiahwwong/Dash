//
//  Keys.swift
//  Dash
//
//  Created by Isaiah Wong on 8/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

enum KeyNames: String {
    case CLOUD_DEV = "GOOGLE_CLOUD_DEV"
}

enum RemoteHost: String {
    case IISAIAH = "https://iisaiah.com/nlp"
}

protocol CloudService {
    var key: String? { get }
    var HOST: String { get }
    
    func connect() -> Bool
    func configure()
}

extension CloudService {
    func connect() -> Bool {
        print("Warning! Function has not been implemented")
        return false
    }
    func configure() {}
}


