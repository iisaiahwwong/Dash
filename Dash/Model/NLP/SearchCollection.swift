//
//  SearchCollection.swift
//  Dash
//
//  Created by Isaiah Wong on 31/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import Foundation

class SearchCollection {

    var entries: [String] = []
    var transcripts: [Transcript] = []
    var cards: [Card] = []
    
    func addTranscriptToCollection(transcript: Transcript) {
        self.transcripts.append(transcript)
        for extract in transcript.extracts {
            self.entries.append(extract.extractText)
        }
    }
    
    func addCardsToCollection(card: Card) {
        self.cards.append(card)
        for cardContent in card.contents {
            switch(cardContent.content) {
            case is String:
                self.entries.append((cardContent.content as! String).stripHTML())
            case is Intent:
                self.entries.append((cardContent.content as! Intent).fulfillment)
            case is Extract:
                self.entries.append((cardContent.content as! Extract).extractText)
            case is Vote:
                self.entries.append((cardContent.content as! Vote).title)
            default:
                break
            }
        }
    }
}
