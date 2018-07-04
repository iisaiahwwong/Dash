//
//  AuthenticationVC+UIHandlersViewController.swift
//  Dash
//
//  Created by Isaiah Wong on 1/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

extension AuthenticationVC {
    
    func setupConstraints() {
        // viewWrapper Constraints
        self.viewWrapper.translatesAutoresizingMaskIntoConstraints = false
        viewWrapperHeightConstraints = self.viewWrapper.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor, multiplier: 1)
        viewWrapperHeightConstraints.isActive = true
        constantHeight = viewWrapperHeightConstraints.constant
        // Loading View
        self.loadingView.isHidden = true
        self.view.addSubview(self.loadingView)
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.loadingView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.loadingView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        // Decrease spacing between text and buttons
        if viewType == .login {
            self.loginButtonStack.setCustomSpacing(5, after: loginBtn)
            self.loginButtonStack.setCustomSpacing(5, after: loginAlternateLbl)
        }
        else {
            self.registerButtonStack.setCustomSpacing(5, after: registerBtn)
            self.registerButtonStack.setCustomSpacing(5, after: registerAlternateLbl)
        }
    }
    
    func setupRegisterConstraints() {
        // registerView constraints
        self.viewWrapper.addSubview(self.registerView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.viewWrapper.centerXAnchor).isActive = true
        self.registerView.topAnchor.constraint(equalTo: self.welcomeLbl.bottomAnchor, constant: 30).isActive = true
        self.registerView.bottomAnchor.constraint(equalTo: self.viewWrapper.bottomAnchor).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.viewWrapper.widthAnchor, multiplier: 1).isActive = true
    }
    
    func setupLoginConstriants() {
        // registerView constraints
        self.viewWrapper.addSubview(self.loginView)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.viewWrapper.centerXAnchor).isActive = true
        self.loginView.topAnchor.constraint(equalTo: self.welcomeLbl.bottomAnchor, constant: 30).isActive = true
        self.loginView.bottomAnchor.constraint(equalTo: self.viewWrapper.bottomAnchor).isActive = true
        self.loginView.widthAnchor.constraint(equalTo: self.viewWrapper.widthAnchor, multiplier: 1).isActive = true
    }
    
    func setupDatePicker() {
        // Set tags
        // UIPicker Tags
        let datePickerTag = self.registerDateOfBirthTf.tag
        // Setup Tool Bar
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barTintColor = .black
        toolbar.sizeToFit()
        // done button
        let flexibleSpace = CustomUIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = CustomUIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(sender:)))
        done.tintColor = .white
        done.setUserInfo(userInfo: ["tag": datePickerTag])
        toolbar.setItems([flexibleSpace, done], animated: true)
        // Format date picker
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(observeDatePicker), for: .valueChanged)
        //        datePicker.backgroundColor = .black
        //        datePicker.setValue(UIColor.white, forKey: "textColor")
        // set textfield to call datepicker
        registerDateOfBirthTf.inputAccessoryView = toolbar
        registerDateOfBirthTf.inputView = datePicker
    }
    
    func setupUIPicker() {
        // Set tags
        let genderPickerTag = self.registerGenderTf.tag
        // Setup Tool Bar
        let toolbar: UIToolbar = UIToolbar()
        toolbar.sizeToFit()
        // done button
        let flexibleSpace = CustomUIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = CustomUIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(sender:)))
        done.setUserInfo(userInfo: ["tag": genderPickerTag])
        toolbar.setItems([flexibleSpace, done], animated: true)
        //        genderPickerView.backgroundColor = .black
        //        genderPickerView.setValue(UIColor.white, forKey: "textColor")
        // set textfield to call uipicker
        registerGenderTf.inputAccessoryView = toolbar
        registerGenderTf.inputView = genderPickerView
    }
    
    @objc func observeDatePicker() {
        DispatchQueue.main.async {
            self.viewWrapperHeightConstraints.constant = self.constantHeight + 150
            self.registerDateOfBirthTf.text = self.datePicker.date.formatted
        }
    }
    
    @objc func setGenderDefaultValue() {
        DispatchQueue.main.async {
            self.registerGenderTf.text = Gender.male.description
            self.viewWrapperHeightConstraints.constant = self.constantHeight + 150
        }
    }
    
    @objc func donePressed(sender: CustomUIBarButtonItem) {
        if let tag = sender.userInfo["tag"] as? Int {
            if tag == self.registerDateOfBirthTf.tag {
                self.observeDatePicker()
                DispatchQueue.main.async {
                    self.registerGenderTf.becomeFirstResponder()
                }
            }
            else {
                if self.registerGenderTf.text == "" || self.registerGenderTf.text == nil {
                    self.setGenderDefaultValue()
                }
                DispatchQueue.main.async {
                    self.viewWrapperHeightConstraints.constant = self.constantHeight
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                }
            }
        }
        self.view.endEditing(true)
    }
    
    func showLoading(state: Bool) {
        if state {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.loadingView.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView.alpha = 0.4
            })
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView.isHidden = true
                self.loadingView.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
                self.loadingView.isHidden = true
            })
        }
    }
    
    // MARK: - Keyboard Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        DispatchQueue.main.async {
            if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
        }
        return false
    }
    
    func setupKeyboard() {
        // Keyboard Observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Set keyboard mood interactive
        self.scrollView.keyboardDismissMode = .interactive
        // Change keyboard return to next
        for tf in textFields {
            if tf == loginPasswordTf {
                continue
            }
            tf.returnKeyType = .next
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // Adds additional width to view wrapper to activate scroll
            DispatchQueue.main.async {
                self.viewWrapperHeightConstraints.constant = self.constantHeight + keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            self.viewWrapperHeightConstraints.constant = self.constantHeight
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.view.layoutIfNeeded()
        }
    }
}
