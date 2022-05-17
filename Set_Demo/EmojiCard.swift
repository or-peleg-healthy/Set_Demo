//
//  EmojiCard.swift
//  Concentration_Demo
//
//  Created by Or Peleg on 13/04/2022.
//

import Foundation

struct EmojiCard: Hashable {
    // doesn't require the displayed emoji.
    // the emoji only involves the view.
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: EmojiCard, rhs: EmojiCard) -> Bool {
            lhs.identifier == rhs.identifier
    }

    var isFaceUp = false
    var isMatched = false
    var wasFlippedBefore = false
    private var identifier: Int
    
    private static var identifierFactory = 0
    
    private static func uniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = EmojiCard.uniqueIdentifier()
    }
}
