//
//  MainTabBarVC.swift
//  Dash
//
//  Created by Isaiah Wong on 29/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarVC: UITabBarController {
    
    // MARK: Properties
    
    // MARK: Methods
    func prepareInterface() {
        /** Create Button **/
        let button = generateButton(imageName: "add", upperBound: UIColor.PurpleBlue.upperBound, lowerBound: UIColor.PurpleBlue.lowerBound)
        self.view.insertSubview(button, aboveSubview: self.tabBar)
        self.tabBar.tintColor = UIColor.Palette.blue
        /** Button Actions **/
        button.addTarget(self, action: #selector(showPopUpControls), for: .touchUpInside)
    }
    
    func generateButton(imageName: String, upperBound: UIColor, lowerBound: UIColor) -> UIButton {
        let button = UIButton()
        var gradientLayer = CAGradientLayer()
        let imageLayer = CALayer()
        imageLayer.backgroundColor = UIColor.clear.cgColor
        // Some Hardcoded tested value
        imageLayer.frame = CGRect(x: 15 , y: 15, width: 20, height: 20)
        imageLayer.contents = UIImage(named: imageName)?.cgImage
        button.layer.cornerRadius = 25
        button.frame = CGRect.init(x: self.tabBar.center.x - 25, y: self.view.bounds.height - 74, width: 50, height: 50)
        button.setGradientBackground(
            gradientLayer: &gradientLayer,
            cornerRadius: 25,
            upperBound: upperBound,
            lowerBound: lowerBound,
            withImage: imageLayer
        )
        return button
    }
    
    @objc func showPopUpControls() {
        let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpControls") as! PopUpControlsVC
        popupVC.button = generateButton(imageName: "cross_blue", upperBound: .white, lowerBound: .white)
        self.addChildViewController(popupVC)
        popupVC.view.frame = self.view.frame
        TapticFeedback.feedback.heavy()
        self.view.addSubview(popupVC.view)
        popupVC.didMove(toParentViewController: self)
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInterface()
        // Push users to 
//        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
//            var dict = snapshot.value as! [String : Any]
//            for key in dict {
//                let id = key.key as! String
//                let value = key.value as! [String : Any]
//                let credentials = value["credentials"] as! [String : Any]
//                let email = credentials["email"] as! String
//                Database.database().reference().child("emails").childByAutoId().setValue(["userId" : id, "email" : email])
//            }
//        }
    }
}
