//
//  NLP.swift
//  Dash
//
//  Created by Isaiah Wong on 24/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias NLPCompletionHandler = (Any) -> (Void)

// MARK: NLP services hosted on EC2 
class NLP: CloudService {
    // MARK: Properties
    var key: String?
    var HOST: String
    
    // MARK: Instance
    private static let _nlpInstance = NLP()

    private init() {
        HOST = RemoteHost.IISAIAH.rawValue
    }
    
    // MARK: Shared Instance
    static func nlp() -> NLP {
        return self._nlpInstance
    }
    
    // MARK: Methods
    static func configure() {
        // TODO: authenticate
        
    }
    
    func analyseEntities(text: String, completion: @escaping NLPCompletionHandler) {
        let parameters: Parameters = [
            "text" : text
        ]
        Alamofire.request("https://www.iisaiah.com/nlp/analyseEntities", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { (response) in
                // Extract JSON
                var entities: [Entity] = []
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json {
                        let arrayNames = subJson["entities"].arrayValue.map({$0["name"].stringValue})
                        let arrayType = subJson["entities"].arrayValue.map({$0["type"].stringValue})
                        
                        for i in 0..<arrayNames.count {
                            entities.append(Entity(name: arrayNames[i], type: arrayType[i]))
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                completion(entities)
        }
    }
    
    func getNames(text: String) {
        let tags: [NSLinguisticTag] = [.personalName]
    }
    
    func analyseIntent(text: String, completion: @escaping NLPCompletionHandler) {
        let sentences = text.components(separatedBy: ".")
        guard let objectData = try? JSONSerialization.data(withJSONObject: sentences, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        let objectString = String(data: objectData, encoding: .utf8)
        let param: Parameters = [
            "query": objectString!
        ]
        Alamofire.request("https://www.iisaiah.com/lang", method: .post, parameters: param, encoding: JSONEncoding.default)
            .responseJSON { (response) in
                // Extract JSON
                var intents: [Intent] = []
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json {
                        let resolvedQuery = subJson["result"]["resolvedQuery"]
                        let fulfillment = subJson["result"]["fulfillment"]["speech"]
                        if !fulfillment.stringValue.isEmpty {
                            intents.append(Intent(fulfillment: fulfillment.stringValue, resolvedQuery: resolvedQuery.stringValue))
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                completion(intents)
        }
    }
}
