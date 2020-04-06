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
    @IBOutlet weak var dealNextLabel: UIButton!
    
    private var game = SetGame(numCardAttributes: AttributeType.allCases.count)
    
    private var dealtCards = [Card?]() {
        didSet {
            dealNextLabel.setTitle("Deal 3 (\(game.deck.count))", for: .normal)
            if game.deck.count == 0  || dealtCards.allSatisfy( { $0 != nil }){
                dealNextLabel.isEnabled = false
            }
            displayDealtCards()
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
            case .filled: attributes.updateValue(colorValue.withAlphaComponent(1.0), forKey: .strokeColor)
                attributes.updateValue(-1.0, forKey: .strokeWidth)
            case .outline: {
                attributes.updateValue(colorValue, forKey: .strokeColor)
                attributes.updateValue(5.0, forKey: .strokeWidth)
            }()
            case .striped: attributes.updateValue(colorValue.withAlphaComponent(0.15), forKey: .foregroundColor)
        }
        return NSAttributedString(string: shapeString, attributes: attributes)
    }
    
    private func displayDealtCards() {
        for (cardButton, optCard) in zip(cardButtons, dealtCards) {
            if let card = optCard {
                let cardString = getAttributedString(for: card)
                cardButton.setAttributedTitle(cardString, for: .normal)
                cardButton.isEnabled = true
            } else {
                cardButton.isEnabled = false
            }
        }
    }
    
    private func dealNewCards(n: Int) {
        let newCards = game.dealCards(n: n)
        for (newCard, slot) in zip(newCards, dealtCards.indices.filter( { dealtCards[$0] == nil })) {
            dealtCards[slot] = newCard
        }
    }
    
    private func checkForSet() {
        print("Checking for set...")
        let selected = zip(cardButtons, dealtCards).filter({$0.0.isSelected && $0.1 != nil})
        if selected.count == 3 {
            if game.isSet(cards: selected.map { $0.1! }) {
                print("Found a set!")
            }
        }
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.layer.borderWidth = 3.0
            sender.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            sender.layer.borderWidth = 0
        }
        
        checkForSet()
    }
    
    @IBAction func dealThree(n: Int) {
        dealNewCards(n: 3)
    }
    
    private func initializeNewGame() {
        dealtCards = Array(repeating: nil, count: cardButtons.count)
        for button in cardButtons {
            button.setTitle(" ", for: .disabled)
            button.titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            button.isEnabled = false
            button.isSelected = false
        }
        dealNewCards(n: 12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNewGame()
    }
}

