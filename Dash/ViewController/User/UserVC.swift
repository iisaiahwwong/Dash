//
//  UserVC.swift
//  Dash
//
//  Created by Isaiah Wong on 1/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol UserSettingRow {
    var name: String! { get set }
    var icon: UIImage! { get set }
}

class UserVC: UIViewController {
    // MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    enum SectionRow: String {
        case team = "Teams"
        case account = "Account"
    }
    
    struct Section {
        var sectionName: SectionRow!
        var sectionObjects: [AnyObject]!
    }
    
    struct TeamRow: UserSettingRow {
        var name: String!
        var icon: UIImage!
        var team: Team!
    }
    
    struct TeamCreate: UserSettingRow {
        var name: String!
        var icon: UIImage!
    }
    
    struct Account: UserSettingRow {
        var name: String!
        var icon: UIImage!
    }
    
    private var sectionArray = [Section]()
    
    // MARK: Methods
    func prepareInterface() {
        guard let user = AuthProvider.auth().getCurrentUserModel() else {
            return
        }
        self.usernameLabel.text = user.name
    }
    
    func interpolateSections() {
        self.sectionArray = [
            Section(sectionName: .team, sectionObjects: [TeamCreate(name: "Create Team", icon: UIImage(named: "create_dash")) as AnyObject]),
            Section(sectionName: .account, sectionObjects: [Account(name: "Logout", icon: UIImage(named: "logout")) as AnyObject])
        ]
        fetchTeams()
    }
    
    func fetchTeams() {
        Team.getAllTeams { [weak weakSelf = self] (team) in
            if let i = weakSelf?.sectionArray.index(where: { $0.sectionName == .team }) {
                weakSelf!.sectionArray[i].sectionObjects.insert(
                    TeamRow(name: team.name, icon: UIImage(named: "team_purple"), team: team) as AnyObject, at: 0
                )
                DispatchQueue.main.async {
                    weakSelf!.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.prepareInterface()
        self.interpolateSections()
    }
}

extension UserVC: UITableViewDelegate, UITableViewDataSource, UserSettingCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserSettingCell") as? UserSettingCell else {
            return UITableViewCell()
        }
        let object = sectionArray[indexPath.section].sectionObjects[indexPath.row]
        cell.prepare(object: object as! UserSettingRow)
        cell.prepareInterface()
        cell.delegate = self
        
        // Set seperator of last cell to hidden
        cell.seperator.isHidden = sectionArray[indexPath.section].sectionObjects.count - 1 == indexPath.row ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor.Palette.lightGrey
        let borderBottom = UIView(frame: CGRect(x: 0, y: 28, width: tableView.bounds.size.width, height: 0.5))
        borderBottom.backgroundColor = UIColor.black
        borderBottom.alpha = 0.2
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.bounds.width - 30, height: 25))
        label.font = UIFont(name: "Gotham-Bold", size: 12)
        label.textColor = UIColor.black
        label.text = sectionArray[section].sectionName.rawValue.uppercased()
        label.addTextSpacing(spacing: 1)
        view.addSubview(label)
        view.addSubview(borderBottom)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10))
        let borderBottom = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.5))
        borderBottom.backgroundColor = UIColor.black
        borderBottom.alpha = 0.2
        view.backgroundColor = UIColor.Palette.lightGrey
        view.addSubview(borderBottom)
        return view
    }

    func didTap(_ viewController: UIViewController) {
        self.addChildViewController(viewController)
        viewController.view.frame = self.view.frame
        TapticFeedback.feedback.heavy()
        self.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func logout() {
        AuthProvider.auth().logout()
        self.dismiss(animated: false)
    }
}
