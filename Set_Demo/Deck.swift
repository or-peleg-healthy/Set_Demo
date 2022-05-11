//
//  Deck.swift
//  Set_Demo
//
//  Created by Or Peleg on 11/05/2022.
//

import Foundation

struct Deck {
    var cards: [Card] = {
        var tempDeck: [Card] = []
        for shape in Shape.allCases {
            for quantity in Quantity.allCases {
                for color in Color.allCases {
                    for shading in Shading.allCases {
                        tempDeck.append(Card(shape: shape, quantity: quantity, color: color, shading: shading))
                    }
                }
            }
        }
        return tempDeck
    }()
    
    subscript(index: Int) -> Card {
        cards[index]
    }
    
    mutating func shuffleDeck() {
        cards.shuffle()
    }
    
    mutating func draw() -> Card {
        cards.removeLast()
    }
    
    func hasAvailableCardsToDraw() -> Bool {
        cards.count >= 3
    }
    
    func count() -> Int {
        cards.count
    }
}
