//
//  cardBehavior.swift
//  Set_Demo
//
//  Created by Or Peleg on 15/05/2022.
//

import UIKit

final class CardBehavior: UIDynamicBehavior {
    let itemBehavior = UIDynamicItemBehavior()
    let colBehavior = UICollisionBehavior()
    
    func addBehaviors() {
        itemBehavior.allowsRotation = true
        itemBehavior.elasticity = 1.0
        itemBehavior.resistance = 1.0
        colBehavior.translatesReferenceBoundsIntoBoundary = true
        colBehavior.collisionMode = .everything
    }
    
    func removeBehaviors(cardView: PlayingCardView) {
        itemBehavior.removeItem(cardView)
        colBehavior.removeItem(cardView)
    }
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat(5.arc4random) * CGFloat.pi
        push.magnitude = 10.0
        push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        itemBehavior.addItem(item)
        colBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        itemBehavior.removeItem(item)
        colBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addBehaviors()
        self.addChildBehavior(itemBehavior)
        self.addChildBehavior(colBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
