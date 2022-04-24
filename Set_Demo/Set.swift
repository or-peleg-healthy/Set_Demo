//
//  Set.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation
class Set {
    var score = 0
    var currentSelected: [Card] = []
    var shuffledDeck: [Card] = []
    var currentCardsOnScreen: [Card] = []
    var deck: [Card] = {
        var tempDeck: [Card] = []
        for shape in Shape.allCases{
            for quantity in Quantity.allCases{
                for color in Color.allCases{
                    for shading in Shading.allCases{
                        tempDeck.append(Card(shape: shape, quantity: quantity, color: color, shading: shading))
                    }
                }
            }
        }
        return tempDeck
    }()
    init() {
        shuffledDeck = deck.shuffled()
        for cardIndex in 0..<12 {
            var CardToAdd = shuffledDeck[cardIndex]
            currentCardsOnScreen.append(CardToAdd)
            CardToAdd.isOnScreen = true
        }
    }
    func cardWasSelected(at index: Int){
        var selectedCard = shuffledDeck[index]
        if selectedCard.isSelected {
            if currentSelected.count < 2 {
                selectedCard.isSelected = false
                for indexToRemove in 0..<currentSelected.count{
                    if currentSelected[indexToRemove] == selectedCard {
                        currentSelected.remove(at: indexToRemove)
                        return
                    }
                }
            }
        } else {
            currentSelected.append(selectedCard)
            selectedCard.isSelected = true
            if currentSelected.count == 2 {
                if isMatch() {
                    score += 5
                    for cardIndex in currentSelected.indices {
                        var card = currentSelected[cardIndex]
                        card.isMatched = true
                    }
                }
                else {
                    score -= 3
                    for cardIndex in currentSelected.indices {
                        var card = currentSelected[cardIndex]
                        card.isSelected = false
                    }
                }
                currentSelected.removeAll()
            }
        }
    }
    
    func isMatch() -> Bool{
        var Matcher: [[Int]] = [[]]
        for card in currentSelected {
            Matcher[0][card.shape.rawValue] += 1
            Matcher[1][card.quantity.rawValue] += 1
            Matcher[2][card.color.rawValue] += 1
            Matcher[3][card.shading.rawValue] += 1
        }
        for Dimension in Matcher {
            for ValueWithinDimension in Dimension{
                if ValueWithinDimension == 2 {
                    return false
                }
            }
        }
        return true
    }
}

extension Int {
    var arc4random: Int{
        if self > 0 {
        return Int(arc4random_uniform(UInt32(self)))
        }
    }
}
