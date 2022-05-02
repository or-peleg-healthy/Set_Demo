//
//  PlayingCardView.swift
//  Set_Demo
//
//  Created by Or Peleg on 02/05/2022.
//

import UIKit
@IBDesignable final class PlayingCardView: UIView {
    var card: Card
    
    required init(card: Card) {
        self.card = card
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        nil
        // fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.systemOrange.setFill()
        roundedRect.fill()
        for _ in 0..<card.quantity.rawValue {
            var drawingOnCard = UIBezierPath()
            switch card.shape {
            case .squiggle:
                drawingOnCard = createSquiggle(rect)
            case .diamond:
                drawingOnCard = createDiamond(rect)
            case .oval:
                drawingOnCard = createOval(rect)
            }
            decodeColors[card.color.rawValue]?.setStroke()
            drawingOnCard.lineWidth = 3.0
            drawingOnCard.stroke()
        }
    }
    
    func createSquiggle(_ bounds: CGRect) -> UIBezierPath {
        // Based on: https://stackoverflow.com/questions/25387940/how-to-draw-a-perfect-squiggle-in-set-card-game-with-objective-c
        let startPoint = CGPoint(x: bounds.minX, y: bounds.midY)
        // Draw the squiggle
        let path = UIBezierPath()
        path.move(to: startPoint)
//        var point = CGPoint(x: startPoint.x , y: startPoint.y)
//        path.addCurve(to: <#T##CGPoint#>, controlPoint1: <#T##CGPoint#>, controlPoint2: <#T##CGPoint#>)(to: point)
//        path.move(to: point)
//        var point = CGPoint(x: startPoint.x , y: startPoint.y)
        
        path.close()
        // Your code to scale, rotate and translate the squiggle
        return path
    }
    
    func createDiamond(_ bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let startPoint = CGPoint(x: bounds.minX, y: bounds.midY)
        let points = [
                    CGPoint(x: bounds.midX, y: bounds.minY),
                    CGPoint(x: bounds.maxX, y: bounds.midY),
                    CGPoint(x: bounds.midX, y: bounds.maxY),
                    CGPoint(x: bounds.minX, y: bounds.midY)]
        path.move(to: startPoint)
        for point in points {
            path.addLine(to: point)
            path.move(to: point)
        }
        path.close()
        return path
    }
    
    func createOval(_ bounds: CGRect) -> UIBezierPath {
        UIBezierPath(ovalIn: bounds)
    }
    private(set) var decodeColors: [Int: UIColor] = [0: UIColor.green, 1: UIColor.black, 2: UIColor.systemIndigo]
    private(set) var decodeShading: [Int: CGFloat] = [0: CGFloat(0.30), 1: CGFloat(1), 2: CGFloat(1)]
    private(set) var decodeWidth: [Int: Double] = [0: 0, 1: 0, 2: 10.0]
}
