//
//  TranscriptPopUpVC.swift
//  Dash
//
//  Created by Isaiah Wong on 22/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

let TranscriptLoadPopup = "com.dash.load.transcript.popup"
let TranscriptLoadAlert = "com.dash.load.transcript.alert"

class TranscriptPopUpVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var popupWrapper: CardView!
    @IBOutlet weak var extractView: UITextView!
    @IBOutlet weak var categoryView: UICollectionView!
    @IBOutlet weak var wrapper: CardShadow!
    @IBOutlet weak var tableView: UITableView!
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    private var categories: [String : [AnyObject]] = [:]
    private var selectedKey: String?
    let cellHeight: CGFloat = 65
    var extract: Extract?
    var highlightStringAttributes: [AttributeProperty] = []
    var ranges: [NSRange] = []

    let TranscriptLoadPopupKey = Notification.Name(rawValue: TranscriptLoadPopup)
    let TranscriptLoadAlertKey = Notification.Name(rawValue: TranscriptLoadAlert)

    enum ExtractError: Error {
        case ValueNotInitialized(String)
    }
    
    // MARK: Methods
    @IBAction func didClose(_ sender: UIButton) {
        self.animateOut()
    }
    
    @IBAction func export(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadAlert), object: nil, userInfo: ["ViewController" : self.getAlert()])
        
    }
    
    private func prepareInterface() {
        guard let extract = self.extract else {
            // TODO: Throw error
            animateOut()
            return
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.gradientLayer.opacity = 0
        self.view.setGradientBackground(gradientLayer: &self.gradientLayer, upperBound: UIColor.PurpleBlue.upperBound, lowerBound: UIColor.PurpleBlue.lowerBound)
        extractView.text = extract.extractText
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        // Estimate cell height
        self.tableView.estimatedRowHeight = self.cellHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.cellHeight
        self.tableView.scrollIndicatorInsets.bottom = self.cellHeight
    }
    
    private func analyseEntities() {
        guard let extract = self.extract else {
            return
        }
        // TODO:
        NLP.nlp().analyseEntities(text: extract.extractText) { (response) -> (Void) in
            guard let entities = response as? [Entity] else {
                return
            }
            for entity in entities {
                // Check if Key exists
                if self.categories[entity.type] == nil {
                    self.categories[entity.type] = []
                }
                self.categories[entity.type]?.append(entity)
            }
            DispatchQueue.main.async {
                self.categoryView.reloadData()
                // Select First Item as Default
                if self.categories.count > 0 {
                    self.categoryView.selectItem(at:  IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
                }
            }
        }
    }
    
    private func analyseIntent() {
        guard let extract = self.extract else {
            return
        }
        NLP.nlp().analyseIntent(text: extract.extractText) { [weak weakSelf = self] (response) -> (Void) in
            guard let weakSelf = weakSelf else {
                return
            }
            guard let intents = response as? [Intent] else {
                return
            }
            for intent in intents {
                // Check if Key exists
                // Initialise intent
                if weakSelf.categories["intent"] == nil {
                    weakSelf.categories["intent"] = []
                }
                weakSelf.highlightIntent(intent: intent)
                weakSelf.categories["intent"]?.append(intent as AnyObject)
            }
            DispatchQueue.main.async {
                self.categoryView.reloadData()
            }
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
        
        // Assign all attributes 
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
                NSAttributedStringKey.foregroundColor : UIColor.white
                ], range: range)
        }
        self.extractView.attributedText = mutableAttributedString
    }
    
    func getAlert() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let existingCard = UIAlertAction(title: "Add To Existing Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardAddExisting.storyboardInstance()
            vc?.extract = self.extract
            NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadPopup), object: nil, userInfo: ["ViewController" : vc])
        }
        let newCard = UIAlertAction(title: "Create New Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardQuickAddVC.storyboardInstance()
            vc?.extract = self.extract
            NotificationCenter.default.post(name: Notification.Name(rawValue: TranscriptLoadPopup), object: nil, userInfo: ["ViewController" : vc])
        }
        alertController.addAction(existingCard)
        alertController.addAction(newCard)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }
    
    private func animate() {
        self.popupWrapper.transform = CGAffineTransform(translationX: 0, y: 50)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
            self.popupWrapper.transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.8) {
            self.gradientLayer.opacity = 0.87
        }
    }
    
    @objc private func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupWrapper.transform = CGAffineTransform(translationX: 0, y: 50)
            self.view.alpha = 0
            self.gradientLayer.opacity = 0
        }) { (success) in
            NotificationCenter.default.removeObserver(self)
            self.view.removeFromSuperview()
        }
    }
    
    @objc private func loadVC(notification: Notification) {
        if let vc = notification.userInfo!["ViewController"] as? UIViewController {
            self.animateOut()
            TapticFeedback.feedback.heavy()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc private func loadAlert(notification: Notification) {
        if let vc = notification.userInfo!["ViewController"] as? UIViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadVC(notification:)), name: TranscriptLoadPopupKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAlert(notification:)), name: TranscriptLoadAlertKey, object: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Delegates
        self.categoryView.delegate = self
        self.categoryView.dataSource = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        prepareInterface()
        analyseEntities()
        analyseIntent()
        animate()
        createObservers()
    }
}

extension TranscriptPopUpVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtractCategoryCollectionCell", for: indexPath) as! ExtractCategoryCollectionCell
        let key = Array(categories.keys)[indexPath.row]
        cell.category.text = String(describing: key).capitalized
        cell.count.text = String(describing: categories[key]!.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = Array(categories.keys)[indexPath.row]
        self.selectedKey = key
        self.tableView.reloadData()
    }
}

extension TranscriptPopUpVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedKey = self.selectedKey else {
            return 0
        }
        guard let objects = categories[selectedKey] else {
            return 0
        }
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExtractPopUpCell", for: indexPath) as? ExtractPopUpCell else {
            return UITableViewCell()
        }
        guard let selectedKey = self.selectedKey else {
            return cell
        }
        guard let objects = categories[selectedKey] else {
            return cell
        }
        cell.prepare(object: objects[indexPath.row], extract: self.extract!)
        return cell
    }
}
