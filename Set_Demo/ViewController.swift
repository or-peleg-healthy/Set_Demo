//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.frame)
        grid.cellCount = 12
        super.viewDidLoad()
        cardButtons = loadFirstBoard()
        updateView()
    }
    
    func updateView() {
        var indexOfCard = 0
        for playingCardView in playingCardViews {
            playingCardView.frame = grid[indexOfCard]!.insetBy(dx: 2, dy: 2)
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
    
    var playingCardViews: [PlayingCardView] = []
    var grid = Grid(layout: .aspectRatio(CGFloat(0.7)))
    var cardButtons: [UIView] = []
    private lazy var game = SetDemo()
    private lazy var gameStarted = true
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
                grid.cellCount += 1
                playingCardViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
                newViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
            }
            updateView()
        }
    }
    @IBAction private func newGame(_ sender: Any) {
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        grid.cellCount = 12
        playingCardViews = []
        cardButtons = loadFirstBoard()
        updateView()
        gameStarted = true
        for button in self.cardButtons {
            button.isHidden = false
        }
        deal3MoreButton.isEnabled = true
        deal3MoreButton.setTitle("Deal 3 More Cards", for: UIControl.State.normal)
    }
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
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
