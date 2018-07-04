//
//  Extract.swift
//  Dash
//
//  Created by Isaiah Wong on 25/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import googleapis

enum ExtractError: Error {
    case EmptyTranscript(String)
}

class Extract: NSObject {
    
    // MARK: Properties
    private var _id: String
    private var _transcriptId: String
    private var _extractText: String
    private var _createdAt: Date
    private var _extractStyle: ExtractStyle = .normal
    private var _command: SpeechCommand = .none
    private var _userId: String
    private var _userInitials:String
    var intents: [Intent] = []
    
    // MARK: Optionals
    
    /** A speech recognition result corresponding to a portion of the audio. **/
    private var _unprocessedExtractText: StreamingRecognitionResult?
    
    /** Transcript text representing the words that the user spoke.  **/
    var extractBuilder: String = ""
    
    /** Variable to tract if transcript session has ended  **/
    var isFinal: Bool = false
    
    var id: String {
        get {
            return self._id
        }
        
        set {
            self._id = newValue
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
    
    var extractText: String {
        get {
            return self._extractText
        }
        set {
            self._extractText = newValue
        }
    }
    
    var unprocessedExtract: StreamingRecognitionResult {
        get {
            guard let unprocessedTranscript = self._unprocessedExtractText else {
                return StreamingRecognitionResult()
            }
            return unprocessedTranscript
        }
        set {
            self._unprocessedExtractText = newValue
        }
    }
    
    var extractStyle: ExtractStyle {
        get {
            return self._extractStyle
        }
        set {
            self._extractStyle = newValue
        }
    }
    
    var command: SpeechCommand {
        get {
            return self._command
        }
        set {
            self._command = newValue
        }
    }
    
    var createdAt: Date {
        get {
            return self._createdAt
        }
    }
    
    var userInitials: String {
        get {
            return self._userInitials
        }
        set {
            self._userInitials = newValue
        }
    }
    
    // MARK: Intializers
    
    init(_ tmpInit: String) {
        self._id = ""
        self._transcriptId = ""
        self._extractText = ""
        self._createdAt = Date()
        self._userId = ""
        self._userInitials = ""
    }
    
    init(transcriptId: String, userId: String, userInitials: String) {
        self._id = ""
        self._transcriptId = transcriptId
        self._extractText = ""
        self._createdAt = Date()
        self._userId = userId
        self._userInitials = userInitials
    }
    
    init(transcripted: String, createdAt: Date, userId: String, userInitials: String) {
        self._id = ""
        self._transcriptId = ""
        self._extractText = transcripted
        self._createdAt = createdAt
        self._userId = userId
        self._userInitials = userInitials
    }
    
    init(format unprocessedTranscript: StreamingRecognitionResult, createdAt: Date, userId: String, userInitials: String) {
        self._id = ""
        self._unprocessedExtractText = unprocessedTranscript
        self._extractText = ""
        self._createdAt = createdAt
        self._transcriptId = ""
        self._userId = userId
        self._userInitials = userInitials
    }
    
    init(id: String, transcriptId: String, extractText: String, extractStyle: String, command: String, createdAt: Date, userId: String, userInitials: String, intents: [Intent]) {
        self._id = id
        self._transcriptId = transcriptId
        self._extractText = extractText
        self._createdAt = createdAt
        self._extractStyle = ExtractStyle.map(extractStyle)
        self._command = SpeechCommand.map(command)
        self._userId = userId
        self._userInitials = userInitials
        self.intents = intents
    }
    
    // MARK: Methods
    func map() -> [String : Any] {
        return [
            "transcriptId" : self._transcriptId,
            "extractText" : self._extractText,
            "createdAt" : self._createdAt.timeIntervalSince1970,
            "extractStyle" : self._extractStyle.rawValue,
            "command" : self._command.command(),
            "userId" : self._userId,
            "userInitials" : self._userInitials,
            "intents" : Intent.dictionaryToArray(self.intents)
        ]
    }
    
    class func interpolate(id: String, dict: [String : Any]) -> Extract {
        let transcriptId = dict["transcriptId"] as! String
        let command = dict["command"] as! String
        let createdAt = Date(timeIntervalSince1970: dict["createdAt"] as! Double)
        let extractStyle = dict["extractStyle"] as! String
        let extractText = dict["extractText"] as! String
        let userId = dict["userId"] as! String
        let userInitials = dict["userInitials"] as! String
        var intents: [Intent] = []
        if let arr = dict["intents"] as? NSMutableArray {
            for intent in arr {
                let intentDict = intent as! [String : Any]
                let fulfilment = intentDict["fulfilment"] as! String
                let resolvedQuery = intentDict["resolvedQuery"] as! String
                intents.append(Intent(fulfillment: fulfilment, resolvedQuery: resolvedQuery))
            }
        }
        return Extract(id: id, transcriptId: transcriptId, extractText: extractText, extractStyle: extractStyle, command: command, createdAt: createdAt, userId: userId, userInitials: userInitials, intents: intents)
    }
    
    func processTranscript() throws {
        // TODO: Transcript Processing
        /** Check if unprocessedTranscript has been assigned **/
        guard let unprocessedTranscript = self._unprocessedExtractText else {
            throw ExtractError.EmptyTranscript("unprocessed transcript is empty. Initialise value first")
        }
        
        // Debugging
//        print(unprocessedTranscript)
        self.isFinal = unprocessedTranscript.isFinal
        // Extract Speech Results
        if let speechResults = unprocessedTranscript.alternativesArray.firstObject as? SpeechRecognitionAlternative {
            self._extractText = extractBuilder + speechResults.transcript
            // Append the transcript when speech recognition processing has ended
            if self.isFinal {
                var unnormalizedResult = speechResults.transcript!
                extractCommands(&unnormalizedResult)
                let finalTranscript = unnormalizedResult
                    .trimmingCharacters(in: .whitespacesAndNewlines) // Normalise data
                    .capitalizingFirstLetter()
                // Builds Transcripts by appending
                self.extractBuilder += "\(finalTranscript). "
            }
        }
    }
    
    func extractCommands(_ transcript: inout String)  {
        let words = transcript.components(separatedBy: " ")
        for word in words {
            // TODO: Word Lemma and Stemming
            let command: SpeechCommand = self.traverse(word)
            if command != .none {
                self._command = command
                break;
            }
        }
    }
    
    func analyseIntent(_ completion: @escaping (Extract) -> (Void)) {
        NLP.nlp().analyseIntent(text: self.extractText) { [weak weakSelf = self] (response) -> (Void) in
            guard let weakSelf = weakSelf else {
                return
            }
            guard let intents = response as? [Intent] else {
                return
            }
            // Copy Intent
            for intent in intents {
                self.intents.append(intent)
            }
            completion(self)
        }
    }
    
    func traverse(_ string: String) -> SpeechCommand {
        switch string {
        case SpeechCommand.delete.command():
            return SpeechCommand.delete
        default:
            return SpeechCommand.none
        }
    }
    
    
}
