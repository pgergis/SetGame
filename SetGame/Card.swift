//
//  Card.swift
//  SetGame
//
//  Created by Pierre Gergis on 3/21/20.
//  Copyright © 2020 Pierre Gergis. All rights reserved.
//

import Foundation

// each card attribute has 3 possible values
enum Attribute: Int, CaseIterable {
    case first, second, third
}

struct Card: Equatable {
    let id = UUID()
    let attributes: [Attribute]
}
