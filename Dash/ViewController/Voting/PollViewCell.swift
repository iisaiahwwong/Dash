//
//  PollViewCell.swift
//  Dash
//
//  Created by ITP312 on 10/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class PollViewCell: UITableViewCell {

    @IBOutlet weak var userBubbleInitials: UILabel!
    @IBOutlet weak var userBubble: UIView!
    @IBOutlet weak var voteRatioBar: UIView!
    @IBOutlet weak var radiobtn: UIImageView!
    @IBOutlet weak var voteText: UITextField!
    var isChecked = false;
   
    override func awakeFromNib() {
        
        super.awakeFromNib()
        userBubble.layer.cornerRadius = userBubble.frame.size.width/2
        voteRatioBar.isHidden = true;
//        userBubble.clipsToBounds = true;
//        userBubble.layer.borderColor = UIColor.white.cgColor;
//        userBubble.layer.borderWidth = 5.0;
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
