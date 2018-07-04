//
//  Team.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

typealias UserWeakRef = WeakRef<User>

class Team: NSObject {
    
    // MARK: Properties
    private var _id: String
    private var _name: String
    private var _members: [UserWeakRef] = []
    private var _createdAt: Date
    private var _teamLeaderId: String
    
    var id: String {
        get {
            return self._id
        }
    }
    
    var name: String {
        get {
            return self._name
        }
        set {
            self._name = newValue
        }
    }
    
    var members: [UserWeakRef] {
        get {
            return self._members
        }
    }

    var createdAt: Date {
        get {
            return _createdAt
        }
    }
    
    var teamLeaderId: String {
        get {
            return self._teamLeaderId
        }
        
        set {
            self._teamLeaderId = newValue
        }
    }
    
    // MARK: Initializers
    // Initial team creation
    init(name: String, createdAt: Date, teamLeaderId: String) {
        self._id = ""
        self._name = name
        self._createdAt = createdAt
        self._teamLeaderId = teamLeaderId
    }
    
    // Retrieval
    init(id: String, name: String, createdAt: Date, teamLeaderId: String) {
        self._id = id
        self._name = name
        self._createdAt = createdAt
        self._teamLeaderId = teamLeaderId
    }
    
    // MARK: Methods
    class func getAllTeams(completion: @escaping (Team) -> Void) {
        guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).child("teams").observe(.childAdded)
        { (snapshot) in
            if !snapshot.exists() { return }
            let key = snapshot.key
            Database.database().reference().child("teams").child(key).observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() { return }
                guard let value = snap.value else {
                    print("error value")
                    return
                }
                let id = snap.ref.key
                let dict = value as! [String : Any]
                let createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double)
                let teamLeaderId = dict["teamLeaderId"] as! String
                let name = dict["name"] as! String
                completion(Team(id: id, name: name, createdAt: createdAt, teamLeaderId: teamLeaderId))
            })
        }
    }
    
    func create(completion: ((Bool) -> Void)?) {
        Database.database().reference()
            .child("teams")
            .childByAutoId()
                .setValue(self.map()) { (error, ref) in
                    self._id = ref.key
                    let value = [self._id : true]
                    Database.database().reference()
                        .child("users")
                        .child(self._teamLeaderId)
                        .child("teams")
                        .updateChildValues(value, withCompletionBlock: { (error, ref) in
                            var status = true
                            if error != nil {
                                status = false
                            }
                            if let completion = completion {
                                completion(status)
                            }
                        })
        }
    }
    
    func updateTeam(completion: ((Bool) -> Void)?) {
        
    }
    
    private func map() -> [String : Any] {
        return [
            "name" : self._name,
            "teamLeaderId" : self._teamLeaderId,
            "createdAt" : self._createdAt.timeIntervalSince1970
        ]
    }
}


