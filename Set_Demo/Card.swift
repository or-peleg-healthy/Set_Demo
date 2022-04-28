//
//  Card.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import UIKit

enum Shape: Int, CaseIterable { case triangle = 0, circle, square }
enum Quantity: Int, CaseIterable { case one = 0, two, three }
enum Color: Int, CaseIterable { case purple = 0, red, orange }
enum Shading: Int, CaseIterable { case striped = 0, solid, open }

final class Card: Hashable {
    init(shape: Shape, quantity: Quantity, color: Color, shading: Shading) {
        self.shape = shape
        self.quantity = quantity
        self.color = color
        self.shading = shading
        self.identifier = shape.rawValue * 1 + quantity.rawValue * 3 + color.rawValue * 9 + shading.rawValue * 27
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Card, rhs: Card) -> Bool {
            lhs.identifier == rhs.identifier
    }
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    private let identifier: Int
    var isSelected = false
    var isOnScreen = false
    var isMatched = false
    var missMatched = false
    var isInGame = true
}
