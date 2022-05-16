//
//  ConcentrationViewController.swift
//  Concentration_Demo
//
//  Created by Or Peleg on 13/04/2022.
//

import UIKit

final class ConcentrationViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emojiChoices = theme
        emojiDict = [:]
        updateViewFromModel()
    }
    private lazy var game = ConcentrationDemo(numberOfPairsOfCards: numberOfPairsOfCards)
    private var emojiDict = [EmojiCard: String]()
    var numberOfPairsOfCards: Int {
        (cardButtons.count + 1) / 2
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel(flips: 0)
        }
    }
    var theme: [String] = []
    var emojiChoices: [String] = []

    @IBOutlet private weak var scoreLabel: UILabel!
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction private func newGame(_ sender: UIButton) {
        game = ConcentrationDemo(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
        emojiChoices = theme
        scoreLabel.text = ""
        flipCountLabel.text = "Flips :0"
        for button in cardButtons {
            button.isEnabled = true
        }
        updateViewFromModel()
    }
    
    // MARK: Handle Card Touch Behavior
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            let (wasFaceUp, isGameOver, flips, result) = game.chooseCard(at: cardNumber)
            if !wasFaceUp {
                updateFlipCountLabel(flips: flips)
            }
            if isGameOver {
                scoreLabel.text = "Score :\(result)"
            }
            updateViewFromModel()
        } else {
            print("chosen card is not in card buttons")
        }
    }
        
    func updateFlipCountLabel(flips: Int) {
        flipCountLabel.text = "Flips: \(flips)"
    }
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                if card.isMatched {
                    button.isEnabled = false
                }
            }
        }
        
        func emoji(for card: EmojiCard) -> String {
            if emojiDict[card] == nil {
                if !emojiChoices.isEmpty {
                    emojiDict[card] = emojiChoices.remove(at: emojiChoices.count.arc4random)
                }
            }
            return emojiDict[card] ?? "?"
        }
    }
}
