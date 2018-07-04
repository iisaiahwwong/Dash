//
//  MyFilter.swift
//  Dash
//
//  Created by Isaiah Wong on 31/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import Foundation

class SearchFilter {
    let searchCollection: SearchCollection?
    var filteredTranscripts: [Transcript] = []
    var filteredCards: [Card] = []
    var wordSets = [String: Set<String>]()
    var languages = [String: String]()
    
    var searchString = "" {
        didSet {
            if searchString == "" {
                if let transcripts = self.searchCollection?.transcripts {
                    self.filteredTranscripts = transcripts
                    for transcript in transcripts {
                        transcript.extractSearchHelper = [:]
                    }
                }
                if let cards = self.searchCollection?.cards {
                    self.filteredCards = cards
                    for card in cards {
                        card.cardSearchHelper = [:]
                    }
                }
            }
            else{
                extractWordSetsAndLanguages()
                filterEntries()
            }
        }
    }
    
    init(searchCollection: SearchCollection?) {
        self.searchCollection = searchCollection
    }
    
    private func setOfWords(string: String, language: inout String?) -> Set<String> {
        var wordSet = Set<String>()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .language], options: 0)
        let range = NSRange(location: 0, length: string.utf16.count)
        
        tagger.string  = string
        
        if let language = language {
            let orthography = NSOrthography.defaultOrthography(forLanguage: language)
            tagger.setOrthography(orthography, range: range)
        }
        else{
            language = tagger.dominantLanguage
        }
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitWhitespace, .omitPunctuation]){
            tag, tokenRange, _ in
            let token = (string as NSString).substring(with: tokenRange)
            wordSet.insert(token.lowercased())
            
            if let lemma = tag?.rawValue {
                wordSet.insert(lemma.lowercased())
            }
        }
        return wordSet
    }
    
    private func extractWordSetsAndLanguages() {
        var newWordSets = [String: Set<String>]()
        var newLanguages = [String: String]()
        
        if let entries = searchCollection?.entries {
            for entry in entries {
                if let wordSet = wordSets[entry] {
                    newWordSets[entry] = wordSet
                    newLanguages[entry] = languages[entry]
                }
                else {
                    var language: String?
                    let wordSet = setOfWords(string: entry, language: &language)
                    newWordSets[entry] = wordSet
                    newLanguages[entry] = language
                }
            }
        }
        
        wordSets = newWordSets
        languages = newLanguages
    }
    
    private func filterEntries() {
        var language: String?
        var filterSet = setOfWords(string: searchString, language: &language)


        for existingLanguage in Set<String>(languages.values) {
            language = existingLanguage
            filterSet = filterSet.union(setOfWords(string: searchString, language: &language))
        }

        self.filteredTranscripts.removeAll()
        self.filteredCards.removeAll()

        if let transcripts = self.searchCollection?.transcripts {
            if filterSet.isEmpty {
                self.filteredTranscripts.append(contentsOf: transcripts)
                for transcript in transcripts {
                    transcript.extractSearchHelper = [:]
                }
            }
            else {
                for transcript in transcripts {
                    for extract in transcript.extracts {
                        guard let wordSet = wordSets[extract.extractText], !wordSet.intersection(filterSet).isEmpty else { continue }
                        transcript.extractSearchHelper[extract] = true
                        self.filteredTranscripts.append(transcript)
                    }
                }
            }
        }
        if let cards = self.searchCollection?.cards {
            if filterSet.isEmpty {
                self.filteredCards.append(contentsOf: cards)
                for card in cards {
                    card.cardSearchHelper = [:]
                }
            }
            else {
                for card in cards {
                    for cardContent in card.contents {
                        var string: String = ""
                        switch(cardContent.content) {
                        case is String:
                            string = (cardContent.content as! String).stripHTML()
                        case is Intent:
                            string = (cardContent.content as! Intent).fulfillment
                        case is Extract:
                            string = (cardContent.content as! Extract).extractText
                        case is Vote:
                            string = (cardContent.content as! Vote).title
                        default:
                            break
                        }
                        guard let wordSet = wordSets[string], !wordSet.intersection(filterSet).isEmpty else { continue }
                        card.cardSearchHelper[cardContent] = true
                        self.filteredCards.append(card)
                    }
                }
            }
        }
    }
}



