//
//  String+Extension.swift
//  Dash
//
//  Created by Isaiah Wong on 5/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func getInitials() -> String {
        return self.uppercased().components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.characters.first!)") + "\($1.characters.first!)" }
    }
    
    
}
