//
//  AuthenticationVC.swift
//  Dash
//
//  Created by Isaiah Wong on 27/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class AuthenticationVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var registerView: UIView!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var registerButtonStack: UIStackView!
    @IBOutlet weak var registerBtn: RoundedButton!
    @IBOutlet weak var registerFbBtn: RoundedButton!
    @IBOutlet weak var registerAlternateLbl: UILabel!
    @IBOutlet weak var registerNameTf: UITextField!
    @IBOutlet weak var registerEmailTf: UITextField!
    @IBOutlet weak var registerPasswordTf: UITextField!
    @IBOutlet weak var registerDateOfBirthTf: UITextField!
    @IBOutlet weak var registerGenderTf: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var loginPasswordTf: UITextField!
    @IBOutlet weak var loginEmailTf: UITextField!
    @IBOutlet weak var loginBtn: RoundedButton!
    @IBOutlet weak var loginAlternateLbl: UILabel!
    @IBOutlet weak var loginFbBtn: RoundedButton!
    @IBOutlet weak var loginButtonStack: UIStackView!
    
    @IBOutlet var textFields: [UITextField]!
    let datePicker = UIDatePicker()
    let genderPickerView = UIPickerView()
    var viewWrapperHeightConstraints: NSLayoutConstraint!
    var constantHeight: CGFloat!
    
    var viewType: ViewType!
    
    let home = Notification.Name(rawValue: HomeScreenNotificationKey)
    let register = Notification.Name(rawValue: RegisterScreenNotificationKey)
    
    // MARK: IBActions
    @IBAction func register(_ sender: UIButton) {
        for tf in self.textFields {
            tf.resignFirstResponder()
        }
        showLoading(state: true)
        
        let name = registerNameTf.text!
        let email = registerEmailTf.text!
        let password = registerPasswordTf.text!
        let gender = registerGenderTf.text!
        let dateOfBirth = datePicker.date
        
        // TODO: Validation
        // Register
        AuthProvider.auth().register(name: name, email: email, gender: gender, dateOfBirth: dateOfBirth, password: password, profileImg: nil)
        { (status, error) in
            self.showLoading(state: false)
            if status {
                self.prepareForMainView(status: status)
            }
            else {
                // TODO: Handle error
                print(error!)
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        for tf in self.textFields {
            tf.resignFirstResponder()
        }
        self.showLoading(state: true)
        let email = loginEmailTf.text!
        let password = loginPasswordTf.text!
        AuthProvider.auth().login(withEmail: email, password: password) { (msg, user) in
            self.showLoading(state: false)
            if (user != nil) {
                self.prepareForMainView(status: true)
            }
            else {
                // TODO: Handle error
                print(msg)
            }
        }
    }
    
    private func setupDelegates() {
        for tf in textFields {
            tf.delegate = self
        }
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
    }
    
    
    
    private func prepareForMainView(status: Bool) {
        if status {
            DispatchQueue.main.async {
                self.pushToMainView(completion: { (status) in
                    if status {
                        for tf in self.textFields {
                            tf.text = ""
                        }
                    }
                })
            }
        }
        return
    }
    
    private func pushToMainView(completion:  ((Bool) -> Void)?) {
        self.dismiss(animated: false)
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch viewType! {
        case .register:
            self.setupRegisterConstraints()
        case .login:
            self.setupLoginConstriants()
        }
        self.setupConstraints()
        self.setupDelegates()
        self.setupDatePicker()
        self.setupUIPicker()
        self.setupKeyboard()
    }
}

extension AuthenticationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Gender(rawValue: row)?.description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.viewWrapperHeightConstraints.constant = self.constantHeight
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        registerGenderTf.text = Gender(rawValue: row)?.description
    }
}
