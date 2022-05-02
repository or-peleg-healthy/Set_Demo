//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        cardButtons.append(contentsOf: loadFirstBoard())
        var frame = (40.0, 100.0, 50.0, 50.0)
        for playingCardView in cardButtons {
            let (x, y, width, height) = frame
            playingCardView.frame = CGRect(x: x, y: y, width: width, height: height)
            playingCardView.backgroundColor = UIColor.clear
            view.addSubview(playingCardView)
            frame.0 += 60
            if CGFloat(frame.0) + 60 > view.bounds.maxX {
                frame.0 = 40.0
                frame.1 += 60
            }
        }
    }
    
    private func loadFirstBoard() -> [UIView] {
        game = SetDemo()
        var playingCardViews: [PlayingCardView] = []
        for indexOfCardOnScreen in 0..<12 {
            playingCardViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
        }
        return playingCardViews
    }
    
    var cardButtons: [UIView] = []
    private lazy var game = SetDemo()
    private lazy var gameStarted = false
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deal3MoreButton: UIButton!
    @IBAction private func touchCard(_ sender: UIButton) {
        if gameStarted {
            if let cardNumber = cardButtons.firstIndex(of: sender) {
                let gameEnded = game.cardWasSelected(at: cardNumber)
                if gameEnded {
                    showGameOverAlert()
                }
//                updateViewFromModel()
            }
        }
    }
    
    @IBAction private func deal3More(_ sender: UIButton) {
        if gameStarted {
            game.deal3More()
//            updateViewFromModel()
        }
    }
    @IBAction private func newGame(_ sender: Any) {
        gameStarted = true
        game = SetDemo()
//        updateViewFromModel()
        for button in self.cardButtons {
            button.isHidden = false
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
//                    button.setAttributedTitle(unicodeValue(card: card), for: UIControl.State.normal)
//                    button.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
//                    button.titleLabel?.font = UIFont.systemFont(ofSize: 2)
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
//                        button.setTitle("", for: UIControl.State.normal)
                        game.currentCardsOnScreen[index] = nil
                    }
                }
            } else {
                button.backgroundColor = UIColor.systemGray
//                button.setAttributedTitle(NSAttributedString(""), for: UIControl.State.normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
    private func showGameOverAlert() {
        let gameOverAlert = UIAlertController(title: "Game Over !! \n no more matches can be composed! \n you final score is \(game.score)", message: nil, preferredStyle: .alert)
        gameOverAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            for button in self.cardButtons {
                button.isHidden = true
            }
            self.deal3MoreButton.isEnabled = false
            }
        ))
        self.present(gameOverAlert, animated: true)
    }
}
