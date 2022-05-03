//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        grid = Grid(layout: .fixedCellSize(CGSize(width: 45.0, height: 65.0)), frame: boardView.frame)
        super.viewDidLoad()
        cardButtons.append(contentsOf: loadFirstBoard())
        updateView(with: cardButtons)
    }
    
    func updateView(with newCards: [UIView]) {
        for playingCardView in newCards {
            playingCardView.frame = grid[indexOfCard]!.insetBy(dx: 0.4, dy: 0.4)
            indexOfCard += 1
            playingCardView.backgroundColor = UIColor.clear
            view.addSubview(playingCardView)
            if game.lastCardAdded == 80 {
                deal3MoreButton.isEnabled = false
                deal3MoreButton.setTitle("Deck is Empty", for: UIControl.State.normal)
            }
        }
    }
    
    private func loadFirstBoard() -> [UIView] {
        game = SetDemo()
        for indexOfCardOnScreen in 0..<12 {
            playingCardViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
        }
        return playingCardViews
    }
    
    var playingCardViews: [PlayingCardView] = [] {
        didSet {
            view.layoutSubviews()
        }
    }
    var grid = Grid(layout: .fixedCellSize(CGSize(width: 50.0, height: 50.0)))
    var cardButtons: [UIView] = []
    var indexOfCard = 0
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
            }
        }
    }
    
    @IBOutlet private weak var boardView: UIView!
    @IBAction private func deal3More(_ sender: UIButton) {
        if gameStarted {
            let newCards = game.deal3More()
            var newViews: [UIView] = []
            for indexOfCardOnScreen in newCards {
                playingCardViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
                newViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
            }
            updateView(with: newViews)
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
