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
        deal3MoreButton.isEnabled = false
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(deal3More(sender:)))
        swipeDown.direction = .down
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffle(sender:)))
        self.view.addGestureRecognizer(rotationGesture)
        self.view.addGestureRecognizer(swipeDown)
        grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.frame)
        grid.cellCount = 12
        super.viewDidLoad()
        playingCardViews = loadFirstBoard()
        updateView()
    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let lastCellCount = grid.cellCount
//        if UIDevice.current.orientation.isLandscape {
//            grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: CGRect(x: boardView.frame.maxX, y: boardView.frame.minY, width: boardView.frame.height, height: boardView.frame.width))
//            grid.cellCount = lastCellCount
//            for playingCardView in playingCardViews {
//                playingCardView.removeFromSuperview()
//            }
//            view.layoutSubviews()
//            view.setNeedsDisplay()
//            updateView()
//        } else {
//            grid = Grid(layout: .aspectRatio(CGFloat(0.7)), frame: boardView.frame)
//            grid.cellCount = lastCellCount
//            for playingCardView in playingCardViews {
//                playingCardView.removeFromSuperview()
//            }
//            updateView()
//            view.layoutSubviews()
//        }
//    }
    
    private func loadFirstBoard() -> [PlayingCardView] {
        game = SetDemo()
        for indexOfCardOnScreen in 0..<12 {
            let cardView = PlayingCardView(card: (game.currentCardsOnScreen[indexOfCardOnScreen])!)
            playingCardViews.append(cardView)
        }
        return playingCardViews
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
    
    @objc func handleTap(sender: PlayingCardView) {
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
        if let cardNumber = playingCardViews.firstIndex(of: sender) {
            selectedCardsToRemove.removeAll()
            let (isMatch, gameEnded) = game.cardWasSelected(at: cardNumber)
            print(cardNumber)
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
    
    @objc func deal3More(sender: UIView) {
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
    
    @objc func shuffle(sender: UIView) {
        if game.isMatch() {
            return
        }
        game.shuffleScreen()
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        playingCardViews.removeAll()
        for cardOnScreen in game.currentCardsOnScreen {
            if let card = cardOnScreen {
                let cardView = PlayingCardView(card: card)
                playingCardViews.append(cardView)
            }
        }
        updateView()
        updateViewFromModel()
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
        deal3MoreButton.isEnabled = false
        deal3MoreButton.setTitle("More Cards to Deal", for: UIControl.State.normal)
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
