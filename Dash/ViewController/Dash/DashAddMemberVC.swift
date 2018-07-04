//
//  DashAddMemberVC.swift
//  Dash
//
//  Created by Isaiah Wong on 27/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class DashAddMemberVC: UIViewController, UISearchBarDelegate {
    
    // MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var emails: [EmailUser] = []
    var filteredEmails: [EmailUser] = []
    
    struct EmailUser {
        var userId: String!
        var email: String!
    }
    
    // MARK: Methods
    @IBAction func cancelDidTap(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchData() {
        User.getAllEmails { [weak weakSelf = self] (dict) in
            for value in dict {
                let dict = value.value as! [String: Any]
                let email = dict["email"] as! String
                let userId = dict["userId"] as! String
                if weakSelf!.filterExisting(userId: userId) {
                    weakSelf!.emails.append(EmailUser(userId: userId, email: email))
                }
            }
        }
    }
    
    private func filterExisting(userId: String) -> Bool {
        if userId == DashVC.selectedDash!.userId {
            return false
        }
        for member in DashVC.selectedDash!.members {
            if userId == member.id {
                return false
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keywords = searchText.replacingOccurrences(of: " ", with: "")
        filter(keywords)
    }
    
    private func filter(_ keywords: String) {
        if keywords.isEmpty {
            self.filteredEmails = []
        }
        if !(emails.count < 1) {
            self.filteredEmails = self.emails.filter({ (emailUser) -> Bool in
                return emailUser.email.lowercased().contains(keywords.lowercased())
            })
        }
        self.tableView.reloadData()
    }
    
    static func storyboardInstance() -> DashAddMemberVC? {
        return UIStoryboard(name: "DashDetails", bundle: nil).instantiateViewController(withIdentifier: "DashAddMember") as? DashAddMemberVC
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.fetchData()
    }
}

extension DashAddMemberVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredEmails.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = filteredEmails[indexPath.row].userId
        DashVC.selectedDash?.addMembers(userId: userId!, { (user, status) in
            if status {
                NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateMembersCell), object: nil, userInfo: ["user" : user])
                NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateMembers), object: nil)
                self.close()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddingMemberCell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = self.filteredEmails[indexPath.row].email
        return cell
    }
}
