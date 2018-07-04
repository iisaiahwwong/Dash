//
//  ChatVC.swift
//  Dash
//
//  Created by Isaiah Wong on 9/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthProvider.auth().getCurrentUser() == nil {
            AuthProvider.auth().login(withEmail: "email", password: "", completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
