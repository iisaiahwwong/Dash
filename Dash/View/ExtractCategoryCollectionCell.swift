//
//  ExtractCategoryCollectionCell.swift
//  Dash
//
//  Created by Isaiah Wong on 28/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class ExtractCategoryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var count: UILabel!
    
    override var isSelected: Bool{
        didSet {
            if self.isSelected {
                self.cardView.backgroundColor = UIColor.Palette.blue
                self.category.textColor = UIColor.white
                self.count.textColor = UIColor.white
            }
            else {
                self.cardView.backgroundColor = UIColor.white
                self.category.textColor = UIColor.black
                self.count.textColor = UIColor.black
            }
        }
    }
}
