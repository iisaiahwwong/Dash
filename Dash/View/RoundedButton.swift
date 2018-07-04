//
//  RoundedButton.swift
//  Dash
//
//  Created by Isaiah Wong on 10/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        increaseSpacing(5.0)
    }
    
    func increaseSpacing(_ spacing: Double) {
        guard let title = self.title(for: .normal) else {
            return
        }
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedStringKey.kern: spacing])
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
}
