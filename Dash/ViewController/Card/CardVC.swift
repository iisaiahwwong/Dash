//
//  CardVC.swift
//  Dash
//
//  Created by Isaiah Wong on 2/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class CardVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var cards: [Card] = []
    
    var isSearching: Bool = false
    
    var cardFilter: SearchFilter = SearchFilter(searchCollection: nil)
    
    func fetchData() {
        Card.getAllCards { (card) in
            // Create Observers for each card
            card.getUpdatesForCardContents({ (cardContent) -> (Void) in
                // Post Notification
                NotificationCenter.default.post(name: Notification.Name(rawValue: GetCardContentUpdates), object: nil, userInfo: ["CardContent" : cardContent])
            })
            self.cards.append(card)
            self.cards.sort{ $0.createdAt > $1.createdAt }
            self.cardFilter.searchCollection?.addCardsToCollection(card: card)
            self.cardFilter.searchString = ""
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cardFilter = SearchFilter(searchCollection:  SearchCollection())
        self.cardFilter.searchString = ""
        
        self.collectionView.register(UINib(nibName:"CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        self.searchBar.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Style Search Bar
        self.searchBar.backgroundImage = UIImage()
        var textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.Palette.greyishWhite
        
        fetchData()
    }
}

extension CardVC: UICollectionViewDelegate, UICollectionViewDataSource, CardCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.cardFilter.filteredCards.count)
        return self.cardFilter.filteredCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}

// MARK: Search
extension CardVC: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = !searchText.isEmpty // not searching if empty
        self.cardFilter.searchString = searchText
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

