//
//  CreateDashCollectionCell.swift
//  Dash
//
//  Created by Isaiah Wong on 30/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

protocol DashCreateCellDelegate {
    func showPopup()
}

class DashCreateCollectionCell: UICollectionViewCell {
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var tapArea: UIView!
    
    var delegate: DashCreateCellDelegate?
    
    // MARK: Methods
    func registerRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPopup(sender:)))
        self.tapArea.addGestureRecognizer(tap)
    }
    
    @objc func showPopup(sender: UITapGestureRecognizer) throws {
        delegate?.showPopup()
    }
    
    override func layoutSubviews() {
        registerRecognizer()
    }
}
