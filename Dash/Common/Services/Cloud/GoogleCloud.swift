//
//  GoogleCloud.swift
//  Dash
//
//  Created by Isaiah Wong on 9/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation

class GoogleCloud: CloudService {
    var key: String?
    var HOST: String
    
    enum GoogleCloudHost: String {
        case Speech = "speech.googleapis.com"
        case Vision = "https://vision.googleapis.com/v1/images:annotate?key="
    }
    
    init() {
        HOST = ""
    }
    
    static func configure() {
        // Extracts keys from plist
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let keys: NSDictionary? = NSDictionary(contentsOfFile: path)
            if let dict = keys {
                if let googleCloudKey = dict[KeyNames.CLOUD_DEV.rawValue] as? String {
                    SpeechAPI.speech().key = googleCloudKey
                    VisionAPI.vision().key = googleCloudKey
                }
            }
            return
        }
        print("\n Keys plist is missing. Please contact isaiah@jirehsoho.com \n")
    }
}
