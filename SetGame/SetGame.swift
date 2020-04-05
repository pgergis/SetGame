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
    
    init(numCardAttributes: Int) {
        let attributeVariations = Set(Array(repeating: Attribute.allCases, count: numCardAttributes)
            .reduce([], +).combinations.filter { $0.count == numCardAttributes })
        
        deck = attributeVariations.map { Card(attributes: $0) }.shuffled()
        assert(deck.count == 81)
    }

    mutating func dealCards(n: Int) -> [Card] {
        return deck.popFirst(n)
    }
    
    private func validSetForAttribute(at index: Int, for cards: [Card]) -> Bool {
        let firstAttribute = cards.first!.attributes[index]
        let allTheSame = { () -> Bool in cards.allSatisfy( { $0.attributes[index] == firstAttribute }) }
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
    }
    
    func isSet(cards: [Card]) -> Bool {
        let allSameNumAttributes = { () -> Bool in cards.allSatisfy({ $0.attributes.count == cards.first!.attributes.count }) }
        let validSetForAllAttributes = { () -> Bool in cards.first!.attributes.indices.allSatisfy({ self.validSetForAttribute(at: $0, for: cards) }) }
        return cards.first == nil || (allSameNumAttributes() && validSetForAllAttributes())
    }
}

extension Collection {
    var combinations: [[Element]] {
        guard !isEmpty else { return [[]] }
        return Array(suffix(from: index(startIndex, offsetBy: 1))).combinations.flatMap { [$0, [first!] + $0] }
    }
}

extension Array {
    mutating func popFirst(_ k: Int) -> [Element] {
        var popped = [Element]()
        for _ in 0..<(Swift.min(k, self.count)) {
            popped.append(self.removeFirst())
        }
        return popped
    }
}

