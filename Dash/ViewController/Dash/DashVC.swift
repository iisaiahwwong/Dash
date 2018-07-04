//
//  DashVC.swift
//  Dash
//
//  Created by Isaiah Wong on 29/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

let selectedDashKey = "com.dash.selectedDashKey"
let selectedTranscriptKey = "com.dash.selectedTranscriptKey"

class DashVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var dashCollectionView:
    UICollectionView!
    static var selectedDash: Dash?
    var dashs: [Dash] = []
    
    // MARK: Methods
    private func fetchData() {
        Dash.getAllDash { [weak weakSelf = self] (dash) in
            weakSelf!.appendDash(dash: dash)
        }
        
        Dash.getAllSharedDash { [weak weakSelf = self] (dash) in
            weakSelf!.appendDash(dash: dash)
        }
    }
    
    func appendDash(dash: Dash) {
        self.dashs.append(dash)
        self.dashs.sort{ $0.dueDate < $1.dueDate }
        DispatchQueue.main.async {
            self.dashCollectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashDetails" {
            if let vc = segue.destination as? DashDetailsVC {
                let cell = sender as! DashCollectionCell
                let dash = self.dashs[self.dashCollectionView.indexPath(for: cell)!.row]
                vc.dash  = dash
                DashVC.selectedDash = dash
                TapticFeedback.feedback.heavy()
            }
        }
    }
    
    func prepareInterface() {
        // Hides nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.barTintColor = UIColor.ColorProfileFix.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 20)!,
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]

        self.dashCollectionView.alwaysBounceVertical = true
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInterface()
        // Set Delegates
        self.dashCollectionView.delegate = self
        self.dashCollectionView.dataSource = self
        self.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DashVC.selectedDash = nil
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension DashVC: UICollectionViewDataSource, UICollectionViewDelegate, DashCreateCellDelegate {
    func showPopup() {
        let popupVC = UIStoryboard(name: "Dash", bundle: nil).instantiateViewController(withIdentifier: "DashCreatePopUp") as! DashCreatePopUpVC
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /**
         * Returns one instance of CreateDashCollectionCell if Dashs is empty
         */
        return dashs.count < 1 ? 1 : dashs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Returns Create Cell if dash is empty
        if dashs.count < 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateDashCell", for: indexPath) as? DashCreateCollectionCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashCell", for: indexPath) as? DashCollectionCell else {
            return UICollectionViewCell()
        }
        cell.prepare(dash: dashs[indexPath.row])
        return cell
    }
}
