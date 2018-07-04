//
//  DashCardVC.swift
//  Dash
//
//  Created by Isaiah Wong on 1/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

let UpdateTranscript = "com.dash.update.transcript"
let UpdateMembers = "com.dash.update.main.members"
let UpdateCardContent = "com.card.update.cards.content"

class DashDetailsVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var transcriptView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var viewWrapper: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var dashHeader: DashHeader!
    @IBOutlet weak var dashHeaderView: UIView!
    
    @IBOutlet weak var dropdownView: DashDropdown!
    @IBOutlet weak var dropdownViewTouchEvent: UIView!
    
    @IBOutlet weak var transcriptPlaceholder: UIView!
    @IBOutlet weak var cardPlaceholder: UIView!
    
    var transcriptViewTopConstraint: NSLayoutConstraint!
    var cardViewTopConstraint: NSLayoutConstraint!
    var dropDownViewTopConstraint: NSLayoutConstraint!
    var dropDownViewBottomConstraint: NSLayoutConstraint!
    
    let UpdateTranscriptKey = Notification.Name(rawValue: UpdateTranscript)
    let UpdateMembersKey = Notification.Name(rawValue: UpdateMembers)
    let UpdateCardContentsKey = Notification.Name(rawValue: UpdateCardContent)
    
    var dash: Dash?
    static var selectedTranscript: Transcript?
    
    var users: [UserOnlineStatus] = []
    var cards: [Card] = []
    var transcripts: [Transcript] = []
    
    var transcriptFilter: SearchFilter = SearchFilter(searchCollection: nil)
    var cardFilter: SearchFilter = SearchFilter(searchCollection: nil)

    var isSearching: Bool = false
    
    var isCardView: Bool = true
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Methods
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex) {
        case 0: // card
            self.transcriptViewTopConstraint.constant = 1000
            self.cardViewTopConstraint.constant = 12
            self.isCardView = true
            self.cardFilter.searchString = "" // Reset Search
        case 1: // transcript
            self.transcriptViewTopConstraint.constant = 12
            self.cardViewTopConstraint.constant = 1000
            self.isCardView = false
            self.transcriptFilter.searchString = "" // Reset Search
        default:
            break
        }
        self.view.layoutIfNeeded()
    }
    
    func fetchData() {
        guard let id = dash?.id else {
            return
        }
        // Get all transcript
        Transcript.getAllTranscripts(dashId: id) { [weak weakSelf = self] (transcript) in
            weakSelf?.transcriptPlaceholder.isHidden = true
            weakSelf?.transcripts.append(transcript)
            weakSelf?.transcripts.sort{ $0.dateCreated > $1.dateCreated }
            weakSelf?.transcriptFilter.searchCollection?.addTranscriptToCollection(transcript: transcript)
            weakSelf?.transcriptFilter.searchString = ""
            DispatchQueue.main.async {
                weakSelf?.tableView.reloadData()
            } 
        }
        // Get all Cards
        Card.getAllCards(dashId: id) { [weak weakSelf = self] (card) in
            self.cardPlaceholder.isHidden = true
            // Create Observers for each card
            card.getUpdatesForCardContents({ (cardContent) -> (Void) in
                // Post Notification
                NotificationCenter.default.post(name: Notification.Name(rawValue: GetCardContentUpdates), object: nil, userInfo: ["CardContent" : cardContent])
            })
            weakSelf?.cards.append(card)
            weakSelf?.cards.sort{ $0.createdAt > $1.createdAt }
            weakSelf?.cardFilter.searchCollection?.addCardsToCollection(card: card)
            weakSelf?.cardFilter.searchString = ""
            weakSelf?.cardFilter.filteredCards.sort{ $0.createdAt > $1.createdAt }
            DispatchQueue.main.async {
                weakSelf?.collectionView.reloadData()
            }
        }
        
        self.dash?.observeOnlineMembers({ [weak weakSelf = self] (userStatusArray) -> (Void) in
            guard let uid = AuthProvider.auth().getCurrentUser()?.uid else {
                return
            }
            self.users = userStatusArray
            // Index of current user in array
            let index = self.users.index(where: { (userStatus) -> Bool in
                userStatus.userId == uid
            })
            // Swap current user status to the first index
            if let i = index {
               self.users.swapAt(i, 0)
            }
            // Remove offline users
            self.users = self.users.filter({ $0.connected == true })
            self.userCollectionView.reloadData()
        })
    }

    func handleUserOnlineInterface(_ userOnlineStatus: UserOnlineStatus) {
        let contains = self.users.contains (where: { $0.userId == userOnlineStatus.userId })
        if !contains {
            self.users.append(userOnlineStatus)
        }
        self.users = self.users.filter({ $0.connected == false })
        self.userCollectionView.reloadData()
    }
    
    func prepareInterface() {
        guard let dash = self.dash else {
            return
        }
        // Interpolate header
        self.dashHeader.titleLabel.text = dash.title
        self.dashHeaderView.backgroundColor = .clear
        self.navigationItem.titleView = self.dashHeader
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        self.dashHeader.addGestureRecognizer(tapGesture)
        self.updateHeader(notification: nil)
        self.dropdownViewTouchEvent.addGestureRecognizer(tapGesture2)
        let attr = [
                    "object": UIFont(name: "Gotham-Bold", size: 10)!,
                    "forKey": NSAttributedStringKey.font as NSCopying,
            ]
        self.segmentedControl.setTitleTextAttributes(attr as! [AnyHashable : Any], for: .normal)
        
        // Style Search Bar
        self.searchBar.backgroundImage = UIImage()
        var textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.Palette.greyishWhite
    }

    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTranscript(notification:)), name: UpdateTranscriptKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeader(notification:)), name: UpdateMembersKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCardContents(notification:)), name: UpdateCardContentsKey, object: nil)
    }

    
    @objc func updateTranscript(notification: NSNotification) {
        if let transcript = notification.userInfo!["transcript"] as? Transcript {
            self.transcripts = self.transcripts.map {
                $0.id == transcript.id ? transcript : $0
            }
            self.transcriptFilter.filteredTranscripts = self.transcriptFilter.filteredTranscripts.map {
                $0.id == transcript.id ? transcript : $0
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func updateCardContents(notification: NSNotification) {
        if let card = notification.userInfo!["card"] as? Card {
            self.cards = self.cards.map {
                $0.id == card.id ? card : $0
            }
            self.collectionView.reloadData()
        }
    }
    
    
    @objc func updateHeader(notification: NSNotification?) {
        self.dashHeader.membersLabel.text = "\(DashVC.selectedDash!.members.count + 1) Members"
    }
    
    @objc func toggleDropdown() {
        self.dropdownViewTouchEvent.alpha = self.dropdownViewTouchEvent.alpha == 0.8 ? 0 : 0.8
        UIView.animate(withDuration: Double(0.4), animations: {
            self.dropDownViewBottomConstraint.constant = self.dropDownViewBottomConstraint.constant == -1000 ? 0 : -1000
            self.dropDownViewTopConstraint.constant = self.dropDownViewTopConstraint.constant == -1000 ? 0 : -1000
            self.view.layoutIfNeeded()
        })
    }
    
    func setupViews() {
        // collectionView constraints
        self.viewWrapper.addSubview(self.cardView)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.centerXAnchor.constraint(equalTo: self.viewWrapper.centerXAnchor).isActive = true
        self.cardViewTopConstraint = self.cardView.topAnchor.constraint(equalTo: self.viewWrapper.topAnchor, constant: 12)
        self.cardViewTopConstraint.isActive = true
        self.cardView.bottomAnchor.constraint(equalTo: self.viewWrapper.bottomAnchor).isActive = true
        self.cardView.widthAnchor.constraint(equalTo: self.viewWrapper.widthAnchor, multiplier: 1).isActive = true
        // Push Collection view down
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.cardPlaceholder.isHidden = false

        /** Register Cell **/
        self.collectionView.register(UINib(nibName:"CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        // transcriptView constraints
        self.viewWrapper.addSubview(self.transcriptView)
        self.transcriptView.translatesAutoresizingMaskIntoConstraints = false
        self.transcriptView.centerXAnchor.constraint(equalTo: self.viewWrapper.centerXAnchor).isActive = true
        self.transcriptViewTopConstraint = self.transcriptView.topAnchor.constraint(equalTo: self.viewWrapper.topAnchor, constant: 1000)
        self.transcriptViewTopConstraint.isActive = true
        self.transcriptView.bottomAnchor.constraint(equalTo: self.viewWrapper.bottomAnchor).isActive = true
        self.transcriptView.widthAnchor.constraint(equalTo: self.viewWrapper.widthAnchor, multiplier: 1).isActive = true
        self.transcriptPlaceholder.isHidden = false

        // transcriptView constraints
        self.view.addSubview(self.dropdownView)
        self.dropdownView.translatesAutoresizingMaskIntoConstraints = false
        self.dropdownView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.dropDownViewTopConstraint = self.dropdownView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -1000)
        self.dropDownViewTopConstraint.isActive = true
        self.dropDownViewBottomConstraint = self.dropdownView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1000)
        self.dropDownViewBottomConstraint.isActive = true
        self.dropdownView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        self.dropdownViewTouchEvent.alpha = 0
        
        // Push table view down
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    static func storyboardInstance() -> DashDetailsVC? {
        return UIStoryboard(name: "DashDetails", bundle: nil).instantiateViewController(withIdentifier: "DashCard") as? DashDetailsVC
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.userCollectionView.delegate = self
        self.userCollectionView.dataSource = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.dropdownView.delegate = self
        self.searchBar.delegate = self
        
        // Set scrolling
        self.userCollectionView.alwaysBounceHorizontal = true
        self.collectionView.alwaysBounceVertical = true
        
        self.prepareInterface()
        self.setupViews()
        
        // reset transcript counter
        Transcript.transcriptCount = 0
        
        self.transcriptFilter = SearchFilter(searchCollection:  SearchCollection())
        self.transcriptFilter.searchString = ""
        
        self.cardFilter = SearchFilter(searchCollection:  SearchCollection())
        self.cardFilter.searchString = ""
        
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Set connection status
        self.dash?.onConnect()
        self.createObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Set connection status
        self.dash?.onDisconnect()
        self.dash?.removeObserverOnlineMembers()
    }
}

// MARK: Dropdown
extension DashDetailsVC: DashDropdownDelegate {
    func dashDropdown(didTap: DashDropdown, _ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
        self.toggleDropdown()
    }
}

// MARK: Search
extension DashDetailsVC: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = !searchText.isEmpty // not searching if empty
        if !self.isCardView {
            self.transcriptFilter.searchString = searchText
            self.tableView.reloadData()
        }
        else {
            self.cardFilter.searchString = searchText
            self.collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: Transcripts
extension DashDetailsVC: UITableViewDelegate, UITableViewDataSource, TranscriptCellDelegate, TranscriptDetailCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transcriptFilter.filteredTranscripts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isSearching {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedTranscriptCell", for: indexPath) as? TranscriptCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.prepare(transcript: transcriptFilter.filteredTranscripts[indexPath.row])
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptDetailCell", for: indexPath) as? TranscriptDetailCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.prepare(transcript: transcriptFilter.filteredTranscripts[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func transcriptCell(didTap: TranscriptCell, _ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func transcriptDetailCell(didTap: TranscriptDetailCell, _ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func listen(_ sender: Any) {
        let popupVC = TranscriptVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
}

// MARK: Users & Cards
extension DashDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, CardCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.userCollectionView {
            return self.users.count
        }
        return self.cardFilter.filteredCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.userCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SegementedUserCell", for: indexPath) as? DashUserCollectionCell else {
                return UICollectionViewCell()
            }
            cell.prepare(userOnlineStatus: users[indexPath.row])
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.prepare(card: cardFilter.filteredCards[indexPath.row])
        return cell
    }
    
    func cardCell(didTap: CardCell, _ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func createCard(_ sender: Any) {
        let popupVC = CardEditVC.storyboardInstance()!
        TapticFeedback.feedback.heavy()
        self.present(popupVC, animated: true, completion: nil)
    }
}
