//
//  Chat.swift
//  Dash
//
//  Created by Isaiah Wong on 12/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

class Chat {
    // Properties
    var conversationId: String
    var fromId: String
    var text: String
    var timestamp: Date
    var toId: String
    
    init(conversationId: String, fromId: String, toId: String, text: String, timestamp: Date) {
        self.conversationId = conversationId
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
    }
    
    func chatPartnerId() -> String? {
        return self.fromId == Auth.auth().currentUser?.uid ? self.toId : fromId
    }
    
    func create(completion: @escaping (Bool) -> Void) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else { return }
        // Convert chat into dictionary
        let msgDict = map()
        // get convo from firebase
        Database.database().reference().child("users").child(uid).child("conversations").child(self.toId).observeSingleEvent(of: .value) { (snapshot) in
            // If convo does not exist create one
            if !snapshot.exists() {
                Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(msgDict, withCompletionBlock: { (error, ref) in
                    // gets convo id
                    let data = ["location": ref.parent!.key]
                    // Stores in users document for ref
                    Database.database().reference().child("users").child(uid).child("conversations").child(self.toId).updateChildValues(data)
                    Database.database().reference().child("users").child(self.toId).child("conversations").child(uid).updateChildValues(data)
                    completion(true)
                })
            }
            let data = snapshot.value as! [String: String]
            let location = data["location"]!
            Database.database().reference().child("conversations").child(location).childByAutoId().setValue(msgDict, withCompletionBlock: { (error, _) in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func map() -> [String : Any] {
        return [
            "fromId" : self.fromId,
            "toId" : self.toId,
            "text" : self.text,
            "timestamp" : self.timestamp.timeIntervalSince1970
        ]
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
                        Database.database().reference().child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data)
                        completion(true)
                    })
                }
            })
        }
    }
    
    // TODO: Database read writes
}


