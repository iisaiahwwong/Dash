//
//  LaunchScreenVC.swift
//  Dash
//
//  Created by Isaiah Wong on 21/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

let HomeScreenNotificationKey = "com.dash.home"
let RegisterScreenNotificationKey = "com.dash.register"

class LaunchScreenVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet var bg: UIView!
    
    let home = Notification.Name(rawValue: HomeScreenNotificationKey)
    let register = Notification.Name(rawValue: RegisterScreenNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Methods
    func pushToAuthenticateView() {
        present(InitialVC.toNavigationVC(viewController: InitialVC.storyboardInstance()!), animated: true, completion: nil)
    }
    
    @objc func pushToMain(notification: NSNotification) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBar") as! MainTabBarVC
        self.present(vc, animated: true) {
            
        }
    }
    
    internal func isAuthenticated() {
        if let user = AuthProvider.auth().getCurrentUser() {
            NotificationCenter.default.post(name: home, object: nil)
            AuthProvider.auth().interpolateUser(userId: user.uid, completion: nil)
            return
        }
        // Push to Login
        self.pushToAuthenticateView()
    }
    
    func createObservers() {
        // Home
        NotificationCenter.default.addObserver(self, selector: #selector(pushToMain(notification:)), name: home, object: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var gradientLayer: CAGradientLayer = CAGradientLayer()
        self.bg.setGradientBackground(gradientLayer: &gradientLayer, upperBound: UIColor.PurpleBlue.upperBound, lowerBound: UIColor.PurpleBlue.lowerBound)
        createObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        AuthProvider.auth().logout()
        self.isAuthenticated()
    }
}
