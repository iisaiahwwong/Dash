//
//  RoundedView.swift
//  Dash
//
//  Created by Isaiah Wong on 4/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//
import UIKit

class RoundedView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Drop shadow settings
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}


