//
//  Card.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation

enum Shape: Int, CaseIterable{case triangle = 1, circle, square}
enum Quantity: Int, CaseIterable{case one = 1, two, three}
enum Color: Int, CaseIterable{case blue = 1, red, green}
enum Shading: Int, CaseIterable{case striped = 1, solid, open}

struct Card: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashcode)
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.hashcode == rhs.hashcode
    }
    
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    let hashcode = shape * 1 + quantity * 3 + color * 9 + shading * 27
    var isMatched = false
    var isSelected = false
    var isOnScreen = false
    var isInGame = true
}
