//
//  PopUpControls.swift
//  Dash
//
//  Created by Isaiah Wong on 2/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class PopUpControlsVC: UIViewController {
    
    // MARK: Properites
    var prevVC: UIViewController?
    var button: UIButton?
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    // MARK: Methods
    @IBAction func showDashCreate(_ sender: UIButton) {
        animateOut()
        let popupVC = DashCreatePopUpVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func showTranscript(_ sender: UIButton) {
        animateOut()
        if DashVC.selectedDash == nil {
            self.present(self.getAlert(), animated: true, completion: nil)
            return
        }
        let popupVC = TranscriptVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func showCardEdit(_ sender: Any) {
        animateOut()
        if DashVC.selectedDash == nil {
            self.present(self.getAlert(), animated: true, completion: nil)
            return
        }
        let popupVC = CardEditVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func showImageToText(_ sender: Any) {
        animateOut()
        let popupVC = ScanDocumentVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func addVote(_ sender: Any) {
        animateOut()
        let popupVC = CardEditVC.storyboardInstance()!
        let pvc = self.prevVC as! CardEditVC
        popupVC.card = pvc.card
        popupVC.tblEdit = pvc.tblEdit
        popupVC.addVote();
    }
    
    func getAlert() -> UIAlertController {
        let alertController = UIAlertController(title: "Please Select a Dash", message: nil, preferredStyle: .alert)
        let message = UIAlertAction(title: "Okay", style: .default) { [weak weakSelf = self] (action) in
        }
        alertController.addAction(message)
        return alertController
    }
    
    private func prepareInterface() {
        guard let button = self.button else {
            self.animateOut()
            return
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.gradientLayer.opacity = 0
        self.view.setGradientBackground(gradientLayer: &self.gradientLayer, upperBound: UIColor.PurpleBlue.upperBound, lowerBound: UIColor.PurpleBlue.lowerBound)
        self.view.insertSubview(button, aboveSubview: self.view)
        button.addTarget(self, action: #selector(animateOut), for: .touchUpInside)
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

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInterface()
        animate()
    }
}
