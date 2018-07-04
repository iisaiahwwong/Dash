//
//  DashCollectionCell.swift
//  Dash
//
//  Created by Isaiah Wong on 30/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class DashCollectionCell: UICollectionViewCell {
    // MARK: Properties
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var dashTitle: UILabel!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var daysLabel: UILabel!
    
    let EXPIRE_PLACEHOLDER = "DUE"
    
    var dash: Dash?
    
    func prepare(dash: Dash) {
        self.dash = dash
        self.dashTitle.text = dash.title
        if dash.countdown < 1 {
            self.countdown.text = self.EXPIRE_PLACEHOLDER
            self.countdown.font = self.countdown.font.withSize(55)
            self.cardView.backgroundColor = UIColor.PinkOrange.upperBound
            self.daysLabel.isHidden = true
        }
        else {
            self.countdown.text = String(dash.countdown)
            self.countdown.font = self.countdown.font.withSize(70)

            self.cardView.backgroundColor = UIColor.PurpleBlue.lowerBound
            self.daysLabel.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
