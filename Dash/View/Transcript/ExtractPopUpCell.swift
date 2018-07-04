//
//  ExtractPopUpCell.swift
//  Dash
//
//  Created by Isaiah Wong on 25/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class ExtractPopUpCell: UITableViewCell {
    
    @IBOutlet weak var analysedText: UITextView!
    @IBOutlet weak var addCardButton: UIView!
    @IBOutlet weak var cardView: CardView!
    
    var intent: Intent?
    var entity: Entity?
    var extract: Extract?
    
    var content: CardContent?
    
    // MARK: Methods
    func prepare(object: AnyObject, extract: Extract) {
        self.extract = extract
        switch(object) {
        case is Intent:
            intent = (object as! Intent)
            analysedText.text = intent?.fulfillment
        case is Entity:
            entity = (object as! Entity)
            analysedText.text = entity?.name
        default:
            return
        }
    }
    
    func prepare(content: CardContent) {
        self.content = content
        let object = self.content?.content
        switch(object) {
        case is Intent:
            intent = (object as! Intent)
            analysedText.text = intent?.fulfillment
        case is Entity:
            entity = (object as! Entity)
            analysedText.text = entity?.name
        default:
            return
        }
    }
    
    @objc func showPopup(sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadAlert), object: nil, userInfo: ["ViewController" : getAlert()])
    }
    
    func getAlert() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let existingCard = UIAlertAction(title: "Add To Existing Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardAddExisting.storyboardInstance()
            if let intent = self.intent {
                vc?.intent = intent
            }
            else if let entity = self.entity {
                vc?.entity = entity
            }
             NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadPopup), object: nil, userInfo: ["ViewController" : vc])
        }
        let newCard = UIAlertAction(title: "Create New Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardQuickAddVC.storyboardInstance()
            if let intent = self.intent {
                vc?.object = intent
            }
            else if let entity = self.entity {
                vc?.object = entity
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadPopup), object: nil, userInfo: ["ViewController" : vc])
        }
        alertController.addAction(existingCard)
        alertController.addAction(newCard)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showPopup(sender:)))
        if let addCardButton = self.addCardButton {
            addCardButton.addGestureRecognizer(tapGesture)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
