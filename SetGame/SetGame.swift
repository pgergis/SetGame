//
//  SetGame.swift
//  SetGame
//
//  Created by Pierre Gergis on 3/21/20.
//  Copyright © 2020 Pierre Gergis. All rights reserved.
//

import Foundation

struct SetGame {
    private(set) var deck: [Card]
    
    init(withCardsHaving numAttributes: Int) {
        let attributeVariations = Set(Array(repeating: Attribute.allCases, count: numAttributes)
            .reduce([], +).combinations.filter { $0.count == numAttributes })
        
        deck = attributeVariations.map { Card(attributes: $0) }.shuffled()
        assert(deck.count == 81)
    }

    mutating func dealCards(n: Int) {
        return deck.removeSubrange(0..<n)
    }
    
    private func validSetForAttribute(at index: Int, for cards: [Card]) -> Bool {
        // invalid if attribute isn't in all the cards
        if cards.reduce(false, { $0 || $1.attributes.count <= index }) {
            return false
        }
        if let firstCard = cards.first {
            let firstAttribute = firstCard.attributes[index]
            let allTheSame = { () -> Bool in
                cards.reduce(true, { $0 && $1.attributes[index] == firstAttribute })
            }
            let allDifferent = { () -> Bool in
                var prevAttribute = firstAttribute
                for card in cards {
                    if card.attributes[index] == prevAttribute {
                        return false
                    }
                    prevAttribute = card.attributes[index]
                }
                return true
            }
            
            return allTheSame() || allDifferent()
        } else {
            return true
        }
    }
    
    func isSet(cards: [Card]) -> Bool {
        // invalid if cards don't have the same number of attributes
        if cards.reduce(true, { $0 && cards[0].attributes.count == $1.attributes.count }) {
            return false
        }
        // for each attribute index, all cards should either all match or all not match
        return cards[0].attributes.indices.reduce(true, { $0 && validSetForAttribute(at: $1, for: cards) })
    }
}

extension Collection {
    var combinations: [[Element]] {
        guard !isEmpty else { return [[]] }
        return Array(suffix(from: index(startIndex, offsetBy: 1))).combinations.flatMap { [$0, [first!] + $0] }
    }
}

