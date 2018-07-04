//
//  DashMemberCell.swift
//  Dash
//
//  Created by Isaiah Wong on 25/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class DashMemberCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
