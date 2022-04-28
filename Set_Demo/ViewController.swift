//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    private(set) var decodeShapes: [Int: String] = [0: "▲", 1: "●", 2: "■"]
    private(set) var decodeColors: [Int: UIColor] = [0: UIColor.green, 1: UIColor.black, 2: UIColor.systemIndigo]
    private(set) var decodeShading: [Int: CGFloat] = [0: CGFloat(0.30), 1: CGFloat(1), 2: CGFloat(1)]
    private(set) var decodeWidth: [Int: Double] = [0: 0, 1: 0, 2: 10.0]
    private lazy var game = SetDemo()
    private lazy var gameStarted = false
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deal3MoreButton: UIButton!
    @IBAction private func touchCard(_ sender: UIButton) {
        if gameStarted {
            if let cardNumber = cardButtons.firstIndex(of: sender) {
                let gameEnded = game.cardWasSelected(at: cardNumber)
                if gameEnded {
                    showGameOverAlert()
                }
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
        for button in self.cardButtons {
            button.isEnabled = true
        }
        deal3MoreButton.isEnabled = true
    }
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        if game.lastCardAdded == 80 {
            deal3MoreButton.isEnabled = false
            deal3MoreButton.setTitle("Deck is Empty", for: UIControl.State.normal)
        } else {
            if game.currentCardsOnScreen.contains(nil) {
                deal3MoreButton.isEnabled = true
                deal3MoreButton.setTitle("Deal 3 More Cards", for: UIControl.State.normal)
            } else {
                if game.currentSelected.isEmpty || !game.currentCardsOnScreen[game.currentSelected[0]]!.isMatched {
                    deal3MoreButton.isEnabled = false
                    deal3MoreButton.setTitle("Board is Full", for: UIControl.State.normal)
                } else {
                    deal3MoreButton.isEnabled = true
                    deal3MoreButton.setTitle("Deal 3 More Cards", for: UIControl.State.normal)
                }
            }
        }
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if let card = game.currentCardsOnScreen[index] {
                if card.isOnScreen {
                    button.layer.cornerRadius = 0
                    button.setAttributedTitle(unicodeValue(card: card), for: UIControl.State.normal)
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
    private func showGameOverAlert() {
        let gameOverAlert = UIAlertController(title: "Game Over !! \n no more matches can be composed! \n you final score is \(game.score)", message: nil, preferredStyle: .alert)
        gameOverAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            for button in self.cardButtons {
                button.isEnabled = false
            }
            self.deal3MoreButton.isEnabled = false
            }
        ))
        self.present(gameOverAlert, animated: true)
    }
    private func unicodeValue(card: Card) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeWidth: decodeWidth[card.shading.rawValue]!,
            .foregroundColor:
                decodeColors[card.color.rawValue]?.withAlphaComponent(decodeShading[card.shading.rawValue]!) ?? UIColor.systemBrown]
        let attributedString = NSAttributedString(string: String(repeating: "\(decodeShapes[card.shape.rawValue] ?? "")", count: card.quantity.rawValue + 1), attributes: attributes)
        return (attributedString)
    }
}
