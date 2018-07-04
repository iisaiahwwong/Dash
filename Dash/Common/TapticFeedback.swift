//
//  Feedback.swift
//  Dash
//
//  Created by Isaiah Wong on 28/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

typealias None = () -> ()

struct TapticFeedback {
    static let feedback = TapticFeedback()
    
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        return
    }
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        return
    }
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        return
    }
    
    private init() { }
}

