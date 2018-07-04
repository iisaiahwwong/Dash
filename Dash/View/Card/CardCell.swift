//
//  CardCell.swift
//  Dash
//
//  Created by Isaiah Wong on 10/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol CardCellDelegate {
    func cardCell(didTap: CardCell, _ viewController: UIViewController)
}

class CardCell: UICollectionViewCell {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var touchWrapper: UIView!
    
    var card: Card?
    var delegate: CardCellDelegate?
    
    // MARK: Methods
    func prepare(card: Card) {
        self.cardView.layer.shadowOpacity = 0.3
        self.cardView.setNeedsDisplay()
        
        self.card = card
        self.titleLabel.text = card.title
        self.descriptionTextView.text = card.cardContents.stripHTML()
        //self.descriptionTextView.text = (card.contents[0].content as! String).stripHTML()
        self.descriptionTextView.text = formatDescTextOf(contents: card.contents)
        if let dueDate = card.dueDate {
            self.dueDateLabel.text = dueDate.toString(dateFormat: "dd MMM")
            self.dueDateLabel.textColor = UIColor.PinkOrange.upperBound
        }
        else {
            self.dueDateLabel.text = card.createdAt.toString(dateFormat: "dd MMM")
            self.dueDateLabel.textColor = UIColor.Palette.blue
        }
    }
    
    func formatDescTextOf(contents: [CardContent]) -> String{
        var str = ""
        
        for content in contents {
            switch(content.content) {
            case is String:
                str += " \((content.content as! String).stripHTML())"
            case is Intent:
                str += " [Intent* \((content.content as! Intent).fulfillment)]"
            case is Extract:
                str += " [Extract* \((content.content as! Extract).extractText)]"
            case is Vote:
                str += " [Vote* \((content.content as! Vote).title)]"
            default:
                break
            }
        }
        
        if !(str.isEmpty) {
            str.remove(at: str.startIndex) //remove 1st space
        }
        
        return str
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let popupVC = CardEditVC.storyboardInstance()!
        popupVC.card = self.card
        //popupVC.dash = self.dash
        TapticFeedback.feedback.heavy()
        self.delegate?.cardCell(didTap: self, popupVC)
    }

    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.touchWrapper.addGestureRecognizer(tap)
    }
}

extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>|&[^;]+;", with: " ", options: NSString.CompareOptions.regularExpression, range: nil)
    }
}
