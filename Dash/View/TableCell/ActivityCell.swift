//
//  ActivityCell.swift
//  SmartHealth
//
//  Created by Isaiah Wong on 5/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

protocol ActivityCellDelegate {
    func didTapTopSectionCell(_ indexPath: IndexPath)
}

class ActivityCell: UITableViewCell {

    // MARK: Properties
    var delegate: ActivityCellDelegate?
    var indexPath: IndexPath?
    
    // MARK: IB Properties
    @IBOutlet weak var topSectionView: UIView!
    
    // MARK: Methods
    @objc func didTapView() {
        if let indexPath = self.indexPath {
            self.delegate?.didTapTopSectionCell(indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        self.topSectionView.addGestureRecognizer(gesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
