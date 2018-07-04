//
//  DashHeader.swift
//  Dash
//
//  Created by Isaiah Wong on 24/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class DashHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    
    /**
     * Resolves bug of navigation item having a size of 0 0
     */
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 197, height: 44)
    }
}
