//
//  SubviewTest.swift
//  Dash
//
//  Created by ITP312 on 28/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class SubviewTest: UIView {
    var shouldSetupConstraints = true
    
    var tableView: UIView!
    
    let screenSize = UIScreen.main.bounds
    
        
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints){
            //autolayoutconstraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
