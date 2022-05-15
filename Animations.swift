//
//  animations.swift
//  Set_Demo
//
//  Created by Or Peleg on 15/05/2022.
//

import UIKit

func fadeOut(cardToFade: UIView, alpha: Double) {
    UIView.transition(with: cardToFade,
                      duration: 0.75,
                      options: [],
                      animations: { cardToFade.alpha = alpha })
}

func fadeIn(cardToFade: UIView) {
    UIView.transition(with: cardToFade,
                      duration: 0.75,
                      options: [],
                      animations: { cardToFade.alpha = 1 })
}

func connect2Animators(firstAnimator: UIViewPropertyAnimator, secondAnimator: UIViewPropertyAnimator) -> UIViewPropertyAnimator {
    firstAnimator.addCompletion { _ in
            secondAnimator.startAnimation()
        }
    return secondAnimator
}
