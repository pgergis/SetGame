//
//  ViewController.swift
//  SetGame
//
//  Created by Pierre Gergis on 3/21/20.
//  Copyright © 2020 Pierre Gergis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private enum AttributeType: Int, CaseIterable { case shape, shapeCount, shading, color}
    private var game = SetGame(withCardsHaving: AttributeType.allCases.count)
    
    private enum Shape: Int { case triangle, circle, square }
    private enum Shading: Int { case filled, striped, outline }
    private enum Color: Int { case red, green, purple }
    
    private func getAttributedString(shape:Shape, shapeCount: Int, shading: Shading, color: Color) -> NSAttributedString {
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
            case .outline: {
                attributes.updateValue(colorValue, forKey: .strokeColor)
                attributes.updateValue(5.0, forKey: .strokeWidth)
            }()
            case .striped: attributes.updateValue(colorValue.withAlphaComponent(0.15), forKey: .strokeColor)
        }
        return NSAttributedString(string: shapeString, attributes: attributes)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }


}

