//
//  Card.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17, added on by Keane Ruan on 11/1/18.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase

class CardContent: NSObject {
    var index: Int!
    var content: Any!
    
    init(index: Int, content: Any) {
        self.index = index
        self.content = content
    }
}

class Card: NSObject {
    
    // MARK: Properties
    private var _id : String
    private var _title: String
    //private var _cardContents: CardContents
    private var _cardContents: String
    private var _cardSection: String
    private var _createdAt: Date
    private var _dashId: String
    private var _userId: String
    private var _dueDate: Date?
    
    // Binds search query extract to this
    var cardSearchHelper: [CardContent : Bool] = [:]
    
    var contents: [CardContent] = [] {
        didSet {
//            self.formatContents()
        }
    }
    
    var cardContentReference: DatabaseReference!
    
    var id: String {
        get { return self._id }
        set { self._id = newValue }
    }
    
    var title: String {
        get { return self._title }
        set { self._title = newValue }
    }
    
    var cardSection: String {
        get { return self._cardSection }
        set { self._cardSection = newValue }
    }
    
    var cardContents: String {
        get { return self._cardContents }
        set { self._cardContents = newValue }
    }
    
    var createdAt: Date {
        get { return self._createdAt }
    }
    
    var dueDate: Date? {
        get { return self._dueDate }
        set { self._dueDate = newValue }
    }
    
    
    // MARK: Intializers
    init(id: String, dashId: String, userId: String, title: String, createdAt: Date, cardContents: String, cardSection: String) {
        self._id = id
        self._userId = userId
        self._dashId = dashId
        self._title = title
        self._createdAt = createdAt
        self._cardContents = cardContents
        self._cardSection = cardSection
    }
    
    init(dashId: String, title: String, content: String) {
        self._id = ""
        self._userId = ""
        self._dashId = dashId
        self._title = title
        //self._dueDate = dueDate
        self._createdAt = Date()
        self._cardContents = content
        self._cardSection = ""
    }
    
    init(title: String, content: String) {
        self._id = ""
        self._userId = ""
        self._dashId = ""
        self._title = title
        //self._dueDate = dueDate
        self._createdAt = Date()
        self._cardContents = content
        self._cardSection = ""
    }
    
    init(dashId: String) {
        self._id = ""
        self._userId = ""
        self._dashId = dashId
        self._title = ""
        //srelf._dueDate = dueDate
        self._createdAt = Date()
        self._cardContents = ""
        self._cardSection = ""
    }
    
    //MARK: Methods
    func create(completion: ((Bool) -> Void)?) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else { return }
        self._userId = uid
        
