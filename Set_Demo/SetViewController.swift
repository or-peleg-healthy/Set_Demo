//
//  SetViewController.swift
//  Set_Demo
//
//  Created by Or Peleg on 20/04/2022.
//

import UIKit

final class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    /* Outlets */
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var boardView: UIView!
    @IBOutlet private weak var matchedPile: UIView!
    @IBOutlet private weak var deckPlaceHolder: UIView!
    private let topDeckCard = PlayingCardView()
    private let topMatchedPileCard = PlayingCardView()
    
    /* Model */
    private lazy var game = SetDemo()
    private var playingCardViews: [PlayingCardView] = []
    private var grid = Grid(layout: .aspectRatio(CGFloat(0.7)))
    
    /* View Handlers */
    private var justMatched = false
    private var selectedCardsToRemove: [Int] = []
    private var currentMatchedCards: [PlayingCardView] = []
    private var match = false
    private var cellCount = Constant.initialCellCount { didSet {
        grid.cellCount = cellCount
    }}
    
    /* Animation Handlers */
    var finishedAnimating = false
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)
   
    /* Class Functions */
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffle(sender:)))
        let tapOnDeck = UITapGestureRecognizer(target: self, action: #selector(deal3More(sender:)))
        self.view.addGestureRecognizer(rotationGesture)
        self.deckPlaceHolder.addGestureRecognizer(tapOnDeck)
        loadFirstBoard()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grid = Grid(layout: .aspectRatio(CGFloat(Constant.cardAspectRatio)), frame: boardView.bounds)
        grid.cellCount = cellCount
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func loadFirstBoard() {
        game = SetDemo()
        embedPlaceHolders()
        cellCount = Constant.initialCellCount
        scoreLabel.text = "Score: \(game.score)"
        for indexOfCardOnScreen in 0..<12 {
            let cardView = PlayingCardView(card: (game.board[indexOfCardOnScreen])!)
            let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            cardView.addGestureRecognizer(tapOnCard)
            playingCardViews.append(cardView)
        }
    }
    
    func embedPlaceHolders() {
        topDeckCard.frame = deckPlaceHolder.frame
        deckPlaceHolder.addSubview(topDeckCard)
        deckPlaceHolder.setNeedsLayout()
        topDeckCard.alpha = 1
        topMatchedPileCard.frame = matchedPile.frame
        topMatchedPileCard.alpha = 0
        topMatchedPileCard.backgroundColor = UIColor.clear
        topDeckCard.backgroundColor = UIColor.clear
        matchedPile.addSubview(topMatchedPileCard)
        matchedPile.setNeedsLayout()
    }
    
    func updateView() {
        var index = 0
        finishedAnimating = false
        if justMatched {
            playingCardViews.removeAll()
            for card in game.board {
                playingCardViews.append(PlayingCardView(card: card!))
            }
        }
        for playingCardIndex in index..<playingCardViews.count where playingCardViews[playingCardIndex].alpha == 1 {
            let playingCardView = self.playingCardViews[playingCardIndex]
            UIView.transition(with: playingCardView,
                              duration: Constant.rearrangeBoardDuration,
                              options: [.curveEaseIn],
                              animations: {
                playingCardView.frame = self.grid[playingCardIndex]!.insetBy(dx: 2, dy: 2)
                self.boardView.addSubview(playingCardView)
            }, completion: { _ in })
            index += 1
        }
        if index < playingCardViews.count {
            callNextAnimator(indexOfCard: index)
        } else {
            self.finishedAnimating = true
        }
    }
    
    func callNextAnimator(indexOfCard: Int) {
        let playingCardView = playingCardViews[indexOfCard]
        if playingCardView.alpha == 0 {
            playingCardView.frame = self.deckPlaceHolder.convert(self.deckPlaceHolder.frame, to: self.view)
            fadeIn(cardToFade: playingCardView)
            fadeOut(cardToFade: deckPlaceHolder, alpha: 0.3)
            fadeIn(cardToFade: deckPlaceHolder)
            UIView.transition(with: playingCardView,
                              duration: Constant.durationOfCardDealing,
                              options: [.curveEaseIn],
                              animations: {
                    playingCardView.frame = self.grid[indexOfCard]!.insetBy(dx: Constant.spaceBetweenCardViews, dy: Constant.spaceBetweenCardViews)
                    self.boardView.addSubview(playingCardView)},
                             completion: {_ in
                UIView.transition(with: playingCardView,
                                  duration: Constant.flipCardDuration,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                    playingCardView.faceUp = true
                    playingCardView.setNeedsDisplay()
                    self.finishedAnimating = true},
                                  completion: { _ in if indexOfCard + 1 < self.playingCardViews.count {
                                      self.callNextAnimator(indexOfCard: indexOfCard + 1) }})})}
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if justMatched {
            justMatched = false
            var dec = 0
            for index in selectedCardsToRemove.sorted() {
                cellCount -= 1
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
        if justMatched {
            justMatched = false
            var dec = 0
            for index in selectedCardsToRemove.sorted() {
                cellCount -= 1
                playingCardViews[index + dec].removeFromSuperview()
                playingCardViews.remove(at: index + dec)
                dec -= 1
            }
            for cardView in playingCardViews {
                cardView.removeFromSuperview()
            }
            selectedCardsToRemove.removeAll()
            updateView()
        }
        if !finishedAnimating {
            return
        }
        let newCards = game.deal3More()
        if newCards.isEmpty {
            noMoreCardsToDealAlert()
        } else {
            for indexOfCardOnScreen in newCards {
                cellCount += 1
                let cardView = PlayingCardView(card: (game.board[indexOfCardOnScreen])!)
                let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                cardView.addGestureRecognizer(tapOnCard)
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
                let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                cardView.addGestureRecognizer(tapOnCard)
                playingCardViews.append(cardView)
            }
        }
        updateView()
        updateViewFromModel()
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if match {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1,
                                                           delay: 0,
                                                           options: [],
                                                           animations: { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1,
                                                                                                                        delay: 0,
                                                                                                                        options: [.curveLinear],
                                                                                                                        animations: { self.currentMatchedCards.forEach {
                $0.transform = (CGAffineTransform.identity)
                $0.frame = self.matchedPile.convert(self.matchedPile.frame, to: self.boardView)
            }}, completion: { _ in self.currentMatchedCards.forEach { UIView.transition(with: $0,
                                                                                        duration: 1,
                                                                                        options:
                                                                                            [.curveLinear],
                                                                                        animations: { fadeIn(cardToFade: self.topMatchedPileCard) },
                                                                                        completion: {_ in
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.transitionFlipFromLeft], animations: {
                        self.currentMatchedCards.forEach {
                            self.cardBehavior.removeItem($0)
                            $0.faceUp = false
                            $0.setNeedsDisplay()
                            $0.layer.borderColor = UIColor.clear.cgColor
                        }})})}})}, completion: { _ in self.deal3More(sender: UIView()) })
        }
    }
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.score)"
        for indexOfCard in playingCardViews.indices {
            let cardView = playingCardViews[indexOfCard]
            if game.currentSelectedCards.contains(indexOfCard) {
                cardView.layer.borderColor = UIColor.green.cgColor
                if game.currentMatchedCards.contains(indexOfCard) {
                    self.match = true
                    currentMatchedCards.append(cardView)
                    self.cardBehavior.addItem(cardView)
                } else if game.currentMissMatchedCards.contains(indexOfCard) {
                    cardView.layer.borderColor = UIColor.red.cgColor
                }
            } else {
                cardView.layer.borderWidth = 1
                cardView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    @IBAction private func newGame(_ sender: Any) {
        for playingCardView in playingCardViews {
            playingCardView.removeFromSuperview()
        }
        selectedCardsToRemove.removeAll()
        playingCardViews.removeAll()
        loadFirstBoard()
        updateView()
        updateViewFromModel()
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
