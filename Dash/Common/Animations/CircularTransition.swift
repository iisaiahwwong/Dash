//
//  CircularTransition.swift
//  Countdown
//
//  Created by Isaiah Wong on 30/9/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {
    
    var circle: UIView = UIView()
    
    var startingPoint: CGPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    
    var circleColor: UIColor = .white
    
    let duration: Double = 1.2
    
    var transitionMode: CircularTransitionMode = .present
    
    enum CircularTransitionMode: Int {
        case present, dismiss, pop
    }
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if transitionMode == .present {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.timingFunction = CAMediaTimingFunction(controlPoints: 5/6, 0.2, 2/6, 0.9)
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 1
                
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                
                circle = UIView()
                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                circle.layer.cornerRadius = circle.frame.size.height / 2
                let borderWidth: CGFloat = 2.0
                circle.layer.borderWidth = borderWidth;
                circle.layer.borderColor = UIColor.black.cgColor
                circle.layer.add(animation, forKey: nil)
                circle.center = startingPoint
                circle.backgroundColor = circleColor
                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                containerView.addSubview(circle)
                
                presentedView.center = startingPoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentedView.layer.add(animation, forKey: nil)
                presentedView.alpha = 0
                containerView.addSubview(presentedView)
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = CGAffineTransform.identity
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 1
                    presentedView.center = viewCenter
                }, completion: { (success: Bool) in
                    transitionContext.completeTransition(success)
                })
            }
        }
        else {
            let transitionModeKey = transitionMode == .pop ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returningView = transitionContext.view(forKey: transitionModeKey) {
                let viewCenter = returningView.center
                let viewSize = returningView.frame.size
                
                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                
                circle.layer.cornerRadius = circle.frame.size.height / 2
                circle.center = startingPoint
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returningView.center = self.startingPoint
                    returningView.alpha = 0
                    
                    if self.transitionMode == .pop {
                        containerView.insertSubview(returningView, belowSubview: returningView)
                        containerView.insertSubview(self.circle, belowSubview: returningView)
                    }
                }, completion: { (success: Bool) in
                    returningView.center = viewCenter
                    returningView.removeFromSuperview()
                    
                    self.circle.removeFromSuperview()
                    transitionContext.completeTransition(success)
                })
            }
        }
    }
    
    func frameForCircle(withViewCenter viewCenter: CGPoint, size viewSize: CGSize, startPoint: CGPoint ) -> CGRect {
        let xLength = fmax(startingPoint.x, viewSize.width - startingPoint.x)
        let yLength = fmax(startingPoint.y, viewSize.height - startingPoint.y)
        
        let offSetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offSetVector, height: offSetVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
}