        // TODO: +K Follow up on multiple section UI
        let values = mapCardDetails()
        Database.database().reference()
            .child("dashs")
            .child("cards")
            .childByAutoId()
            .setValue(values) { (error, ref) in
                self._id = ref.key
                let value = [self._id : true]
                if !self._dashId.isEmpty {
                    Database.database().reference().child("dashs").child(self._dashId).child("cards").updateChildValues(value, withCompletionBlock: { (error, ref) in
                        if let completion = completion {
                            completion(true)
                        }
                    })
                }
                Database.database().reference().child("users").child(uid).child("cards").updateChildValues(value)
            }
    }

    func update(completion: ((Bool) -> Void)?) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else { return }
        self._userId = uid
        
        //let values = mapCardDetails()
        //TODO: +K Change createdAt to / Add lastModified attribute
        let values = mapCardDetails()
        Database.database().reference()
            .child("dashs")
            .child("cards")
            .child(self._id)
            .updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let completion = completion {
                    completion(true)
                }
            })
    }
    
    func addIntent(intent: Intent, completion: @escaping (Bool) -> (Void)) {
        let ref = Database.database().reference()
            .child("dashs")
            .child("cards")
            .child(self._id)
            .child("contents")
        self.formatContentWithDatabase(ref: ref)
        let index = self.contents.count
        ref.child("\(index)").updateChildValues(["intent" : intent.map()]) { (error, ref) in
                if error == nil {
                    ref.child("\(index+1)").updateChildValues(["textHtml" : ""])
                    completion(true)
                    self.contents.append(CardContent.init(index: index, content: intent))
                    self.contents.append(CardContent.init(index: index+1, content: ""))
                    NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateCardContent), object: nil, userInfo: ["card" : self])
                }
        }
    }
    
    func addExtract(extract: Extract, completion: @escaping (Bool) -> (Void)) {
        let ref = Database.database().reference()
            .child("dashs")
            .child("cards")
            .child(self._id)
            .child("contents")
        self.formatContentWithDatabase(ref: ref)
        let index = self.contents.count
        ref.child("\(index)").updateChildValues(["extract" : extract.map()]) { (error, ref) in
            if error == nil {
                ref.child("\(index+1)").updateChildValues(["textHtml" : ""])
                completion(true)
                self.contents.append(CardContent.init(index: index, content: extract))
                self.contents.append(CardContent.init(index: index, content: ""))
                NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateCardContent), object: nil, userInfo: ["card" : self])
            }
        }
    }
    
    
    func formatContents() {
        // get last inserted
        let lastContent = self.contents[self.contents.count - 1].content
        if !(lastContent is String) {
            self.contents.append(CardContent(index: self.contents.count, content: ""))
        }
    }
    
    func formatContentWithDatabase(ref: DatabaseReference) {
        // Remove unwanted card contents
        let lastContent = self.contents[self.contents.count - 1].content
        if lastContent is String {
            if (lastContent as! String).isEmpty {
                // Remove it from db
                ref.child("\(self.contents.count - 1)").removeValue()
                // Remove it from card
                self.contents.removeLast()
            }
        }
    }
    
    //TODO: +K Get Cards onChange instead of onAdd
    class func getAllCards(dashId: String, completion: @escaping (Card) -> Void) {
        let ref = Database.database().reference()
            .child("dashs")
            .child(dashId)
            .child("cards")
        ref.keepSynced(true)
        ref.observe(.childAdded) { (snapshot) in
                if !snapshot.exists() { return }
                //Card.transcriptCount += 1 //?
                let key = snapshot.key
                Database.database().reference()
                    .child("dashs")
                    .child("cards")
                    .child(key)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() { return }
                        guard let value = snapshot.value else {
                            return
                        }
                        let dict = value as! [String : Any],
                            id = snapshot.ref.key,
                            title = dict["title"] as! String,
                            userId = dict["userId"] as! String,
                            createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double),
                            cardContents = dict["cardContents"] as! String,
                            cardSection = dict["cardSection"] as! String
                        let card = Card(id: id, dashId: dashId, userId: userId, title: title, createdAt: createdAt, cardContents: cardContents, cardSection: cardSection)
                        if let dueDate = dict["dueDate"] {
                            card.dueDate = Date(timeIntervalSince1970: dueDate as! Double)
                        }
                        if let contents = dict["contents"] as? NSMutableArray {
                            var index = 0
                            for content in contents {
                                guard let dict = content as? [String : Any] else {
                                    continue
                                }
                                if let intent = dict["intent"] as? [String : Any] {
                                    let fulfilment = intent["fulfilment"] as! String
                                    let resolvedQuery = intent["resolvedQuery"] as! String
                                    card.contents.append(CardContent.init(index: index, content: Intent(fulfillment: fulfilment, resolvedQuery: resolvedQuery)))
                                }
                                if let string = dict["textHtml"] as? String {
                                    card.contents.append(CardContent.init(index: index, content: string))
                                }
                                if let extract = dict["extract"] as? [String : Any] {
                                    // TODO: Fix id
                                    card.contents.append(CardContent.init(index: index, content: Extract.interpolate(id: "", dict: extract)))
                                }
                                if let vote = dict["vote"] as? [String : Any] {
                                    card.contents.append(CardContent.init(index: index, content: Vote.interpolate(dict: vote)))
                                }
                                if let draw = dict["draw"] as? [String : Any] {
                                    card.contents.append(CardContent.init(index: index, content: Draw.interpolate(dict: draw)))
                                }
                                index += 1
                            }
                        }
                        completion(card)
                    })
        }
    }
    
    class func getAllCards(completion: @escaping (Card) -> Void) {
        guard let uid =  AuthProvider.auth().getCurrentUser()?.uid else { return }
        let ref = Database.database().reference()
            .child("users")
            .child(uid)
            .child("cards")
        ref.keepSynced(true)
        ref.observe(.childAdded) { (snapshot) in
                if !snapshot.exists() { return }
                //Card.transcriptCount += 1 //?
                let key = snapshot.key
                Database.database().reference()
                    .child("dashs")
                    .child("cards")
                    .child(key)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() { return }
                        guard let value = snapshot.value else {
                            return
                        }
                        let dict = value as! [String : Any],
                        id = snapshot.ref.key,
                        title = dict["title"] as! String,
                        userId = dict["userId"] as! String,
                        createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double),
                        cardContents = dict["cardContents"] as! String,
                        cardSection = dict["cardSection"] as! String,
                        dashId = dict["dashId"] as! String

                        let card = Card(id: id, dashId: dashId, userId: userId, title: title, createdAt: createdAt, cardContents: cardContents, cardSection: cardSection)
                        if let dueDate = dict["dueDate"] {
                            card.dueDate = Date(timeIntervalSince1970: dueDate as! Double)
                        }
                        if let contents = dict["contents"] as? NSMutableArray {
                            var index = 0
                            for content in contents {
                                let dict = content as! [String : Any]
                                if let intent = dict["intent"] as? [String : Any] {
                                    let fulfilment = intent["fulfilment"] as! String
                                    let resolvedQuery = intent["resolvedQuery"] as! String
                                    card.contents.append(CardContent.init(index: index, content: Intent(fulfillment: fulfilment, resolvedQuery: resolvedQuery)))
                                }
                                if let string = dict["textHtml"] as? String {
                                    card.contents.append(CardContent.init(index: index, content: string))
                                }
                                if let extract = dict["extract"] as? [String : Any] {
                                    // TODO: Fix id
                                    card.contents.append(CardContent.init(index: index, content: Extract.interpolate(id: "", dict: extract)))
                                }
                                if let vote = dict["vote"] as? [String : Any] {
                                    card.contents.append(CardContent.init(index: index, content: Vote.interpolate(dict: vote)))
                                }
                                if let draw = dict["draw"] as? [String : Any] {
                                    card.contents.append(CardContent.init(index: index, content: Draw.interpolate(dict: draw)))
                                }
                                index += 1
                            }
                        }
                        completion(card)
                    })
        }
    }
    
    func getUpdatesForCardContents(_ completion: ((CardContent) -> (Void))? ) {
        self.cardContentReference = Database.database().reference().child("dashs").child("cards").child(self._id).child("contents")
        self.cardContentReference.keepSynced(true)
        self.cardContentReference.observe(.childAdded, with: { (snapshot) in
            if !snapshot.exists() { return }
            // Intent | Extract | Vote | Draw
            guard let index = Int(snapshot.key) else {
                return
            }
            var cardContent: CardContent!
            if let dict = snapshot.value as? [String : Any] {
                if let intent = dict["intent"] as? [String : Any] {
                    let fulfilment = intent["fulfilment"] as! String
                    let resolvedQuery = intent["resolvedQuery"] as! String
                    cardContent = CardContent.init(index: index, content: Intent(fulfillment: fulfilment, resolvedQuery: resolvedQuery))
                }
                if let extract = dict["extract"] as? [String : Any] {
                    cardContent = CardContent.init(index: index, content: Extract.interpolate(id: "", dict: extract))

                }
                if let textHtml = dict["textHtml"] as? String {
                    cardContent = CardContent.init(index: index, content: textHtml)
                }
                if let vote = dict["vote"] as? [String : Any] {
                    cardContent = CardContent.init(index: index, content: Vote.interpolate(dict: vote))
                }
                if let draw = dict["draw"] as? [String : Any] {
                    cardContent = CardContent.init(index: index, content: Draw.interpolate(dict: draw))
                }
            }
            else if let array = snapshot.value as? NSMutableArray {
            }
            if let cardContent = cardContent {
                if self.contents.count < index || self.contents.count == index {
                    // Add a new card content to prevent index exception
                    self.contents.append(cardContent)
                }
                else {
                    self.contents[index] = cardContent
                }
            }
            if let completion = completion {
                completion(cardContent)
            }
        })
    }
    
    func removeObserverForCardContents() {
        self.cardContentReference.removeAllObservers()
    }
    
    private func mapCardDetails() -> [String : Any]{
        var cardSection = self._cardSection
        
        cardSection = self._dashId.isEmpty ? ""
            : (cardSection.isEmpty ? "Planning" : cardSection)
        
        // TODO: +K Find out dueDate UI
        var dict: [String : Any] = [
            "title": self._title.isEmpty ? "" : self._title,
            "cardContents": self._cardContents,
            "cardSection": cardSection,
            //"dueDate": self._dueDate.timeIntervalSince1970,
            "createdAt": self._createdAt.timeIntervalSince1970,
            "dashId": self._dashId,
            "userId": self._userId,
            "contents" : Card.dictionaryToArray(self.contents)
        ]
        if let dueDate = self._dueDate {
            dict["dueDate"] = dueDate.timeIntervalSince1970
        }
        return dict
    }
    
    class func dictionaryToArray(_ cardContent: [CardContent]) -> [[String : Any]] {
        var arr: [[String : Any]] = []
        for content in cardContent {
            switch content.content {
            case is Intent:
                arr.append(["intent" : (content.content as! Intent).map()])
            case is Extract:
                arr.append(["extract" : (content.content as! Extract).map()])
            case is String:
                arr.append(["textHtml" : (content.content as! String)])
            case is Vote:
                arr.append(["vote" : (content.content as! Vote).map()])
            case is Draw:
                arr.append(["draw" : (content.content as! Draw).map()])
            default:
                break
            }
        }
        return arr
    }
}
