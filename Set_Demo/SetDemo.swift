//
//  Set.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation
final class SetDemo {
    private(set) var score = 0
    private(set) var currentSelectedCards: [Int] = []
    private(set) var currentMatchedCards: [Int] = []
    private(set) var currentMissMatchedCards: [Int] = []
    private(set) var board: [Card?] = []
    private var deck = Deck()

    init() {
        deck.shuffle()
        for cardIndex in 0..<81 {
            if cardIndex < 12 {
                board.append(deck.draw())
            } else {
                board.append(nil)
            }
        }
    }
    
    func deal3More() -> [Int] {
        if deck.hasAvailableCardsToDraw() {
            checkForMatch()
            var freeScreenSpots: [Int] = []
            var isFreeSpace = 0
            while freeScreenSpots.count < 3 {
                if board[isFreeSpace] == nil {
                    freeScreenSpots.append(isFreeSpace)
                }
                isFreeSpace += 1
            }
            for freeSpace in freeScreenSpots {
                board[freeSpace] = deck.draw()
            }
            return freeScreenSpots
        }
        return []
    }
    
    func shuffleScreen() {
        checkForMatch()
        currentSelectedCards.removeAll()
        board.shuffle()
    }
    
    func cardWasSelected(at index: Int) -> (Bool, Bool) {
        currentMatchedCards.removeAll()
        currentMissMatchedCards.removeAll()
        checkForMatch()
        board = board.filter({ $0 != nil })
        for _ in 0..<81 - board.count {
            board.append(nil)
        }
        if board[index] != nil {
            if currentSelectedCards.contains(index) {
                if currentSelectedCards.count < 3 {
                    currentSelectedCards.remove(at: currentSelectedCards.firstIndex(of: index)!)
                }
            } else {
                currentSelectedCards.append(index)
                if currentSelectedCards.count == 3 {
                    if selectedCardsMatch() {
                        for cardIndex in currentSelectedCards {
                            currentMatchedCards.append(cardIndex)
                            }
                        } else {
                            for cardIndex in currentSelectedCards {
                                currentMissMatchedCards.append(cardIndex)
                        }
                    }
                }
            }
        }
        if deck.count() > 60 {
            return (selectedCardsMatch(), didGameEnd())
        } else {
            return (selectedCardsMatch(), false)
        }
    }
    private func didGameEnd() -> Bool {
        if selectedCardsMatch(), !deck.hasAvailableCardsToDraw() {
            let lastThreeCards = board.filter { $0 != nil }
            if lastThreeCards.count == 3 {
                score += 5
                return true
            }
        }
        let tmpSelectedCards = currentSelectedCards
        currentSelectedCards.removeAll()
        for card1 in board.indices {
            for card2 in board.indices where card2 != card1 {
                for card3 in board.indices where card3 != card2 && card3 != card1 {
                    if board[card1] != nil, board[card2] != nil, board[card3] != nil {
                        currentSelectedCards = [card1, card2, card3]
                    }
                    if selectedCardsMatch() {
                        currentSelectedCards = tmpSelectedCards
                        return false
                    }
                }
            }
        }
        currentSelectedCards = tmpSelectedCards
        return true
    }
    func selectedCardsMatch() -> Bool {
        var matcher: [[Int]] = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        for index in currentSelectedCards {
            if let card = board[index] {
                matcher[0][card.shape.rawValue] += 1
                matcher[1][card.quantity.rawValue] += 1
                matcher[2][card.color.rawValue] += 1
                matcher[3][card.shading.rawValue] += 1
            }
        }
        for dimension in matcher {
            if dimension.reduce(0, +) != 3 {
                return false
            }
            for valueWithinDimension in dimension where valueWithinDimension == 2 {
                return false
            }
        }
        return true
    }
    private func checkForMatch() {
        if currentSelectedCards.count == 3 {
            if selectedCardsMatch() {
                score += 5
                for cardIndex in currentSelectedCards {
                    board[cardIndex] = nil
                }
            } else {
                score -= 3
                }
            currentSelectedCards.removeAll()
        }
    }
}
extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int.random(in: 0...self)
        }
        return 0
    }
}
