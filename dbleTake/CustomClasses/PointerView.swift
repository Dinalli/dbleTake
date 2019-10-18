//
//  PointerView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 15/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit
import QuartzCore

class PointerView: UIView {

    var fillColor: UIColor = UIColor.white
    var lineColor: UIColor = UIColor.white
    var radius: CGFloat = 6.0
    var sideOffset: CGFloat = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .redraw
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .redraw
    }

    override public func draw(_ rect: CGRect) {
        backgroundColor = .green
        let center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let alpha = self.radius * 3 / sqrt(3)
        let pointA: CGPoint?
        let pointB: CGPoint?
        let pointC: CGPoint?
        pointA = CGPoint(x: center.x - 1 / 2 * alpha, y: self.sideOffset)
        pointB = CGPoint(x: center.x + 1 / 2 * alpha, y: self.sideOffset)
        pointC = CGPoint(x: center.x, y: self.bounds.height - self.sideOffset)
        if let ctx = UIGraphicsGetCurrentContext(), let a = pointA, let b = pointB, let c = pointC {
            ctx.beginPath()
            ctx.move(to: c)
            ctx.addLine(to: b)
            ctx.addLine(to: a)
            ctx.addLine(to: c)
            ctx.setFillColor(self.fillColor.cgColor)
            ctx.setStrokeColor(self.lineColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.drawPath(using: .fillStroke)
        }
    }
}
