//
//  HorizontalNumberScrollView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 11/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

@IBDesignable class HorizontalNumberScrollView: UIView {

    @IBInspectable var startValue: Int = 0
    @IBInspectable var endValue: Int = 1
    @IBInspectable var snapToZero:Bool = false
    @IBInspectable var numberColor: UIColor = .black
    @IBInspectable var backColor: UIColor = .clear

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
        self.backgroundColor = backColor
        var scrollView: UIScrollView!
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        scrollView.contentSize = CGSize(width: 2000, height: self.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = backColor

        let minTemp = 0.0
        let maxTemp = 36.8
        let interval = 0.1

        // LINES
        let lines = UIBezierPath()

        // DRAW TEMP OTHER LINES
        for temp in stride(from: minTemp, to: maxTemp, by: interval)
        {
            let isInteger = floor(temp) == temp

            let height = (isInteger) ? 20.0 : 10.0
            let oneLine = UIBezierPath()
            oneLine.move(to: CGPoint(x: temp*50, y: 0))
            oneLine.addLine(to: CGPoint(x: temp*50, y: height))

            lines.append(oneLine)

            // INDICATOR TEXT
            if(isInteger)
            {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
                label.center = CGPoint(x: temp*50, y: height+15)
                label.font = UIFont(name: "HelveticaNeue",
                                    size: 10.0)
                label.textAlignment = .center
                label.text = "\(temp) °C"
                label.textColor = UIColor.white
                scrollView.addSubview(label)
            }
        }

        // DESIGN LINES IN LAYER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = lines.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1

        // ADD LINES IN LAYER
        scrollView.layer.addSublayer(shapeLayer)
        self.addSubview(scrollView)
    }
}
