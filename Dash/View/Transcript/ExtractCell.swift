//
//  ExtractCell.swift
//  Dash
//
//  Created by Isaiah Wong on 6/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class ExtractCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var profileImageWrapper: UIView!
    @IBOutlet weak var userInitials: UILabel!
    @IBOutlet weak var extractWrapper: CardView!
    @IBOutlet weak var extractView: UITextView!
    
    var highlightStringAttributes: [AttributeProperty] = []
    var ranges: [NSRange] = []
    
    /** Gradient Layer used to overlay views. **/
    var gradientLayer: CAGradientLayer?
    weak var transcriptVC: TranscriptVC?
    var extract: Extract?
    
    enum ExtractCellError: Error {
        case EmptyViewController(String)
    }

    // MARK: Methods
    func prepare(extract: Extract, transcriptVC: TranscriptVC) {
        self.extract = extract
        self.extractView.text = extract.extractText
        self.userInitials.text = self.extract?.userInitials
        self.transcriptVC = transcriptVC
        self.gradientLayer = CAGradientLayer()
        self.ranges = []
        self.highlightStringAttributes = []
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
    
    struct AttributeProperty {
        var attribute: [NSAttributedStringKey : Any]
        var range: NSRange
    }
    
    private func highlightIntent(intent: Intent) {
        // iterate sentences of extact view
        self.extractView.text.enumerateSubstrings(in: self.extractView.text.startIndex..<self.extractView.text.endIndex, options: .bySentences) {
            (substring, substringRange, _, _) in
            // normalise data
            let string = substring!.substring(to: substring!.index(substring!.endIndex, offsetBy: -2))
            // append ranges of all strings
            self.ranges.append(NSRange(substringRange, in: self.extractView.text))
            // Check if enumerated string matches intent
            if string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ==
                intent.resolvedQuery.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                // Append attribute property
                self.highlightStringAttributes.append(
                    AttributeProperty(attribute: [
                        NSAttributedStringKey.backgroundColor: UIColor.Palette.orange,
                        NSAttributedStringKey.font: UIFont(name: "Gotham-Bold", size: 14),
                        NSAttributedStringKey.foregroundColor : UIColor.black
                        ], range: NSRange(substringRange, in: self.extractView.text))
                )
            }
        }
        
        // Add all attributes
        let mutableAttributedString = NSMutableAttributedString(string: self.extractView.text)
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
        self.extractView.attributedText = mutableAttributedString
    }
    
    func highlightGradient() {
//        guard var gradientLayer = self.gradientLayer else {
//            // TODO: Throw gradientlayer null error
//            return
//        }
        extractWrapper.backgroundColor = UIColor.Palette.green
        extractView.font = UIFont(name: "Gotham-Bold", size: extractView.font!.pointSize)
        extractView.textColor = UIColor.white
    }
    
    func removeGradient() {
//        guard var gradientLayer = self.gradientLayer else {
//            // TODO: Throw gradientlayer null error
//            return
//        }
        extractWrapper.backgroundColor = UIColor.white
        extractView.font = UIFont(name: "Gotham-Book", size: extractView.font!.pointSize)
        extractView.textColor = UIColor.black
    }
    
    @objc func showPopup(sender: UILongPressGestureRecognizer) throws {
        if sender.state == .began {
            guard let transcriptVC = self.transcriptVC else {
                throw ExtractCellError.EmptyViewController("Transcript ViewController not assigned")
            }
            /** Stop Recoridng **/
            transcriptVC.speechActionHandler(action: .stop, completion: nil)
            let popupVC = UIStoryboard(name: "Transcript", bundle: nil).instantiateViewController(withIdentifier: "TranscriptPopUp") as! TranscriptPopUpVC
            popupVC.extract = self.extract
            transcriptVC.addChildViewController(popupVC)
            popupVC.view.frame = transcriptVC.view.frame
            TapticFeedback.feedback.heavy()
            transcriptVC.view.addSubview(popupVC.view)
            popupVC.didMove(toParentViewController: transcriptVC)
        }
    }

    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showPopup))
        self.extractWrapper.addGestureRecognizer(longPressRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
