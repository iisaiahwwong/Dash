//
//  UserSettingCell.swift
//  Dash
//
//  Created by Isaiah Wong on 22/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol UserSettingCellDelegate {
    func didTap(_ viewController: UIViewController)
    
    func logout()
}

class UserSettingCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var wrapperView: CardView!
    @IBOutlet weak var seperator: UIView!

    var object: UserSettingRow!
    var delegate: UserSettingCellDelegate!
    
    // MARK: Methods
    func prepare(object: UserSettingRow) {
        self.object = object
        self.icon.image = self.object.icon
        self.title.text = self.object.name
        self.wrapperView.layer.shadowOpacity = 0.3
        self.wrapperView.layer.cornerRadius = 2.0
    }
    
    func prepareInterface() {
        // Change UI
        switch(self.object) {
        case is UserVC.TeamCreate:
            self.title.font = UIFont(name: "Gotham-Bold", size: self.title.font.pointSize)
            self.title.textColor = UIColor.Palette.blue
        default:
            self.title.font = UIFont(name: "Gotham-Book", size: self.title.font.pointSize)
            self.title.textColor = UIColor.black
        }
    }
    
    @objc func handleTap() {
        switch(self.object) {
        case is UserVC.TeamCreate:
            delegate.didTap(TeamCreatePopupVC.storyboardInstance()!)
        case is UserVC.Account:
            delegate.logout()
            break
        default:
            return
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        wrapperView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
