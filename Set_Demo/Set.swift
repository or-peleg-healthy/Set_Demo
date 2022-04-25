//
//  Set.swift
//  Set_Demo
//
//  Created by Or Peleg on 24/04/2022.
//

import Foundation
class Set {
    var score = 0
    var currentSelected: [Int] = []
    var shuffledDeck: [Card] = []
    var currentCardsOnScreen: [Card?] = []
    var lastCardAdded = 11
    var onScreenMatch: [Int] = []
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
        for cardIndex in 0..<24 {
            if cardIndex < 12 {
                let CardToAdd = shuffledDeck[cardIndex]
                CardToAdd.isOnScreen = true
                currentCardsOnScreen.append(CardToAdd)
            }else{
                currentCardsOnScreen.append(nil)
            }
        }
    }
    func Deal3More() {
        if currentCardsOnScreen.filter({ $0 == nil }).count > 2 && lastCardAdded < 79{
            checkForMatch()
            var FreeScreenSpots: [Int] = []
            var isFreeSpace = 0
            while FreeScreenSpots.count < 3 {
                if currentCardsOnScreen[isFreeSpace] == nil{
                    FreeScreenSpots.append(isFreeSpace)
                }
                isFreeSpace += 1
            }
            for FreeSpace in FreeScreenSpots {
                lastCardAdded += 1
                currentCardsOnScreen[FreeSpace] = shuffledDeck[lastCardAdded]
                shuffledDeck[lastCardAdded].isOnScreen = true
            }
        }
    }
    func cardWasSelected(at index: Int){
        checkForMatch()
        if let selectedCard = currentCardsOnScreen[index]{
            if selectedCard.isMatched {
                return
            } else {
                if !onScreenMatch.isEmpty{
                    for indexOfCardPartOfMatch in onScreenMatch.indices{
                        if let cardToHandle = currentCardsOnScreen[indexOfCardPartOfMatch]{
                            cardToHandle.isInGame = false
                        }
                    }
                    onScreenMatch.removeAll()
                }
            }
            if selectedCard.isSelected {
                if currentSelected.count < 2 {
                    selectedCard.isSelected = false
                    for indexToRemove in currentSelected.indices{
                        if currentCardsOnScreen[currentSelected[indexToRemove]] == selectedCard {
                            currentSelected.remove(at: indexToRemove)
                            return
                        }
                    }
                }
            } else {
                selectedCard.isSelected = true
                currentSelected.append(index)
                print(currentSelected)
            }
        }
    }
    
    func isMatch() -> Bool{
        var Matcher: [[Int]] = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]
        for index in currentSelected {
            if let card = currentCardsOnScreen[index]{
                Matcher[0][card.shape.rawValue] += 1
                Matcher[1][card.quantity.rawValue] += 1
                Matcher[2][card.color.rawValue] += 1
                Matcher[3][card.shading.rawValue] += 1
            }
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
    func checkForMatch() {
        if currentSelected.count == 3 {
            if isMatch() {
                score += 5
                for cardIndex in currentSelected.indices {
                    currentCardsOnScreen[cardIndex]?.isMatched = true
                }
            }
            else {
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
    var arc4random: Int{
        if self > 0 {
        return Int(arc4random_uniform(UInt32(self)))
        }
        return 0
    }
}
