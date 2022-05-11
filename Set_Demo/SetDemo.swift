//
//  Set.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation
final class SetDemo {
    private(set) var score = 0
    private(set) var currentSelected: [Int] = []
    var currentCardsOnScreen: [Card?] = []
    private var shuffledDeck: [Card] = []
    private(set) var lastCardAdded = 11
    private var deck: [Card] = {
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
    init() {
        shuffledDeck = deck.shuffled()
        for cardIndex in 0..<81 {
            if cardIndex < 12 {
                let cardToAdd = shuffledDeck[cardIndex]
                currentCardsOnScreen.append(cardToAdd)
            } else {
                currentCardsOnScreen.append(nil)
            }
        }
    }
    func deal3More() -> [Int] {
        if lastCardAdded < 80 {
            checkForMatch()
            var freeScreenSpots: [Int] = []
            var isFreeSpace = 0
            var newCards: [Int] = []
            while freeScreenSpots.count < 3 {
                if currentCardsOnScreen[isFreeSpace] == nil {
                    freeScreenSpots.append(isFreeSpace)
                }
                isFreeSpace += 1
            }
            for freeSpace in freeScreenSpots {
                lastCardAdded += 1
                currentCardsOnScreen[freeSpace] = shuffledDeck[lastCardAdded]
                newCards.append(lastCardAdded)
            }
            return freeScreenSpots
        }
        return []
    }
    
    func shuffleScreen() {
        checkForMatch()
        for indexOfCard in currentSelected {
            currentCardsOnScreen[indexOfCard]?.isSelected = false
        }
        currentSelected.removeAll()
        currentCardsOnScreen.shuffle()
    }
    
    func cardWasSelected(at index: Int) -> (Bool, Bool) {
        checkForMatch()
        currentCardsOnScreen = currentCardsOnScreen.filter({ $0 != nil })
        for _ in 0..<81 - currentCardsOnScreen.count {
            currentCardsOnScreen.append(nil)
        }
        for cardIndex in currentSelected {
            currentCardsOnScreen[cardIndex]?.missMatched = false
        }
        if let selectedCard = currentCardsOnScreen[index] {
            if selectedCard.isSelected {
                if currentSelected.count < 3 {
                    selectedCard.isSelected = false
                    currentSelected.remove(at: currentSelected.firstIndex(of: index)!)
                }
                } else {
                    selectedCard.isSelected = true
                    currentSelected.append(index)
                    if currentSelected.count == 3 {
                        if isMatch() {
                        for cardIndex in currentSelected {
                            currentCardsOnScreen[cardIndex]?.isMatched = true
                            }
                        } else {
                            for cardIndex in currentSelected {
                                currentCardsOnScreen[cardIndex]?.missMatched = true
                            }
                        }
                }
            }
        }
        if lastCardAdded > 60 {
            return (isMatch(), didGameEnd())
        } else {
            return (isMatch(), false)
        }
    }
    private func didGameEnd() -> Bool {
        if isMatch(), lastCardAdded > 79 {
            let lastThreeCards = currentCardsOnScreen.filter { $0 != nil }
            if lastThreeCards.count == 3 {
                score += 5
                return true
            }
        }
        let tmpSelectedCards = currentSelected
        currentSelected.removeAll()
        for card1 in currentCardsOnScreen.indices {
            for card2 in currentCardsOnScreen.indices where card2 != card1 {
                for card3 in currentCardsOnScreen.indices where card3 != card2 && card3 != card1 {
                    if currentCardsOnScreen[card1] != nil, currentCardsOnScreen[card2] != nil, currentCardsOnScreen[card3] != nil {
                        currentSelected = [card1, card2, card3]
                    }
                    if isMatch() {
                        currentSelected = tmpSelectedCards
                        return false
                    }
                }
            }
        }
        currentSelected = tmpSelectedCards
        return true
    }
    func isMatch() -> Bool {
        var matcher: [[Int]] = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        for index in currentSelected {
            if let card = currentCardsOnScreen[index] {
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
        if currentSelected.count == 3 {
            if isMatch() {
                score += 5
                for cardIndex in currentSelected {
                    currentCardsOnScreen[cardIndex] = nil
                }
            } else {
                score -= 3
                for cardIndex in currentSelected.indices {
                    currentCardsOnScreen[currentSelected[cardIndex]]?.isSelected = false
                }
            }
            currentSelected.removeAll()
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
