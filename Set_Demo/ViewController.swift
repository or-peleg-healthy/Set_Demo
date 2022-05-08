//
//  ViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class ViewController: UIViewController {
    var playingCardViews: [PlayingCardView] = []
    var grid = Grid(layout: .aspectRatio(CGFloat(0.7)))
    var justMatched = false
    var selectedCardsToRemove: [Int] = []
    private lazy var game = SetDemo()
    private lazy var gameStarted = true
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deal3MoreButton: UIButton!
    @IBOutlet private weak var boardView: UIView!
    
    override func viewDidLoad() {
        grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.frame)
        grid.cellCount = 12
        super.viewDidLoad()
        playingCardViews = loadFirstBoard()
        updateView()
    }
    
    func updateView() {
        var indexOfCard = 0
        for playingCardView in playingCardViews {
            playingCardView.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
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
    
    private func loadFirstBoard() -> [PlayingCardView] {
        game = SetDemo()
        for indexOfCardOnScreen in 0..<12 {
            let cardView = PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!)
            playingCardViews.append(cardView)
        }
        return playingCardViews
    }
    
    @objc func handleTap(sender: PlayingCardView) {
        if justMatched {
            justMatched = false
            for index in selectedCardsToRemove {
                grid.cellCount -= 1
                playingCardViews[index].removeFromSuperview()
                playingCardViews.remove(at: index)
            }
            for cardView in playingCardViews {
                cardView.removeFromSuperview()
            }
            updateView()
        }
        if let cardNumber = playingCardViews.firstIndex(of: sender) {
            selectedCardsToRemove.removeAll()
            let (isMatch, gameEnded) = game.cardWasSelected(at: cardNumber)
            for index in game.currentSelected {
                selectedCardsToRemove.append(index)
            }
            if isMatch {
                justMatched = true
            }
            updateViewFromModel()
            if gameEnded {
                showGameOverAlert()
            }
        }
    }

    @IBAction private func deal3More(_ sender: UIButton) {
        if gameStarted {
            let newCards = game.deal3More()
            var newViews: [UIView] = []
            for indexOfCardOnScreen in newCards {
                grid.cellCount += 1
                let cardView = PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!)
                cardView.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
                playingCardViews.append(cardView)
                newViews.append(PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!))
            }
            updateView()
        }
    }
    @IBAction private func newGame(_ sender: Any) {
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        playingCardViews.removeAll()
        grid.cellCount = 12
        playingCardViews = loadFirstBoard()
        updateView()
        gameStarted = true
        updateViewFromModel()
        for button in self.playingCardViews {
            button.isHidden = false
        }
        deal3MoreButton.isEnabled = true
        deal3MoreButton.setTitle("Deal 3 More Cards", for: UIControl.State.normal)
    }

    private func updateViewFromModel() {
    scoreLabel.text = "Score: \(game.score)"
    for index in playingCardViews.indices {
        let button = playingCardViews[index]
        if let card = game.currentCardsOnScreen[index] {
                button.layer.cornerRadius = 0
                if card.isSelected {
                    button.layer.borderWidth = 3.0
                    if card.isMatched {
                        button.layer.borderWidth = 10.0
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
            }
        }
    }
    private func showGameOverAlert() {
        let gameOverAlert = UIAlertController(title: "Game Over !! \n no more matches can be composed! \n you final score is \(game.score)", message: nil, preferredStyle: .alert)
        gameOverAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            for button in self.playingCardViews {
                button.isHidden = true
            }
            self.deal3MoreButton.isEnabled = false
            }
        ))
        self.present(gameOverAlert, animated: true)
    }
}
