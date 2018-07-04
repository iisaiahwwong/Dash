//
//  InitialVC.swift
//  Dash
//
//  Created by Isaiah Wong on 27/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    // MARK: Methods
    static func storyboardInstance() -> InitialVC? {
        return UIStoryboard(name: "Initial", bundle: nil).instantiateViewController(withIdentifier: "Initial") as? InitialVC
    }
    
    static func toNavigationVC(viewController: InitialVC) -> UINavigationController{
        return UINavigationController(rootViewController: viewController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AuthenticationVC {
            destination.viewType = segue.identifier == "PresentLogin" ? .login : .register
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 255, g: 255, b: 255, a: 1)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
