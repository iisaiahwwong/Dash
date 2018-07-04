//
//  MainVC.swift
//  Dash
//
//  Created by Isaiah Wong on 9/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

enum DefineCell: CGFloat {
    // Height of Top View + Bottom Constraints + Parent's Bottom Contraints
    case normalHeight = 140
    case expandedHeight = 300
}

class TestVC: UIViewController {
    
    // MARK: Properties
    var selectedCellIndexPath: IndexPath?
    
    // MARK: IB
    @IBOutlet weak var activitiesTableView: UITableView!
    
    // MARK: Methods
    
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        activitiesTableView.dataSource = self
        activitiesTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TestVC: ActivityCellDelegate {
    
    func didTapTopSectionCell(_ indexPath: IndexPath) {
        // Closes tableview
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
        } else {
            selectedCellIndexPath = indexPath
        }
        
        updateTable(tableView: self.activitiesTableView, indexPath: indexPath)
    }
}

extension TestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Changes Height of the cells
        let height: DefineCell = self.selectedCellIndexPath == indexPath ? DefineCell.expandedHeight : DefineCell.normalHeight
        return height.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Closes cells
        self.selectedCellIndexPath = indexPath
        updateTable(tableView: tableView, indexPath: indexPath)
    }
    
    func updateTable(tableView: UITableView, indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }
}

