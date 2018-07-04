//
//  DashDropdown.swift
//  Dash
//
//  Created by Isaiah Wong on 24/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol DashDropdownDelegate {
    func dashDropdown(didTap: DashDropdown, _ viewController: UIViewController)
}

class DashDropdown: UIView {
    
    // MARK: Properties
    @IBOutlet weak var membersRow: UIView!
    var delegate: DashDropdownDelegate!
    
    @objc private func loadMembers() {
        self.delegate.dashDropdown(didTap: self, DashMembersVC.storyboardInstance()!)
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.loadMembers))
        membersRow.addGestureRecognizer(tap)
    }
}
