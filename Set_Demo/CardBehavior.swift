//
//  cardBehavior.swift
//  Set_Demo
//
//  Created by Or Peleg on 15/05/2022.
//

import UIKit

final class CardBehavior: UIDynamicBehavior {
    let behavior = UIDynamicItemBehavior()
    let colBehavior = UICollisionBehavior()
    
    func addBehaviors() {
        behavior.allowsRotation = true
        behavior.elasticity = 2.0
        behavior.resistance = 1
        colBehavior.translatesReferenceBoundsIntoBoundary = true
    }
    
    func removeBehaviors(cardView: PlayingCardView) {
        behavior.removeItem(cardView)
        colBehavior.removeItem(cardView)
    }
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat(2.arc4random) * CGFloat.pi
        push.magnitude = 1.0
        push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        behavior.addItem(item)
        colBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        behavior.removeItem(item)
        colBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addBehaviors()
        self.addChildBehavior(behavior)
        self.addChildBehavior(colBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
