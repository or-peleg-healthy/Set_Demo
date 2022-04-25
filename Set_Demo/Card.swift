//
//  Card.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation

enum Shape: Int, CaseIterable{case triangle = 0, circle, square}
enum Quantity: Int, CaseIterable{case one = 0, two, three}
enum Color: Int, CaseIterable{case blue = 0, red, green}
enum Shading: Int, CaseIterable{case striped = 0, solid, open}

struct Card: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.identifier == rhs.identifier
    }
    
    func description() -> String {
        return ("\(shape), \(quantity), \(color), \(shading)")
    }
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    let identifier: Int
    var isMatched = false
    var isSelected = false
    var isOnScreen = false
    var isInGame = true
}
