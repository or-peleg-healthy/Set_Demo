//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    private lazy var game = SetDemo()
    @IBOutlet private var cardButtons: [UIButton]!
    private lazy var gameStarted = false
    @IBAction private func touchCard(_ sender: UIButton) {
        if gameStarted {
            if let cardNumber = cardButtons.firstIndex(of: sender) {
                game.cardWasSelected(at: cardNumber)
                updateViewFromModel()
            }
        }
    }
    @IBAction private func deal3More(_ sender: UIButton) {
        if gameStarted {
            game.deal3More()
            updateViewFromModel()
        }
    }
    @IBAction private func newGame(_ sender: Any) {
        gameStarted = true
        game = SetDemo()
        updateViewFromModel()
    }
    @IBOutlet private weak var scoreLabel: UILabel!
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if let card = game.currentCardsOnScreen[index] {
                if card.isOnScreen {
                    button.layer.cornerRadius = 0
                    button.setAttributedTitle(card.unicodeValue(), for: UIControl.State.normal)
                    button.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 2)
                    button.backgroundColor = UIColor.systemMint
                    if card.isSelected {
                        button.layer.borderWidth = 3.0
                        if card.isMatched {
                            button.layer.cornerRadius = 50.0
                        }
                        if card.missMatched {
                            button.layer.borderColor = UIColor.red.cgColor
                        } else {
                        button.layer.borderColor = UIColor.green.cgColor
                        }
                    } else {
                        button.layer.borderWidth = 0
                        button.layer.borderColor = UIColor.systemGray.cgColor
                    }
                    if !card.isInGame {
                        button.setTitle("", for: UIControl.State.normal)
                        game.currentCardsOnScreen[index] = nil
                    }
                }
            } else {
                button.backgroundColor = UIColor.systemGray
                button.setAttributedTitle(NSAttributedString(""), for: UIControl.State.normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
}
