//
//  CardExtractCell.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class CardExtractCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var analysedText: UITextView!
    
    var extract: Extract!
    
    var highlightStringAttributes: [AttributeProperty] = []
    var ranges: [NSRange] = []
    
    struct AttributeProperty {
        var attribute: [NSAttributedStringKey : Any]
        var range: NSRange
    }
    
    // MARK: Methods
    func prepare(extract: Extract) {
        self.extract = extract
        self.analysedText.text = extract.extractText
        self.style((self.extract?.extractStyle)!)
        self.getIntent()
    }
    
    func style(_ style: ExtractStyle) {
        switch(style) {
        case .normal:
            removeGradient()
        case .highlight:
            highlightGradient()
        default:
            break
        }
    }
    
    private func getIntent() {
        for intent in self.extract!.intents {
            highlightIntent(intent: intent)
        }
    }
    
    private func highlightIntent(intent: Intent) {
        // iterate sentences of extact view
        self.analysedText.text.enumerateSubstrings(in: self.analysedText.text.startIndex..<self.analysedText.text.endIndex, options: .bySentences) {
            (substring, substringRange, _, _) in
            // normalise data
            let string = substring!.substring(to: substring!.index(substring!.endIndex, offsetBy: -2))
            // append ranges of all strings
            self.ranges.append(NSRange(substringRange, in: self.analysedText.text))
            // Check if enumerated string matches intent
            if string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ==
                intent.resolvedQuery.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                // Append attribute property
                self.highlightStringAttributes.append(
                    AttributeProperty(attribute: [
                        NSAttributedStringKey.backgroundColor: UIColor.Palette.orange,
                        NSAttributedStringKey.font: UIFont(name: "Gotham-Bold", size: 14),
                        NSAttributedStringKey.foregroundColor : UIColor.black
                        ], range: NSRange(substringRange, in: self.analysedText.text))
                )
            }
        }
        
        // Add all attributes
        let mutableAttributedString = NSMutableAttributedString(string: self.analysedText.text)
        for attribute in self.highlightStringAttributes {
            // Remove highlight from all ranges
            self.ranges = self.ranges.filter { $0 != attribute.range }
            mutableAttributedString.addAttributes(attribute.attribute, range: attribute.range)
        }
        // Add attribute for normal text
        for range in self.ranges {
            mutableAttributedString.addAttributes([
                NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 14),
                NSAttributedStringKey.foregroundColor : UIColor.black
                ], range: range)
        }
        self.analysedText.attributedText = mutableAttributedString
    }
    
    func highlightGradient() {
        cardView.backgroundColor = UIColor.Palette.green
        analysedText.font = UIFont(name: "Gotham-Bold", size: analysedText.font!.pointSize)
        analysedText.textColor = UIColor.white
    }
    
    func removeGradient() {
        cardView.backgroundColor = UIColor.white
        analysedText.font = UIFont(name: "Gotham-Book", size: analysedText.font!.pointSize)
        analysedText.textColor = UIColor.black
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
