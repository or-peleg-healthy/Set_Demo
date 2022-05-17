//
//  animations.swift
//  Set_Demo
//
//  Created by Or Peleg on 15/05/2022.
//

import UIKit

func fadeOut(cardToFade: UIView) {
    UIView.transition(with: cardToFade,
                      duration: 0.75,
                      options: [],
                      animations: { cardToFade.alpha = 0 })
}

func fadeIn(cardToFade: UIView) {
    UIView.transition(with: cardToFade,
                      duration: 0.75,
                      options: [],
                      animations: { cardToFade.alpha = 1 })
}
