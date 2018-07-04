//
//  ActivityVC.swift
//  Dash
//
//  Created by Isaiah Wong on 30/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class ImageToTextVC: UIViewController {
    // MARK: Properties
    @IBOutlet weak var imageWrapper: CardView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var analysedText: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var image: UIImage!
    var scanDocument: ScanDocument?
    var extract: Extract? // Temporary object placeholder due to lack of time
    
    let imagePicker = UIImagePickerController()
    
    // MARK: Methods
    func initialise(image: UIImage) {
        self.image = image
        let binaryImageData = VisionAPI.vision().base64EncodeImage(image)
        VisionAPI.vision().queryOCR(with: binaryImageData) { (description) -> (Void) in
            DispatchQueue.main.async {
                self.analysedText.text = description
                self.createDocument()
            }
        }
    }
    
    func load(scanDocument: ScanDocument) {
        self.scanDocument = scanDocument
    }
    
    func createDocument() {
        guard let dash = DashVC.selectedDash else {
            return
        }
        let scanDocument = ScanDocument(title: "Document \(ScanDocument.scanDocumentCount)", textAnnotation: self.analysedText.text, dashId: dash.id)
        scanDocument.image = self.image
        scanDocument.create { (bool) -> (Void) in
            // Completion
        }
    }
    
    @objc func expandImage() {
        let vc = ImagePreviewVC.storyboardInstance()!
        vc.image = self.image
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func getRange() {
        if let textRange = analysedText.selectedTextRange {
            let selectedText = analysedText.text(in: textRange)
            guard let string = selectedText, !string.isEmpty else {
                return
            }
            export(string)
        }
    }
    
    func export(_ string: String) {
        self.extract = Extract("")
        self.extract?.extractText = string
        self.present(getAlert(), animated: true, completion: nil) 
    }
    
    func addCustomMenu() {
        // Save instead of export
        let export = UIMenuItem(title: "Export", action: #selector(getRange))
        UIMenuController.shared.menuItems = [export]
    }
    
    func getAlert() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let existingCard = UIAlertAction(title: "Add To Existing Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardAddExisting.storyboardInstance()!
            if let extract = self.extract {
                vc.extract = extract
            }
            self.present(vc, animated: true, completion: nil)
        }
        let newCard = UIAlertAction(title: "Create New Card", style: .default) { [weak weakSelf = self] (action) in
            let vc = CardQuickAddVC.storyboardInstance()!
            if let extract = self.extract {
                vc.extract = extract
            }
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(existingCard)
        alertController.addAction(newCard)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }
    
    static func storyboardInstance() -> ImageToTextVC? {
        return UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "ImageToText") as? ImageToTextVC
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.cornerRadius = 5.0
        self.tintView.layer.cornerRadius = 5.0
        
        // Tap gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandImage))
        self.imageWrapper.addGestureRecognizer(tap)
        
        addCustomMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if let image = self.image {
            self.imageView.image = image
        }
        if let scanDocument = self.scanDocument {
            self.imageView.loadImageUsingCacheWithUrlString(urlString: scanDocument.imagePath!, completion: { (image) in
                self.image = image
            })
            self.analysedText.text = scanDocument.textAnnotation
            self.titleTextField.text = scanDocument.title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
