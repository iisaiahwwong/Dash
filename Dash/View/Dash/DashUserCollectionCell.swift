//
//  DashUserCollectionCell.swift
//  Dash
//
//  Created by Isaiah Wong on 4/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class DashUserCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var userInitialsLabel: UILabel!
    
    var userOnlineStatus: UserOnlineStatus!
    
    func prepare(userOnlineStatus: UserOnlineStatus) {
        self.userOnlineStatus = userOnlineStatus
        self.userInitialsLabel.text = self.userOnlineStatus.userInitials
    }
}
