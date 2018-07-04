//
//  CardQuickAddVC.swift
//  Dash
//
//  Created by Isaiah Wong on 21/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class CardQuickAddVC: UIViewController {
    // MARK: Properties
    @IBOutlet weak var cardTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var object: AnyObject?
    var intent: Intent?
    var entity: Entity?
    var extract: Extract?
    
    private var isHidden = true;
    
    // MARK: Methods
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createCard(_ sender: Any) {
        guard let title = self.cardTitle.text, !title.isEmpty else {
            InteractionAnimation.animation().shakeView(
                layer: self.cardTitle.layer,
                duration: 0.07,
                repeatCount: 3,
                autoreverse: true,
                fromValue: CGPoint(x: self.cardTitle.center.x - 10, y: self.cardTitle.center.y),
                toValue: CGPoint(x: self.cardTitle.center.x + 10, y: self.cardTitle.center.y)
            )
            return
        }
        guard let dashId = DashVC.selectedDash?.id else {
            return
        }
        let card = Card(dashId: dashId, title: title, content: "")
        if !isHidden {
            let dueDate = self.datePicker.date
            card.dueDate = dueDate
        }
        if let extract = self.extract {
            card.contents.append(CardContent(index: card.contents.count, content: extract))
            card.formatContents() // Adds a richeditor at the bottom
        }
        card.create { (status) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func toggle(_ sender: UISwitch) {
        self.isHidden = !self.isHidden
        self.datePicker.isHidden = self.isHidden
    }
    
    static func storyboardInstance() -> CardQuickAddVC? {
        return UIStoryboard(name: "CardOperation", bundle: nil).instantiateViewController(withIdentifier: "CardQuickAdd") as? CardQuickAddVC
    }
    
    private func loadData() {
        switch(self.object) {
        case is Intent:
            self.intent = (object as! Intent)
            cardTitle.text = intent?.fulfillment
        case is Entity:
            self.entity = (object as! Entity)
            cardTitle.text = entity?.name
        default:
            return
        }
    }
    
    private func prepareInterface() {
        self.cardTitle.text = ""
        self.datePicker.setValue(UIColor.white, forKey: "textColor")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareInterface()
        self.loadData()
        self.cardTitle.delegate = self
    }
}

extension CardQuickAddVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

