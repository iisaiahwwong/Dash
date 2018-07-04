//
//  DashAddMembersVC.swift
//  Dash
//
//  Created by Isaiah Wong on 25/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

let UpdateMembersCell = "com.dash.update.cell.members"

class DashMembersVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    let UpdateMembersKey = Notification.Name(rawValue: UpdateMembersCell)
    var members: [Any] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    static func storyboardInstance() -> DashMembersVC? {
        return UIStoryboard(name: "DashDetails", bundle: nil).instantiateViewController(withIdentifier: "DashMembers") as? DashMembersVC
    }
    
    func prepare() {
        // Add arbitrary value to first index
        members.append(0)
        // Copy data
        for member in DashVC.selectedDash!.members {
            members.append(member)
        }
    }
    
    @objc func getMembers(notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            self.members.append(user)
            self.tableView.reloadData()
        }
    }
    
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.getMembers(notification:)), name: UpdateMembersKey, object: nil)
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        prepare()
        createObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension DashMembersVC: UITableViewDelegate, UITableViewDataSource, DashAddMemberDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func dashAddMemberCell(didTap: DashAddMemberCell, _ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row  {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberAddCell", for: indexPath) as? DashAddMemberCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? DashMemberCell else {
                return UITableViewCell()
            }
            let user = members[row] as! User
            cell.emailLabel.text = user.email
            cell.nameLabel.text = user.name
            cell.initialsLabel.text = user.name.getInitials()
            return cell
        }
    }
}
