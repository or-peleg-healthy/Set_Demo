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
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var boardView: UIView!
    @IBOutlet private weak var matchedPile: UIView!
    @IBOutlet private weak var deckPlaceHolder: UIView!
    let topDeckCard = PlayingCardView()
    let topMatchedPileCard = PlayingCardView()
    var finishedAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.orientation.isLandscape {
            boardView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffle(sender:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(deal3More(sender:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(rotationGesture)
        self.view.addGestureRecognizer(swipeDown)
        playingCardViews = loadFirstBoard()
        updateView()
    }
    
    private func loadFirstBoard() -> [PlayingCardView] {
        game = SetDemo()
        topDeckCard.frame = deckPlaceHolder.frame
        deckPlaceHolder.addSubview(topDeckCard)
        deckPlaceHolder.setNeedsLayout()
        topDeckCard.alpha = 1
        topMatchedPileCard.frame = matchedPile.frame
        topMatchedPileCard.alpha = 0
        matchedPile.addSubview(topMatchedPileCard)
        matchedPile.setNeedsLayout()
        scoreLabel.text = "Score: \(game.score)"
        grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.bounds)
        grid.cellCount = 12
        for indexOfCardOnScreen in 0..<12 {
            let cardView = PlayingCardView(card: (game.board[indexOfCardOnScreen])!)
            cardView.layer.borderWidth = 1.5
            cardView.layer.borderColor = UIColor.clear.cgColor
            cardView.layer.cornerRadius = 1
            let swipeDown = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            cardView.addGestureRecognizer(swipeDown)
            playingCardViews.append(cardView)
        }
        return playingCardViews
    }
    
    func updateView() {
        callNextAnimator(indexOfCard: 0)
    }
    
    func callNextAnimator(indexOfCard: Int) {
        let playingCardView = self.playingCardViews[indexOfCard]
        playingCardView.backgroundColor = UIColor.clear
        finishedAnimating = false
        if playingCardView.alpha == 0 {
            playingCardView.frame = CGRect(origin: CGPoint(x: 50, y: 700), size: CGSize(width: 100, height: 100))
            fadeIn(cardToFade: playingCardView)
            fadeOut(cardToFade: deckPlaceHolder, alpha: 0.2)
            fadeIn(cardToFade: deckPlaceHolder)
            UIView.transition(with: playingCardView,
                              duration: 0.3,
                              options: [.curveEaseIn],
                              animations: {
                playingCardView.frame = self.grid[indexOfCard]!.insetBy(dx: 2, dy: 2)
                self.boardView.addSubview(playingCardView)},
                                             completion: {_ in
                UIView.transition(with: playingCardView,
                                  duration: 0.3,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                playingCardView.faceUp = true
                playingCardView.setNeedsDisplay()
                self.finishedAnimating = true
                }, completion: { _ in if indexOfCard + 1 < self.playingCardViews.count {
                    self.callNextAnimator(indexOfCard: indexOfCard + 1) }})})
        } else {
            UIView.transition(with: playingCardView,
                              duration: 0.10,
                              options: [.curveEaseIn],
                              animations: {
                playingCardView.frame = self.grid[indexOfCard]!.insetBy(dx: 2, dy: 2)
                self.boardView.addSubview(playingCardView)},
                              completion: { _ in if indexOfCard + 1 < self.playingCardViews.count {
                self.callNextAnimator(indexOfCard: indexOfCard + 1) }})
        }
    }
    
    @IBAction private func newGame(_ sender: Any) {
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        selectedCardsToRemove.removeAll()
        playingCardViews.removeAll()
        playingCardViews = loadFirstBoard()
        updateView()
        updateViewFromModel()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if justMatched {
            justMatched = false
            var dec = 0
            for index in selectedCardsToRemove.sorted() {
                grid.cellCount -= 1
                playingCardViews[index + dec].removeFromSuperview()
                playingCardViews.remove(at: index + dec)
                dec -= 1
            }
            for cardView in playingCardViews {
                cardView.removeFromSuperview()
            }
            updateView()
        }
        let playingCardView = sender.view as? PlayingCardView
        if let cardNumber = playingCardViews.firstIndex(of: playingCardView!) {
            selectedCardsToRemove.removeAll()
            let (selectedCardsMatch, gameEnded) = game.cardWasSelected(at: cardNumber)
            for index in game.currentSelectedCards {
                selectedCardsToRemove.append(index)
            }
            if selectedCardsMatch {
                justMatched = true
            }
            updateViewFromModel()
            if gameEnded {
                showGameOverAlert()
            }
        }
    }
    
    @objc func deal3More(sender: UIView) {
        if !finishedAnimating {
            return
        }
        let newCards = game.deal3More()
        if newCards.isEmpty {
            noMoreCardsToDealAlert()
        } else {
            for indexOfCardOnScreen in newCards {
                grid.cellCount += 1
                let cardView = PlayingCardView(card: (game.board[indexOfCardOnScreen])!)
                cardView.layer.borderWidth = 1.5
                cardView.layer.borderColor = UIColor.clear.cgColor
                cardView.layer.cornerRadius = 1
                let swipeDown = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                cardView.addGestureRecognizer(swipeDown)
                playingCardViews.append(cardView)
                if game.deck.cards.isEmpty {
                    fadeOut(cardToFade: topDeckCard, alpha: 0)
                }
            }
            updateView()
        }
    }
    
    @objc func shuffle(sender: UIView) {
        if game.selectedCardsMatch() {
            return
        }
        game.shuffleScreen()
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        playingCardViews.removeAll()
        for cardOnScreen in game.board {
            if let card = cardOnScreen {
                let cardView = PlayingCardView(card: card)
                let swipeDown = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                cardView.addGestureRecognizer(swipeDown)
                playingCardViews.append(cardView)
            }
        }
        updateView()
        updateViewFromModel()
    }

    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        for indexOfCard in playingCardViews.indices {
            let cardView = playingCardViews[indexOfCard]
            if game.currentSelectedCards.contains(indexOfCard) {
                cardView.layer.borderColor = UIColor.green.cgColor
                if game.currentMatchedCards.contains(indexOfCard) {
                    fadeOut(cardToFade: cardView, alpha: 0)
                    fadeOut(cardToFade: topMatchedPileCard, alpha: 0)
                    fadeIn(cardToFade: topMatchedPileCard)
                    cardView.layer.borderWidth = 10.0
                } else if game.currentMissMatchedCards.contains(indexOfCard) {
                    cardView.layer.borderColor = UIColor.red.cgColor
                }
            } else {
                cardView.layer.borderWidth = 1
                cardView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    private func showGameOverAlert() {
        let gameOverAlert = UIAlertController(title: "Game Over !! \n no more matches can be composed! \n you final score is \(game.score)", message: nil, preferredStyle: .alert)
        gameOverAlert.addAction(UIAlertAction(title: "New Game", style: .default, handler: { [self] _ in
            newGame((Any).self)
        }))
        gameOverAlert.addAction(UIAlertAction(title: "Quit", style: .default, handler: { _ in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        self.present(gameOverAlert, animated: true)
    }
    
    private func noMoreCardsToDealAlert() {
        let noMoreCardsAlert = UIAlertController(title: "The Deck is Empty", message: nil, preferredStyle: .alert)
        noMoreCardsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
        self.present(noMoreCardsAlert, animated: true)
    }
}
