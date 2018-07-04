//
//  UserInteraction.swift
//  Dash
//
//  Created by Isaiah Wong on 1/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class InteractionAnimation: NSObject {
    
    private static let sharedInstance: InteractionAnimation = InteractionAnimation()
    
    override private init() { }
    
    static func animation() -> InteractionAnimation {
        return self.sharedInstance
    }
    
    /**
     * RECOMMENDED VALUES
     * duration: 0.07
     * repeatCount: 3,
     * autoreverse: true,
     * fromValue: CGPoint(x: object.center.x - 10, y: object.center.y),
     * toValue: CGPoint(x: object.center.x + 10, y: object.center.y)
     */
    func shakeView(layer: CALayer, duration: Double, repeatCount: Float, autoreverse: Bool, fromValue: CGPoint, toValue: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverse
        animation.fromValue = NSValue(cgPoint: fromValue)
        animation.toValue = NSValue(cgPoint: toValue)
        layer.add(animation, forKey: "position")
    }
}
