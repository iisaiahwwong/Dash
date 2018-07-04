//
//  Dash.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

class Dash: NSObject {
    
    // MARK: Properties
    private var _id: String
    private var _title: String
    private var _dueDate: Date
    private var _dashDescription: String
    private var _team: Team?
    private var _createdAt: Date
    private var _countdown: Int
    private var _userId: String
    
    private var onlineUsersRef: DatabaseReference!
    private var onlineUserHandler: DatabaseHandle!
    private var connectionRef: DatabaseReference!
    private var connectionHandler: DatabaseHandle!
    
    var members: [User] = []
    
    var id: String {
        get {
            return self._id
        }
        set {
            self._id = newValue
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
    
    var dueDate: Date {
        get {
            return self._dueDate
        }
        set {
            self._dueDate = newValue
        }
    }
    
    var dashDescription: String {
        get {
            return self._dashDescription
        }
        set {
            self._dashDescription = newValue
        }
    }
    
    var team: Team? {
        get {
            return self._team
        }
        
        set {
            self._team = newValue
        }
    }
    
    var createdAt: Date {
        get {
            return self._createdAt
        }
    }
    
    var countdown: Int {
        get {
            guard let days = Date.getDifferenceInDays(first: Date(), second: self._dueDate) else {
                return 0
            }
            return days
        }
    }
    
    var userId: String {
        get {
            return self._userId
        }
        set {
            self._userId = newValue
        }
    }
    
    // MARK: Initializers
    init(title: String, dueDate: Date, dashDescription: String, createdAt: Date, userId: String) {
        self._id = ""
        self._title = title
        self._dueDate = dueDate
        self._dashDescription = dashDescription
        self._createdAt = createdAt
        self._countdown = 0
        self._userId = userId
    }
    
    init(id: String, title: String, dueDate: Date, dashDescription: String, createdAt: Date, userId: String, members: [String]) {
        self._id = id
        self._title = title
        self._dueDate = dueDate
        self._dashDescription = dashDescription
        self._createdAt = createdAt
        self._countdown = 0
        self._userId = userId
        super.init()
        self.retrieveUsers(members)
    }
    
    private func retrieveUsers(_ members: [String]) {
        for key in members {
            User.getUser(userId: key, { (user) in
                self.members.append(user)
            })
        }
    }
    
    // MARK: Methods
    class func getAllDash(completion: @escaping (Dash) -> Void) {
        guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        let dashRef = Database.database().reference().child("users").child(uid).child("dashs")
        dashRef.keepSynced(true)
        dashRef.observe(.childAdded)
        { (snapshot) in
            if !snapshot.exists() { return }
            let key = snapshot.key
            Database.database().reference().child("dashs").child(key).observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() { return }
                guard let value = snap.value else {
                    print("error value")
                    return
                }
                let id = snap.ref.key
                let dict = value as! [String : Any]
                let createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double)
                let dueDate = Date(timeIntervalSince1970: dict["dueDate"] as! Double)
                let description = dict["dashDescription"] as! String
                let userId = dict["userId"] as! String
                let title = dict["title"] as! String
                var membersKey: [String] = []
                if let dict = dict["members"] as? [String : Any] {
                    for tuple in dict {
                        membersKey.append(tuple.key)
                    }
                }
                completion(Dash(id: id, title: title, dueDate: dueDate, dashDescription: description, createdAt: createdAt, userId: userId, members: membersKey))
            })
        }
    }
    
    class func getAllSharedDash(completion: @escaping (Dash) -> Void) {
        guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        let shareDashRef = Database.database().reference().child("users").child(uid).child("dashs-share")
        shareDashRef.keepSynced(true)
        shareDashRef.observe(.childAdded)
        { (snapshot) in
            if !snapshot.exists() { return }
            let key = snapshot.key
            Database.database().reference().child("dashs").child(key).observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() { return }
                guard let value = snap.value else {
                    print("error value")
                    return
                }
                let id = snap.ref.key
                let dict = value as! [String : Any]
                let createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double)
                let dueDate = Date(timeIntervalSince1970: dict["dueDate"] as! Double)
                let description = dict["dashDescription"] as! String
                let userId = dict["userId"] as! String
                let title = dict["title"] as! String
                var membersKey: [String] = []
                if let dict = dict["members"] as? [String : Any] {
                    for tuple in dict {
                        membersKey.append(tuple.key)
                    }
                }
                completion(Dash(id: id, title: title, dueDate: dueDate, dashDescription: description, createdAt: createdAt, userId: userId, members: membersKey))
            })
        }
    }
    
    func create(completion: @escaping (Bool) -> Void) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        Database.database().reference().child("dashs").childByAutoId().setValue(self.map())
        { (error, ref) in
            let values = [ref.key: true]
            Database.database().reference().child("users").child(uid).child("dashs").updateChildValues(values, withCompletionBlock:
                { (error, _) in
                    if error == nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
            })
        }
    }
    
    func addMembers(userId: String, _ completion: ((User, Bool) -> Void)?) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        Database.database().reference().child("dashs").child(self._id).child("members").updateChildValues([userId: true]) { (error, ref) in
            Database.database().reference().child("users").child(userId).child("dashs-share").updateChildValues([self.id : true], withCompletionBlock: { (error, ref) in
                var status = false
                if error == nil {
                    status = true
                }
                User.getUser(userId: userId, { (user) in
                    self.members.append(user)
                    if let completion = completion {
                        completion(user, true)
                    }
                })
            })
        }
    }
    
    func observeOnlineMembers(_ completion: @escaping ([UserOnlineStatus]) -> (Void)) {
        guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        self.onlineUsersRef = Database.database().reference()
        self.onlineUserHandler = self.onlineUsersRef.child("dashs").child(self.id).child("presence").observe(.value, with: { (snapshot) in
            if !snapshot.exists() { return }
            var statusArray: [UserOnlineStatus] = []
            let dictArray = snapshot.value as! [String : Any]
            for status in dictArray {
                let userId = status.key
                let dict = status.value as! [String : Any]
                let connected = (dict["connected"] as! Int) == 1
                let userInitials = dict["userInitials"] as! String
                statusArray.append(UserOnlineStatus(userId: userId, userInitials: userInitials, connected: connected))
            }
            completion(statusArray)
        })
    }
    
    func removeObserverOnlineMembers() {
        guard let onlineUserRef = self.onlineUsersRef else {
            return
        }
        
        guard let onlineUserHandler = self.onlineUserHandler else {
            return
        }
        onlineUserRef.removeObserver(withHandle: onlineUserHandler)
    }
    
    func onConnect() {
        guard let user =  AuthProvider.auth().getCurrentUserModel() else {
            return
        }
        let dict = [
            user.id : [
                "connected" : true,
                "userInitials" : user.name.getInitials()
            ]
        ]
        self.connectionRef = Database.database().reference(withPath: ".info/connected")
        self.connectionHandler = self.connectionRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                Database.database().reference().child("dashs").child(self.id).child("presence").updateChildValues(dict)
            }
            else {
                Database.database().reference().child("dashs").child(self.id).child("presence").child(user.id).updateChildValues(["connected" : false])
            }
        })
    }
    
    func onDisconnect() {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        guard let connectionRef = self.connectionRef else {
            return
        }
        Database.database().reference().child("dashs").child(self.id).child("presence").child(uid).updateChildValues(["connected" : false])
        connectionRef.removeObserver(withHandle: self.connectionHandler)
    }
    
    private func map() -> [String : Any]{
        return [
            "title": self._title,
            "dueDate": self._dueDate.timeIntervalSince1970,
            "dashDescription": self._dashDescription,
            "createdAt": self._createdAt.timeIntervalSince1970,
            "userId": self._userId
        ]
    }
}
