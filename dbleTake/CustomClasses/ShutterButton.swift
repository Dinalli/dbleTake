//
//  ShutterButton.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 13/09/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

/// Class extension of UIButton styled like the camera shutter button.
@IBDesignable class ShutterButton: UIButton {

    /// Path for the inner circle shape
    let innerCirclePathLayer = CAShapeLayer()
    /// Paht for the outter circle shape
    let outterCirclePathLayer = CAShapeLayer()
    /// default innercircle radius
    var innerCircleRadius: CGFloat = 23.0
    /// default outter circle radius
    var outterCircleRadius: CGFloat = 25.0

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

    /// Configure the inner and outter circles ready to be drawn
    func configure() {
        innerCirclePathLayer.frame = bounds
        innerCirclePathLayer.lineWidth = 2
        innerCirclePathLayer.fillColor = UIColor.cyan.cgColor
        innerCirclePathLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(innerCirclePathLayer)

        outterCirclePathLayer.frame = bounds
        outterCirclePathLayer.lineWidth = 2
        outterCirclePathLayer.fillColor = UIColor.clear.cgColor
        outterCirclePathLayer.strokeColor = UIColor.cyan.cgColor
        layer.addSublayer(outterCirclePathLayer)
        backgroundColor = .clear
    }

    /// Create the Rect for the inner circle frame
    func innerCircleFrame() -> CGRect {
        innerCircleRadius = self.frame.width * 0.45
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * innerCircleRadius, height: 2 * innerCircleRadius)
        let circlePathBounds = innerCirclePathLayer.bounds
        circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
        return circleFrame
    }

    /// Create the Rect for the outter circle frame
    func outterCircleFrame() -> CGRect {
        outterCircleRadius = self.frame.width / 2
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * outterCircleRadius, height: 2 * outterCircleRadius)
        let circlePathBounds = outterCirclePathLayer.bounds
        circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
        return circleFrame
    }

    /// return the bezier path for the inner circle
    func innerCirclePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: innerCircleFrame())
    }

    /// return the bezier path for the outter circle
    func outterCirclePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: outterCircleFrame())
    }

    /// override layout subviews so we can draw the circles we need.
    override func layoutSubviews() {
        super.layoutSubviews()
        innerCirclePathLayer.frame = bounds
        innerCirclePathLayer.path = innerCirclePath().cgPath
        outterCirclePathLayer.frame = bounds
        outterCirclePathLayer.path = outterCirclePath().cgPath
    }

    /// Sets the Enabled style of the shutter button
    func setEnabled() {
        innerCirclePathLayer.fillColor = UIColor.white.cgColor
        outterCirclePathLayer.strokeColor = UIColor.white.cgColor
    }

    /// Sets the Disabled style of the shutter button
    func setDisabled() {
        innerCirclePathLayer.fillColor = UIColor.gray.cgColor
        outterCirclePathLayer.strokeColor = UIColor.gray.cgColor
    }
}
