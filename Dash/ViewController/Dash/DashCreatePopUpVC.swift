//
//  DashCreatePopUpVC.swift
//  Dash
//
//  Created by Isaiah Wong on 1/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class DashCreatePopUpVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet var wrapper: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backView: UIView!
    
    // MARK: Methods
    @IBAction func didClose(_ sender: UIButton) {
        self.close()
    }
    
    @IBAction func create(_ sender: UIButton) {
        if !self.validate() {
            return
        }
        // Create a new Dash
        let title = titleTextField.text!
        let dueDate = datePicker.date
        let currentDate = Date()
        guard let userId = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        let dash = Dash(title: title, dueDate: dueDate, dashDescription: "", createdAt: currentDate, userId: userId)
        dash.create { (status) in
            if status != true {
                // TODO: Retry call and return
            }
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    static func storyboardInstance() -> DashCreatePopUpVC? {
        return UIStoryboard(name: "Dash", bundle: nil).instantiateViewController(withIdentifier: "DashCreatePopUp") as? DashCreatePopUpVC
    }
    
    private func validate() -> Bool {
        guard let title = self.titleTextField.text else {
            return false
        }
        if title.isEmpty {
            // Animate TextField
            InteractionAnimation.animation().shakeView(
                layer: self.titleTextField.layer,
                duration: 0.07,
                repeatCount: 3,
                autoreverse: true,
                fromValue: CGPoint(x: self.titleTextField.center.x - 10, y: self.titleTextField.center.y),
                toValue: CGPoint(x: self.titleTextField.center.x + 10, y: self.titleTextField.center.y)
            )
            return false
        }
        return true
    }
    
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func prepareInterface() {
        datePicker.setValue(UIColor.white, forKey: "textColor")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.backView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.delegate = self
        prepareInterface()
    }
}

extension DashCreatePopUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
