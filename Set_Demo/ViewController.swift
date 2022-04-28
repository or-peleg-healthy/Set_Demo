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
    @IBOutlet private var cardButtons: [UIButton]!
    private lazy var gameStarted = false
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
    @IBOutlet private weak var scoreLabel: UILabel!
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if let card = game.currentCardsOnScreen[index] {
                if card.isOnScreen {
                    button.layer.cornerRadius = 0
                    button.setAttributedTitle(card.unicodeValue(decodeWidth: decodeWidth, decodeShading: decodeShading, decodeShapes: decodeShapes, decodeColors: decodeColors), for: UIControl.State.normal)
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
    func showGameOverAlert() {
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
}
extension Card {
    func unicodeValue(decodeWidth: [Int: Double], decodeShading: [Int: CGFloat], decodeShapes: [Int: String], decodeColors: [Int: UIColor]) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeWidth: decodeWidth[shading.rawValue]!,
            .foregroundColor:
                decodeColors[color.rawValue]?.withAlphaComponent(decodeShading[shading.rawValue]!) ?? UIColor.systemBrown]
        let attributedString = NSAttributedString(string: String(repeating: "\(decodeShapes[shape.rawValue] ?? "")", count: quantity.rawValue + 1), attributes: attributes)
        return (attributedString)
    }
}
