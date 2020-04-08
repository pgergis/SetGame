//
//  ViewController.swift
//  SetGame
//
//  Created by Pierre Gergis on 3/21/20.
//  Copyright © 2020 Pierre Gergis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet weak private var dealNextButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var setsFoundLabel: UILabel!
    
    private var game = SetGame(numCardAttributes: AttributeType.allCases.count)
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    private var setsFound = 0 {
        didSet {
            setsFoundLabel.text = "\(setsFound)"
        }
    }
    
    private var dealtCards = [Card?]() {
        didSet {
            dealNextButton.setTitle("Deal 🥞\(game.deck.count)", for: .normal)
            if game.deck.count == 0
                || dealtCards.filter({ $0 == nil }).count == 0 {
                dealNextButton.isEnabled = false
            } else {
                dealNextButton.isEnabled = true
            }
            displayDealtCards()
        }
    }
    
    private var selected: [Int] {
        get {
            return cardButtons.indices.filter { cardButtons[$0].isSelected }
        }
    }
    
    private enum AttributeType: Int, CaseIterable { case shape, shapeCount, shading, color}
    
    private enum Shape: Int { case triangle, circle, square }
    private enum Shading: Int { case filled, striped, outline }
    private enum Color: Int { case red, green, purple }
    
    private func getDisplayAttributes(from card: Card) -> (Shape, ShapeCount: Int, Shading, Color) {
        assert(card.attributes.count >= AttributeType.allCases.count)
        
        let attrs = AttributeType.allCases.map { card.attributes[$0.rawValue].rawValue}
        
        return (
            Shape(rawValue: attrs[0])!,
            attrs[1] + 1,
            Shading(rawValue: attrs[2])!,
            Color(rawValue: attrs[3])!
        )
    }
    
    private func getAttributedString(for card: Card) -> NSAttributedString {
        let (shape, shapeCount, shading, color) = getDisplayAttributes(from: card)
        
        func getShapeString() -> String {
            switch shape {
                case .triangle: return "▲"
                case .circle: return "●"
                case .square: return "■"
            }
        }
        func getTextColor() -> UIColor {
            switch color {
                case .green: return UIColor.systemGreen
                case .purple: return UIColor.systemPurple
                case .red: return UIColor.systemRed
            }
        }
        
        let shapeString = String(repeating: getShapeString(), count: shapeCount)
        let colorValue: UIColor = getTextColor()

        var attributes = [NSAttributedString.Key:Any]()
        switch shading {
            case .filled:
                attributes.updateValue(colorValue, forKey: .foregroundColor)

            case .outline:
                attributes.updateValue(colorValue, forKey: .strokeColor)
                attributes.updateValue(10.0, forKey: .strokeWidth)

            case .striped:
                attributes.updateValue(colorValue.withAlphaComponent(0.3), forKey: .foregroundColor)                
        }
        return NSAttributedString(string: shapeString, attributes: attributes)
    }
    
    private func setFace(cardButton: UIButton, up: Bool) {
        if up {
            cardButton.isEnabled = true
            cardButton.backgroundColor = UIColor.secondarySystemFill
        } else {
            cardButton.isEnabled = false
            cardButton.isSelected = false
            cardButton.backgroundColor = UIColor.systemBackground
        }
    }
    
    private func displaySelectionState(cardButton: UIButton) {
        if cardButton.isSelected {
            cardButton.layer.borderWidth = 3.0
            cardButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            cardButton.layer.borderWidth = 0
            cardButton.layer.borderColor = cardButton.backgroundColor?.cgColor ?? UIColor.systemBackground.cgColor
        }
    }
    
    private func displayDealtCards() {
        assert(dealtCards.count == cardButtons.count)
        for i in dealtCards.indices {
            let cardButton = cardButtons[i]
            if let card = dealtCards[i] {
                let cardString = getAttributedString(for: card)
                cardButton.setAttributedTitle(cardString, for: .normal)
                setFace(cardButton: cardButton, up: true)
            } else {
                setFace(cardButton: cardButton, up: false)
            }
            displaySelectionState(cardButton: cardButton)
        }
    }
    
    private func dealNewCards(n: Int) {
        let newCards = game.dealCards(n: n)
        for (newCard, slot) in zip(newCards, dealtCards.indices.filter( { dealtCards[$0] == nil })) {
            dealtCards[slot] = newCard
        }
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if selected.count == 3 {
            let selectedCards = selected.map { dealtCards[$0]! }
            let foundSet = game.isSet(cards: selectedCards)
            setsFound += foundSet ? 1 : 0
            score += foundSet ? 3 : -2
            for i in selected {
                dealtCards[i] = foundSet ? nil : dealtCards[i]
                cardButtons[i].isSelected = false
            }
        }
        
        displayDealtCards()
    }
    
    private func setInDealt() -> Bool {
        return dealtCards
            .filter({ $0 != nil })  // on the board
            .map({ $0! })
            .combinations
            .filter({ $0.count == 3 })  // grouped in threes
            .filter({ game.isSet(cards: $0) })  // valid set
            .count > 0
    }
    
    @IBAction private func dealThree(n: Int) {
        score += setInDealt() ? -1 : 0
        dealNewCards(n: 3)
    }
    
    @IBAction private func initializeNewGame() {
        game = SetGame(numCardAttributes: AttributeType.allCases.count)
        dealtCards = Array(repeating: nil, count: cardButtons.count)
        score = 0
        setsFound = 0
        for button in cardButtons {
            button.layer.cornerRadius = 8.0
            button.setAttributedTitle(NSAttributedString(string: " "), for: .disabled)
            button.titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            setFace(cardButton: button, up: false)
        }
        dealNewCards(n: 12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNewGame()
    }
}

