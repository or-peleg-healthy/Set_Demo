//
//  Set.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation
final class SetDemo {
    var score = 0
    var currentSelected: [Int] = []
    var shuffledDeck: [Card] = []
    var currentCardsOnScreen: [Card?] = []
    var lastCardAdded = 11
    var onScreenMatch: [Int] = []
    var deck: [Card] = {
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
        for cardIndex in 0..<24 {
            if cardIndex < 12 {
                let cardToAdd = shuffledDeck[cardIndex]
                cardToAdd.isOnScreen = true
                currentCardsOnScreen.append(cardToAdd)
            } else {
                currentCardsOnScreen.append(nil)
            }
        }
    }
    func deal3More(afterMatch: Bool) {
        if currentCardsOnScreen.filter({ $0 == nil }).count > 2 && lastCardAdded < 79 {
            if !afterMatch {
                checkForMatch()
            }
            var freeScreenSpots: [Int] = []
            var isFreeSpace = 0
            while freeScreenSpots.count < 3 {
                if currentCardsOnScreen[isFreeSpace] == nil {
                    freeScreenSpots.append(isFreeSpace)
                }
                isFreeSpace += 1
            }
            for freeSpace in freeScreenSpots {
                lastCardAdded += 1
                currentCardsOnScreen[freeSpace] = shuffledDeck[lastCardAdded]
                shuffledDeck[lastCardAdded].isOnScreen = true
            }
        }
    }
    func cardWasSelected(at index: Int) {
        checkForMatch()
        if let selectedCard = currentCardsOnScreen[index] {
            if selectedCard.isSelected {
                if currentSelected.count < 3 {
                    selectedCard.isSelected = false
                    currentSelected.remove(at: currentSelected.firstIndex(of: index)!)
                            return
                        }
                    } else {
                        selectedCard.isSelected = true
                        currentSelected.append(index)
                        print(currentSelected)
            }
        }
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
            for valueWithinDimension in dimension where valueWithinDimension == 2 {
                return false
            }
        }
        return true
    }
    func checkForMatch() {
        if currentSelected.count == 3 {
            if isMatch() {
                score += 5
                for cardIndex in currentSelected {
                    currentCardsOnScreen[cardIndex] = nil
                }
                deal3More(afterMatch: true)
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
