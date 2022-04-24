//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = Set()
    private var buttonsToCardDict: [Int:Int] = [:]
    var placeOnBoard = 0
    updateDict(forFirstTime: true)
    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender){
            game.cardWasSelected(at: cardNumber)
            updateViewFromModel()
        }
    }
    
    private func updateViewFromModel(){
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.shuffledDeck[index]
        }
    }
    private func updateDict(forFirstTime:Bool) {
        if forFirstTime{
            for cardIndex in game.currentCardsOnScreen.indices {
                buttonsToCardDict[placeOnBoard] = game.currentCardsOnScreen[cardIndex].identifier
                placeOnBoard += 1
            }
        }
    }
}
