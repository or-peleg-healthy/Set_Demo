//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = Set()
    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender){
            game.cardWasSelected(at: cardNumber)
            updateViewFromModel()
        }
    }
    @IBAction func deal3More(_ sender: UIButton) {
        game.Deal3More()
        updateViewFromModel()
    }
    @IBAction func newGame(_ sender: Any) {
        game = Set()
        updateViewFromModel()
    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    private func updateViewFromModel(){
        scoreLabel.text = "Score: \(game.score)"
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if let card = game.currentCardsOnScreen[index]{
                if card.isOnScreen{
                    button.setAttributedTitle(card.unicodeValue(), for: UIControl.State.normal)
                    button.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 2)
                    button.backgroundColor = UIColor.systemMint
                    if card.isSelected{
                        button.layer.borderWidth = 3.0
                        button.layer.borderColor = UIColor.green.cgColor
                    }
                    else {
                        button.layer.borderWidth = 0
                        button.layer.borderColor = UIColor.systemGray.cgColor
                    }
                    if !card.isInGame {
                        button.setTitle("", for: UIControl.State.normal)
                        game.currentCardsOnScreen[index] = nil
                    }
                }
            }
            else{
                button.backgroundColor = UIColor.systemGray
                button.setAttributedTitle(NSAttributedString(""), for: UIControl.State.normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
}
