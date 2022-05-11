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
        var indexOfCard = 0
        for playingCardView in playingCardViews {
            playingCardView.frame = grid[indexOfCard]!.insetBy(dx: 2, dy: 2)
            indexOfCard += 1
            playingCardView.backgroundColor = UIColor.clear
            boardView.addSubview(playingCardView)
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
        }
        ))
        gameOverAlert.addAction(UIAlertAction(title: "Quit", style: .default, handler: { _ in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }
        ))
        self.present(gameOverAlert, animated: true)
    }
    private func noMoreCardsToDealAlert() {
        let noMoreCardsAlert = UIAlertController(title: "The Deck is Empty", message: nil, preferredStyle: .alert)
        noMoreCardsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
        self.present(noMoreCardsAlert, animated: true)
    }
}

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let lastCellCount = grid.cellCount
//        boardView.bounds = CGRect(x: boardView.bounds.maxY, y: boardView.bounds.minX, width: boardView.bounds.width, height: boardView.bounds.height)
//        boardView.frame = CGRect(x: boardView.frame.maxY, y: boardView.frame.minX, width: boardView.frame.width, height: boardView.frame.height)
//        boardView.transform = CGAffineTransform(rotationAngle: .pi / 2)
//        grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.frame)
//        grid.cellCount = lastCellCount
//        for playingCardView in playingCardViews {
//            playingCardView.removeFromSuperview()
//        }
//        updateView()
//        boardView.layoutSubviews()
//        if UIDevice.current.orientation.isLandscape {
//
//
//
//            view.layoutSubviews()
//            view.setNeedsDisplay()
//        } else {
//            grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.bounds)
//            grid.cellCount = lastCellCount
//            for playingCardView in playingCardViews {
//                playingCardView.removeFromSuperview()
//            }
//            updateView()
//
//        }
//    }
