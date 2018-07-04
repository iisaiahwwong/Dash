//
//  VoteTableViewCell.swift
//  Dash
//
//  Created by ITP312 on 20/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var voteText: UITextField!
    //MARK: Properties

    
    @IBOutlet weak var voteCheckBox: UIImageView!
    var checked = false;
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
