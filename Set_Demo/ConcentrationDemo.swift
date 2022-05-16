//
//  ConcentrationDemo.swift
//  ConcentrationDemo
//
//  Created by Or Peleg on 13/04/2022.
//

import UIKit

struct ConcentrationDemo {
    private(set) var cards = [EmojiCard]()
    private var matches = 0
    private var flips = 0
    private var score = 0
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    private let numberOfPairs: Int?
    private var isGameOver = false
    
    // swiftlint:disable large_tuple
    mutating func chooseCard(at index: Int) -> (WasFaceUp: Bool, isGameOver: Bool, Flips: Int, Score: Int) {
        assert(cards.indices.contains(index), "Concecntration_Demo.chooseCard(at: \(index)) : choosen index not in the cards")
        var wasAlreadyFacedup = false
        if cards[index].isFaceUp == true {
            wasAlreadyFacedup = true
        } else {
            flips += 1
        }
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    matches += 1
                    score += 2
                    if matches == numberOfPairs {
                        isGameOver = true
                    }
                } else {
                    if cards[matchIndex].wasFlippedBefore {
                        score -= 1
                    }
                    if cards[index].wasFlippedBefore {
                        score -= 1
                    }
                    cards[index].wasFlippedBefore = true
                    cards[matchIndex].wasFlippedBefore = true
                }
                cards[index].isFaceUp = true
            } else {
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
        return (wasAlreadyFacedup, isGameOver, flips, score)
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concecntration_Demo.init(\(numberOfPairsOfCards)) : must have at least one pair of cards")
        self.numberOfPairs = numberOfPairsOfCards
        for _ in 1...numberOfPairsOfCards {
            let card = EmojiCard()
            cards += [card, card]
        }
        cards.shuffle()
    }
}

extension Collection {
    var oneAndOnly: Element? {
        count == 1 ? first : nil
    }
}
