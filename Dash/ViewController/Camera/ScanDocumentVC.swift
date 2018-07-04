//
//  ScanDocumentVC.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class ScanDocumentVC: UIViewController {
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    let imagePicker = UIImagePickerController()

    var scanDocuments: [ScanDocument] = []
    
    // MARK: Method
    @IBAction func loadOptions(_ sender: Any) {
        self.present(getAlert(), animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    static func storyboardInstance() -> UIViewController? {
        let vc = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "ScanDocument") as? ScanDocumentVC
        return UINavigationController(rootViewController: vc!)
    }
 
    func getAlert() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [weak weakSelf = self] (action) in
            // Loads Library
            weakSelf!.loadImagePicker()
        }
        let takePhoto = UIAlertAction(title: "Take a Photo", style: .default) { [weak weakSelf = self] (action) in
            weakSelf!.takePhoto()
        }
        alertController.addAction(takePhoto)
        alertController.addAction(photoLibrary)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }
    
    func fetchData() {
        guard let dash = DashVC.selectedDash else {
            return
        }
        ScanDocument.getAllDocument(dashId: dash.id) { (scanDocument) -> (Void) in
            self.scanDocuments.append(scanDocument)
            self.tableView.reloadData()
        }
    }
    
    func prepareInterface() {
        // Hides nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.barTintColor = UIColor.ColorProfileFix.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 20)!,
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageToTextSegue" {
            if let vc = segue.destination as? ImageToTextVC {
                let cell = sender as! ScanDocumentCell
                let scanDocument = self.scanDocuments[self.tableView.indexPath(for: cell)!.row]
                vc.load(scanDocument: scanDocument)
            }
        }
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        self.imagePicker.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.prepareInterface()
        self.fetchData()
        
        // Reset Scan Documents counter to 0
        ScanDocument.scanDocumentCount = 0
    }
}

extension ScanDocumentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func loadImagePicker() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(self.imagePicker, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
        }
        
        dismiss(animated: true) {
            if let image = image {
                let vc = ImageToTextVC.storyboardInstance()!
                vc.initialise(image: image)
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ScanDocumentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scanDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanDocumentCell", for: indexPath) as? ScanDocumentCell else {
            return UITableViewCell()
        }
        cell.prepare(scanDocument: self.scanDocuments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
