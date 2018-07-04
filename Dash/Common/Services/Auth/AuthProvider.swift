//
//  AuthProvider.swift
//  SmartHealth
//
//  Created by Isaiah Wong on 29/10/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?, _ user: FirebaseAuth.User?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address"
    static let EMAIL_ALREADY_IN_USE = "Email Already in Use"
    static let CONNECTION_ERROR = "Problem Connecting to Internet"
    static let USER_NOT_FOUND = "Invalid Email or Password"
    static let WEAK_PASSWORD = "Password Should be 6 Characters Long"
}

class AuthProvider {
    
    private static let _instance = AuthProvider()
    
    private var user: User?
    
    private init() { }
    
    static func auth() -> AuthProvider {
        return self._instance
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func getCurrentUserModel() -> User? {
        return self.user
    }
    
    func interpolateUser(userId: String, completion: ((_ user: User?) -> Void)?) {
        User.getUser(userId: userId) { (user) in
            self.user = user
        }
    }
    
    func login(withEmail email: String, password: String, completion: LoginHandler?) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak weakSelf = self] (user, err)  in
            if err != nil {
                self.handleErrors(err: (err as NSError?)!, completion: completion)
                return
            }
            guard let user = user else {
                return
            }
            completion?("success", user)
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    func register(name: String, email: String, gender: String, dateOfBirth: Date?, password: String, profileImg: UIImage?, completion: @escaping (Bool, Any?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(false, error!)
                return
            }
            user?.sendEmailVerification(completion: nil)
            let createdAt: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            let dateOfBirthUNIX: NSNumber = NSNumber(value: Int((dateOfBirth?.timeIntervalSince1970)!))
            
            // TODO: Add more properties
            let values: [String: Any] = [
                "name": name,
                "email": email,
                "gender": gender,
                "dateOfBirth": dateOfBirthUNIX,
                "profileImgURL": "",
                "createdAt": createdAt
            ]
            Database.database().reference().child("users").child(user!.uid).child("credentials").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    completion(false, error!)
                    return
                }
                // TODO: handle completion
                Database.database().reference().child("emails").childByAutoId().setValue(["userId" : user!.uid, "email" : email])
                completion(true, nil)
            })
            
            // TODO remvoe conditional block and set default user profile pic
            // storing Profile Image in Database
// START
//            let storageRef = Storage.storage().reference().child("profileImage").child(user!.uid)
//            let imageData = UIImageJPEGRepresentation(profileImg!, 0.1)
//            storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
//                if error != nil {
//                    // Recursive ?
//                    completion(false, error!)
//                    return
//                }
//
//                let path = metadata?.downloadURL()?.absoluteString
//            })
// END
        }
    }
    
    private func handleErrors(err: NSError, completion: LoginHandler?) {
        guard let errCode = AuthErrorCode(rawValue: err.code) else {
            return
        }
        switch errCode {
        case .wrongPassword, .userNotFound:
            completion?(LoginErrorCode.USER_NOT_FOUND, nil)
            
        case .invalidEmail:
            completion?(LoginErrorCode.INVALID_EMAIL, nil)
            
        case .emailAlreadyInUse:
            completion?(LoginErrorCode.EMAIL_ALREADY_IN_USE, nil)
            
        case .weakPassword:
            completion?(LoginErrorCode.WEAK_PASSWORD, nil)
            
        default:
            completion?(LoginErrorCode.CONNECTION_ERROR, nil)
        }
    }
}


