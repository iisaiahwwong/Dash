//
//  User.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

enum Gender: Int {
    case male = 0
    case female = 1
    case unknown = -1
    
    var description: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .unknown: return "Unknown"
        }
    }
    
    static func map(_ gender: String) -> Gender{
        switch gender.lowercased() {
        case "male":
            return .male
        case "female":
            return .female
        default:
            return .unknown
        }
    }
    
    static let count = 2
}

struct UserOnlineStatus {
    var userId: String
    var userInitials: String
    var connected: Bool
}


class User: NSObject {
    
    // MARK: Properties
    private var _id: String
    private var _firstname: String
    private var _lastname: String
    private var _name: String
    private var _email: String
    private var _team: Team?
    private var _createdAt: Date
    private var _dateOfBirth: Date
    private var _gender: Gender
    
    var id: String {
        get {
            return self._id
        }
    }
    
    var firstname: String {
        get {
            return self._firstname
        }
        
        set {
            self._firstname = newValue
        }
    }
    
    var lastname: String {
        get {
            return self.lastname
        }
        
        set {
            self._lastname = newValue
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
    
    
    var email: String {
        get {
            return self._email
        }
        
        set {
            self._email = newValue
        }
    }
    
    var gender: Gender {
        get {
            return self._gender
        }
        set {
            self._gender = newValue
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
    
//    var createdAt: Date {
//        get {
//            return _createdAt
//        }
//    }
    
    init(id: String, name: String, email: String, dateOfBirth: Date, gender: Gender, createdAt: Date) {
        self._id = id
        self._firstname = ""
        self._lastname = ""
        self._dateOfBirth = dateOfBirth
        self._name = name
        self._gender = gender
        self._email = email
        self._createdAt = createdAt
    }
    
    init(id: String, firstname: String, lastname: String, email: String, createdAt: Date, dateOfBirth: Date, gender: Gender) {
        self._id = id
        self._firstname = firstname
        self._lastname = lastname
        self._name = "\(firstname) \(lastname)"
        self._email = email
        self._createdAt = createdAt
        self._dateOfBirth = dateOfBirth
        self._gender = gender
    }
    
    deinit {
        self._team = nil
    }
    
    // MARK: Methods
    class func getAllEmails(_ completion: @escaping ([String : Any]) -> Void) {
        Database.database().reference().child("emails").observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() { return }
            let dict = snapshot.value as! [String : Any]
            completion(dict)
        }
    }
    
    class func getUser(userId: String,_ completion: @escaping (User) -> Void) {
        Database.database()
            .reference()
            .child("users")
            .child(userId)
            .child("credentials")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() { return }
                guard let value = snapshot.value else {
                    return
                }
                let id = userId
                let dict = value as! [String : Any]
                let createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double)
                let dateOfBirth = Date(timeIntervalSince1970: dict["dateOfBirth"] as! Double)
                let email = dict["email"] as! String
                let gender = Gender.map(dict["gender"] as! String)
                let name = dict["name"] as! String
                let user = User(id: id, name: name, email: email, dateOfBirth: dateOfBirth, gender: gender, createdAt: createdAt)
                completion(user)
            })
    }
    
    // TODO:
    func createSession() {
        
    }
}
