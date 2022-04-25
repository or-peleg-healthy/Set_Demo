//
//  Card.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import UIKit

enum Shape: Int, CaseIterable { case triangle = 0, circle, square }
enum Quantity: Int, CaseIterable { case one = 0, two, three }
enum Color: Int, CaseIterable { case blue = 0, red, green }
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
    func unicodeValue() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeWidth: decodeWidth[shading.rawValue]!,
            .foregroundColor:
                decodeColors[color.rawValue]?.withAlphaComponent(decodeShading[shading.rawValue]!) ?? UIColor.systemBrown]
        let attributedString = NSAttributedString(string: String(repeating: "\(decodeShapes[shape.rawValue] ?? "")", count: quantity.rawValue + 1), attributes: attributes)
        return (attributedString)
    }
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    let identifier: Int
    var isSelected = false
    var isOnScreen = false
    var isInGame = true
    let decodeShapes: [Int: String] = [0: "▲", 1: "●", 2: "■"]
    let decodeColors: [Int: UIColor] = [0: UIColor.blue, 1: UIColor.red, 2: UIColor.green]
    let decodeShading: [Int: CGFloat] = [0: CGFloat(0.10), 1: CGFloat(1), 2: CGFloat(1)]
    let decodeWidth: [Int: Double] = [0: 0, 1: 0, 2: 10.0]
}
