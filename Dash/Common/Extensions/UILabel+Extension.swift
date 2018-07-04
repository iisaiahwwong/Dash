//
//  UILabel.swift
//  Countdown
//
//  Created by Isaiah Wong on 28/9/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

extension UILabel{
    func addTextSpacing(spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSRange(location: 0, length: self.text!.count - 1))
        self.attributedText = attributedString
    }
}

