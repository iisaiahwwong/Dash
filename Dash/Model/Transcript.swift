//
//  Transcript.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

class Transcript {
    
    // MARK: Properties
    private var _id: String
    private var _title: String
    private var _dashId: String
    private var _userId: String
    private var _dateCreated: Date
    private var _lastModified: Date
    
    var extractReference: DatabaseReference?
    var extractHandle: DatabaseHandle?
    
    var extracts: [Extract] = [] {
        didSet {
            updateExtracts(nil)
        }
    }
    
    // Binds search query extract to this 
    var extractSearchHelper: [Extract : Bool] = [:]
    
    static var transcriptCount: UInt = 0
    
    var id: String {
        get {
            return self._id
        }
    }
    
    var title: String {
        get {
            return self._title
        }
        set {
            self._title = newValue
        }
    }
    
    var dateCreated: Date {
        get {
            return self._dateCreated
        }
    }
    
    var lastModified: Date{
        get{
            return _lastModified
        }
        set {
            self._lastModified = newValue
        }
    }
    
    // MARK: Initializers
    init(dashId: String) {
        self._id = ""
        self._title = ""
        self._dashId = dashId
        self._userId = ""
        self._dateCreated = Date()
        self._lastModified = Date()
    }
    
    init(id: String, dashId: String) {
        self._id = id
        self._title = ""
        self._dashId = dashId
        self._userId = ""
        self._dateCreated = Date()
        self._lastModified = Date()
    }
    
    init(id: String, dashId: String, title: String, userId: String, extracts: [Extract]?, dateCreated: Date, lastModified: Date) {
        self._id = id
        self._title = title
        self._dashId = dashId
        self._userId = userId
        self.extracts = extracts ?? []
        self._dateCreated = dateCreated
        self._lastModified = lastModified
    }
    
    func create(completion: ((Bool) -> Void)?) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        self._userId = uid
        // TODO: Create a new section for transcript if dash id is not empty
        let values = smallMap()
        Database.database().reference()
            .child("dashs")
            .child("transcripts")
            .childByAutoId()
            .setValue(values) { (error, ref) in
                self._id = ref.key
                let value = [self._id : true]
                if self._dashId.isEmpty {
                    return
                }
                Database.database().reference().child("dashs").child(self._dashId).child("transcripts").updateChildValues(value)
                if let completion = completion {
                    completion(true)
                }
        }
    }
    
    // changed to get once only
    class func getAllTranscripts(dashId: String, completion: @escaping (Transcript) -> Void) {
        let transcriptRef = Database.database().reference().child("dashs").child(dashId).child("transcripts")
        transcriptRef.keepSynced(true)
        transcriptRef.observe(.childAdded) { (snapshot) in
                if !snapshot.exists() { return }
                Transcript.transcriptCount += 1
                let key = snapshot.key
                Database.database().reference()
                    .child("dashs")
                    .child("transcripts")
                    .child(key)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() { return }
                        guard let value = snapshot.value else {
                            return
                        }
                        let dict = value as! [String : Any]
                        let id = snapshot.ref.key
                        let title = dict["title"] as! String
                        let userId = dict["userId"] as! String
                        let dateCreated = Date(timeIntervalSince1970: dict["dateCreated"] as! Double)
                        let lastModified = Date(timeIntervalSince1970: dict["lastModified"] as! Double)
                        let extracts = dict["extracts"] as? [String : Any]
                        var extractArray: [Extract] = []
                        if let arr = extracts {
                            for item in arr {
                                let dict = item.value as! [String : Any]
                                extractArray.append(
                                    Extract.interpolate(id: item.key, dict: dict)
                                )
                            }
                        }
                        
                        let transcript = Transcript(id: id, dashId: dashId, title: title, userId: userId, extracts: extractArray, dateCreated: dateCreated, lastModified: lastModified)
                        completion(transcript)
                    })
        }
    }
    
    func observeExtracts(completion: @escaping (Extract) -> Void) {
        self.extractReference = Database.database().reference()
            .child("dashs")
            .child("transcripts")
            .child(self._id)
            .child("extracts")
        self.extractReference?.keepSynced(true)
        self.extractHandle =  self.extractReference?.observe(DataEventType.childAdded, with: { (snapshot) in
            guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else { return }
            if !snapshot.exists() { return }
            guard let value = snapshot.value else {
                return
            }
            let dict = value as! [String : Any]
            let id = snapshot.key
            let extract = Extract.interpolate(id: id, dict: dict)
            if extract.userId != uid {
                completion(extract)
            }
        })
    }
    
    func removeObserverExtract() {
        guard let extractRef = self.extractReference else {
            return
        }
        guard let extractHandle = self.extractHandle else {
            return
        }
        extractRef.removeObserver(withHandle: extractHandle)
    }
    
    /** Updates Last inserted transcript */
    func updateExtracts(_ completion: ((Bool) -> Void)?) {
        guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        self._userId = uid
        let extract = self.extracts[self.extracts.count - 1]
        let values = extract.map()
        // TODO: change key to timestamp
        Database.database().reference()
            .child("dashs")
            .child("transcripts")
            .child(self._id)
            .child("extracts")
            .childByAutoId()
            .setValue(values) { (error, ref) in
                if error != nil {
                    return
                }
                self.extracts[self.extracts.count - 1].id = ref.key
                Database.database().reference()
                    .child("dashs")
                    .child("transcripts")
                    .child(self._id)
                    .updateChildValues(["lastModified": Date().timeIntervalSince1970])
                
                // Update Key for extracts
                if let completion = completion {
                    completion(true)
                }
        }
    }
    
    /** Updates title on change */
    func updateTitle(_ completion: ((Bool) -> Void)?) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        self._userId = uid
        // TODO: change key to timestamp
        Database.database().reference()
            .child("dashs")
            .child("transcripts")
            .child(self._id)
            .updateChildValues(["title" : self._title, "lastModified": Date().timeIntervalSince1970]) { (error, ref) in
                guard let completion = completion else {
                    return
                }
                completion(true)
        }
    }
    
    func deletePrevious(extracts: inout [Extract]) {
        // Remove previous extract
        extracts.removeLast()
        // Remove previous extract
        let toBeDeleted = self.extracts.removeLast()
        print(toBeDeleted)
        
        deleteExtract(toBeDeleted.id)
    }
    
    func deleteExtract(_ id: String) {
        Database.database().reference()
            .child("dashs")
            .child("transcripts")
            .child(self.id)
            .child("extracts")
            .child(id).removeValue()
    }
    
    func smallMap() -> [String : Any] {
        if self._title.isEmpty {
            self._title = "Transcript \(Transcript.transcriptCount)"
        }
        return [
            "title" : self._title,
            "dateCreated" : self._dateCreated.timeIntervalSince1970,
            "lastModified" : self._lastModified.timeIntervalSince1970,
            "dashId" : self._dashId,
            "userId" : self._userId
        ]
    }
}
