//
//  DashAddMemberCell.swift
//  Dash
//
//  Created by Isaiah Wong on 25/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol DashAddMemberDelegate {
    func dashAddMemberCell(didTap: DashAddMemberCell, _ viewController: UIViewController)
}

class DashAddMemberCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var addMemberRow: UIView!
    var delegate: DashAddMemberDelegate!
    
    @objc private func addMembers() {
        delegate.dashAddMemberCell(didTap: self, DashAddMemberVC.storyboardInstance()!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.addMembers))
        contentView.addGestureRecognizer(tap)
    }
}
