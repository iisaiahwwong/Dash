//
//  CardAddTranscriptVC.swift
//  Dash
//
//  Created by Isaiah Wong on 30/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class CardAddExisting: UIViewController, UISearchBarDelegate {
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var cards: [Card] = []
    var filteredCards: [Card] = []
    
    var intent: Intent?
    var entity: Entity?
    var extract: Extract?

    // MARK: Methods
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchData() {
        guard let id = DashVC.selectedDash?.id else {
            return
        }
        // Get all Cards
        Card.getAllCards(dashId: id) { [weak weakSelf = self] (card) in
            weakSelf?.cards.append(card)
            weakSelf?.filteredCards.append(card)
            weakSelf?.cards.sort{ $0.createdAt > $1.createdAt }
            weakSelf?.filteredCards.sort{ $0.createdAt > $1.createdAt }
            weakSelf?.collectionView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keywords = searchText.replacingOccurrences(of: " ", with: "")
        filter(keywords)
    }
    
    private func filter(_ keywords: String) {
        if !(cards.count < 1) {
            self.filteredCards = self.cards.filter({ (card) -> Bool in
                return card.title.lowercased().contains(keywords.lowercased())
            })
        }
        if keywords.isEmpty {
            self.filteredCards = cards
        }
        self.collectionView.reloadData()
    }
    
    static func storyboardInstance() -> CardAddExisting? {
        return UIStoryboard(name: "CardOperation", bundle: nil).instantiateViewController(withIdentifier: "CardAddTranscript") as? CardAddExisting
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.searchBar.delegate = self
        /** Register Cell **/
        self.collectionView.register(UINib(nibName:"CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        self.collectionView.alwaysBounceVertical = true
        self.fetchData()
    }
}

extension CardAddExisting: UICollectionViewDelegate, UICollectionViewDataSource, CardCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.prepare(card: filteredCards[indexPath.row])
        return cell
    }
    
    func cardCell(didTap: CardCell, _ viewController: UIViewController) {
        let card = didTap.card
        
        if let intent = self.intent {
            card?.addIntent(intent: intent, completion: { (status) -> (Void) in
                if status {
                    self.dismiss(animated: true, completion: nil )
                }
            })
        }
        else if let extract = self.extract {
            card?.addExtract(extract: extract, completion: { (status) -> (Void) in
                if status {
                    self.dismiss(animated: true, completion: nil )
                }
            })
        }
    }
}
