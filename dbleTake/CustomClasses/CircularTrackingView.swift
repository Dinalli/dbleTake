//
//  CircularTrackingView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 12/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

@IBDesignable class CircularTrackingView: UIView {

    @IBInspectable var percent: Int = 0
    @IBInspectable var numberToShow: Int = 0
    @IBInspectable var backColor: UIColor!
    @IBInspectable var foreColor: UIColor!
    @IBInspectable var counterColor: UIColor!
    @IBInspectable var radius: CGFloat = 0
    @IBInspectable var lineWidth: CGFloat = 0
    var font = UIFont.systemFont(ofSize: 17)

    var startAngle: Double!
    var endAngle: Double!
    var circleLayer: CAShapeLayer!

    /// override init to allow calling of configure when button is created.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    /// override init to allow calling of configure when button is created.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.backgroundColor = UIColor.clear
        startAngle = Double.pi * 1.5
        endAngle = startAngle + (Double.pi * 2)
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
        let textContent = "\(self.numberToShow)"
        let arcCenter =  CGPoint(x: (rect.size.width / 2), y: (rect.size.height / 2) + 4.5)
        let bezierEndAngle =  (endAngle - startAngle) * (100.0 / 100.0) + startAngle
        let shadowBezierPath = UIBezierPath(arcCenter: arcCenter, radius: self.radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(bezierEndAngle), clockwise: true)
        shadowBezierPath.lineWidth = self.lineWidth
        UIColor.black .setStroke()
        shadowBezierPath .stroke(with: .normal, alpha: 0.3)

        let bezierArcCenter =  CGPoint(x: (rect.size.width / 2), y: (rect.size.height / 2))
        let bezierPath = UIBezierPath(arcCenter: bezierArcCenter, radius: self.radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(bezierEndAngle), clockwise: true)
        bezierPath.lineWidth = self.lineWidth
        self.backColor .setStroke()
        bezierPath .stroke()

        // Text Drawing
        let yOffset: CGFloat = (rect.size.height - font.pointSize) / 2
        let textRect = CGRect(x: 0, y: yOffset-5, width: rect.size.width, height: font.pointSize)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingTail
        let textFontAttributes = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.foregroundColor: self.counterColor!
        ] as [NSAttributedString.Key : Any]
        textContent.draw(in: textRect, withAttributes: textFontAttributes)
    }

    func drawOverlayCircle() {
        let circle = CAShapeLayer()

        let bezierArcCenter =  CGPoint(x: (self.frame.size.width / 2), y: (self.frame.size.height / 2))
        var bezierEndAngle =  (endAngle - startAngle) * Double(self.percent) / 100.0
        bezierEndAngle += startAngle
        let bezierPath = UIBezierPath(arcCenter: bezierArcCenter, radius: self.radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(bezierEndAngle), clockwise: true)

        circle.path = bezierPath.cgPath

        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = self.foreColor.cgColor
        circle.lineWidth = self.lineWidth
        self.layer.addSublayer(circle)

        let springAnimation = CASpringAnimation(keyPath: "strokeEnd")
        springAnimation.stiffness = 1500
        springAnimation.damping = 25
        springAnimation.mass = 3
        springAnimation.fromValue = 0
        springAnimation.toValue = 1
        springAnimation.duration = 1.5
        circle.add(springAnimation, forKey: "spring")
    }
}




