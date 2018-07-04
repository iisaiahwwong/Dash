//
//  CardDrawCell.swift
//  Dash
//
//  Created by yunfeng on 6/2/18.
//  Copyright © 2018 Keane Ruan. All rights reserved.
//

import UIKit

/*protocol CardDrawCellDelegate {
    func cardDrawCell(cell: CardDrawCell, cellHeight: Int, indexPath: IndexPath)
}*/

class CardDrawCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var drawPreview: UIImageView!
    
    var indexPath: IndexPath?
    var content: CardContent?
    var draw: Draw?
    
    //var delegate: CardDrawCellDelegate?
    
    // MARK: Method
    func prepare(draw: Draw, tableView: UITableView) {
        self.draw = draw
        if let path = draw.imagePath {
            self.drawPreview.loadImageUsingCacheWithUrlString(urlString: path)
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.drawPreview.layer.cornerRadius = 25.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

