//
//  CardShadow.swift
//  Dash
//
//  Created by Isaiah Wong on 23/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class CardShadow: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Drop shadow settings
        self.layer.cornerRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
    }
}
