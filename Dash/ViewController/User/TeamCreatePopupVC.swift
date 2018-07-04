//
//  TeamCreatePopup.swift
//  Dash
//
//  Created by Isaiah Wong on 23/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class TeamCreatePopupVC: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet var viewWrapper: UIView!
    @IBOutlet weak var teamTextField: UITextField!
    @IBOutlet weak var cardBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardView: CardView!
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()

    // MARK: Methods
    static func storyboardInstance() -> TeamCreatePopupVC? {
        return UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "TeamCreatePopup") as? TeamCreatePopupVC
    }
    
    @IBAction func close(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func create(_ sender: Any) {
        if !self.validate() {
            return
        }
        // Create a Team
        let teamName = teamTextField.text!
        guard let userId = AuthProvider.auth().getCurrentUser()?.uid else {
            return
        }
        let team = Team(name: teamName, createdAt: Date(), teamLeaderId: userId)
        team.create { [weak weakSelf = self]  (status) in
            if status != true {
                // TODO: Retry call and return
            }
            DispatchQueue.main.async {
                weakSelf!.animateOut()
            }
        }
    }
    
    private func validate() -> Bool {
        guard let team = self.teamTextField.text else {
            return false
        }
        if team.isEmpty {
            // Animate TextField
            InteractionAnimation.animation().shakeView(
                layer: self.teamTextField.layer,
                duration: 0.07,
                repeatCount: 3,
                autoreverse: true,
                fromValue: CGPoint(x: self.teamTextField.center.x - 10, y: self.teamTextField.center.y),
                toValue: CGPoint(x: self.teamTextField.center.x + 10, y: self.teamTextField.center.y)
            )
            return false
        }
        return true
    }
    
    private func animate() {
        self.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
            self.gradientLayer.opacity = 0.87
        }
    }
    
    @objc private func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.gradientLayer.opacity = 0
        }) { (success) in
            self.view.removeFromSuperview()
        }
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(moveDistance: CGFloat) {
        cardBottomConstraint.constant = moveDistance
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(moveDistance: 200)
    }
    
    private func prepareInterface() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.gradientLayer.opacity = 0
        self.view.setGradientBackground(gradientLayer: &self.gradientLayer, upperBound: UIColor.PurpleBlue.upperBound, lowerBound: UIColor.PurpleBlue.lowerBound)
        self.teamTextField.becomeFirstResponder()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamTextField.delegate = self
        prepareInterface()
        animate()
    }
}
