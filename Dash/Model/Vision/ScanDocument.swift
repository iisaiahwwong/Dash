//
//  ScanDocument.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit
import Firebase

class ScanDocument {
    var image: UIImage?
    var imagePath: String?
    var title: String
    var textAnnotation: String
    var dashId: String
    
    static var scanDocumentCount: UInt = 0
    
    init(title: String, textAnnotation: String, dashId: String) {
        self.title = title
        self.textAnnotation = textAnnotation
        self.dashId = dashId
    }
    
    func create(completion: @escaping (Bool) -> (Void)) {
        guard let image = self.image else {
            return
        }
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let child = UUID().uuidString
        Storage.storage().reference().child("scannedDocuments").child(child).putData(imageData!, metadata: nil) { (metadata, error) in
            if error == nil {
                let path = metadata?.downloadURL()?.absoluteString
                let values: [String : Any] = [
                    "title": self.title,
                    "textAnnotation": self.textAnnotation,
                    "imagePath" : path,
                    "dashId" : self.dashId
                ]
                Database.database().reference().child("dashs").child("scannedDocuments").childByAutoId().setValue(values, withCompletionBlock: { (error, ref) in
                    let key = ref.key
                    let value: [String : Any] = [key : true]
                    Database.database().reference().child("dashs").child(self.dashId).child("scannedDocuments").updateChildValues(value)
                    completion(true)
                })
            }
        }
    }
    
    class func getAllDocument(dashId: String, completion: @escaping (ScanDocument) -> (Void)) {
        Database.database().reference().child("dashs").child(dashId).child("scannedDocuments").observe(.childAdded) { (snapshot) in
            if !snapshot.exists() { return }
            let key = snapshot.key
            Database.database().reference().child("dashs").child("scannedDocuments").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() { return }
                let dict = snapshot.value as! [String : Any]
                let title = dict["title"] as! String
                let textAnnotation = dict["textAnnotation"] as! String
                let imagePath = dict["imagePath"] as! String
                let dashId = dashId
                
                let scanDocument = ScanDocument(title: title, textAnnotation: textAnnotation, dashId: dashId)
                scanDocument.imagePath = imagePath
                ScanDocument.scanDocumentCount += 1
                completion(scanDocument)
            })
        }
    }
}
