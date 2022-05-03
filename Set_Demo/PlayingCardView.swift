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
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 10.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        let grid = Grid(layout: .dimensions(rowCount: card.quantity.rawValue + 1, columnCount: 1), frame: roundedRect.bounds.insetBy(dx: 4, dy: 4))
        let color = decodeColors[card.color.rawValue]
        for indexToAdd in 0...card.quantity.rawValue {
            var drawingOnCard = UIBezierPath()
            switch card.shape {
            case .squiggle:
                drawingOnCard = createSquiggle(grid[indexToAdd]!.insetBy(dx: 3, dy: 3))
            case .diamond:
                drawingOnCard = createDiamond(grid[indexToAdd]!.insetBy(dx: 3, dy: 3))
            case .oval:
                drawingOnCard = createOval(grid[indexToAdd]!.insetBy(dx: 3, dy: 3))
            }
            switch card.shading {
            case .open:
                color?.setStroke()
                drawingOnCard.stroke()
            case .solid:
                color?.setFill()
                drawingOnCard.fill()
            case .striped:
                drawingOnCard = addStripes(shape: drawingOnCard, color: color!)
            }
            drawingOnCard.lineWidth = 3.0
        }
    }
    
    func createSquiggle(_ bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let (minX, midX, maxX, minY, midY, maxY) = (bounds.minX, bounds.midX, bounds.maxX, bounds.minY, bounds.midY, bounds.maxY)
        let startPoint = CGPoint(x: minX, y: (maxY + midY) / 2)
        let points = [
        (CGPoint(x: minX, y: (minY + midY) / 2), CGPoint(x: minX, y: (minY + midY) / 2)),
        (CGPoint(x: midX, y: (minY + midY) / 2), CGPoint(x: (minX + midX) / 2, y: midY)),
        (CGPoint(x: maxX, y: (minY + midY) / 2), CGPoint(x: (midX + maxX) / 2, y: minY)),
        (CGPoint(x: maxX, y: (midY + maxY) / 2), CGPoint(x: maxX, y: (midY + maxY) / 2)),
        (CGPoint(x: midX, y: (midY + maxY) / 2), CGPoint(x: (midX + maxX) / 2, y: midY)),
        (CGPoint(x: minX, y: (midY + maxY) / 2), CGPoint(x: (minX + midX) / 2, y: maxY)),
        (CGPoint(x: bounds.minX, y: bounds.midY), CGPoint(x: bounds.minX, y: bounds.midY))
        ]
        path.move(to: startPoint)
        path.addLine(to: points[0].0)
        path.addQuadCurve(to: points[1].0, controlPoint: points[1].1)
        path.addQuadCurve(to: points[2].0, controlPoint: points[2].1)
        path.addLine(to: points[3].0)
        path.addQuadCurve(to: points[4].0, controlPoint: points[4].1)
        path.addQuadCurve(to: points[5].0, controlPoint: points[5].1)
        path.close()
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
        }
        path.close()
        return path
    }
    
    func createOval(_ bounds: CGRect) -> UIBezierPath {
        UIBezierPath(ovalIn: bounds)
    }
    
    func addStripes(shape: UIBezierPath, color: UIColor) -> UIBezierPath {
        let bounds = shape.bounds
        let stripes = UIBezierPath()
        for x in stride(from: 0, to: bounds.size.width, by: 10) {
            stripes.move(to: CGPoint(x: bounds.origin.x + x, y: bounds.origin.y ))
            stripes.addLine(to: CGPoint(x: bounds.origin.x + x, y: bounds.origin.y + bounds.size.height ))
        }
        stripes.lineWidth = 4
        shape.addClip()
        color.setStroke()
        stripes.stroke()
        shape.stroke()
        return shape
    }
    
    private(set) var decodeColors: [Int: UIColor] = [0: UIColor.systemOrange, 1: UIColor.systemGreen, 2: UIColor.systemBlue]
}
