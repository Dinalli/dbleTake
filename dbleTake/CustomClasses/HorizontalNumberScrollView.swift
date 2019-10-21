//
//  HorizontalNumberScrollView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 11/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

public protocol HorizontalScrollDelegate: AnyObject {
    /// called when the data has changed and the UI may need to be reloaded in ViewController
    func valueChanged(value: CGFloat)
}

@IBDesignable class HorizontalNumberScrollView: UIView {

    weak var delegate: HorizontalScrollDelegate?

    var startValue: Double!
    var endValue: Double!
    var interval: Double!
    var numberColor: UIColor = .black
    var backColor: UIColor = .clear
    var title: String!
    var currentValue: CGFloat!
    
    fileprivate var scrollViewLabels = [UILabel]()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /// override init to allow calling of configure when button is created.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure() {
        self.backgroundColor = backColor
        var scrollView: UIScrollView!
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 25, width: self.frame.width, height: self.frame.height))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = backColor

        let titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: self.frame.width, height: 21))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
        titleLabel.text = title
        titleLabel.textColor = numberColor
        self.addSubview(titleLabel)

        let pointerView = PointerView(frame: CGRect(x: 0, y: 2, width: 15, height: 15))
        pointerView.center = CGPoint(x: self.center.x-8, y: 2)
        pointerView.fillColor = numberColor
        pointerView.lineColor = numberColor
        pointerView.backgroundColor = UIColor.clear
        self.addSubview(pointerView)

        // LINES
        let lines = UIBezierPath()
        var contentWidth:Int = 0

        // DRAW TEMP OTHER LINES
        for value in stride(from: startValue, to: endValue, by: interval)
        {
            let isInteger = floor(value) == value
            let height = (isInteger) ? 20.0 : 10.0
            let oneLine = UIBezierPath()
            oneLine.move(to: CGPoint(x: value*50, y: 0))
            oneLine.addLine(to: CGPoint(x: value*50, y: height))

            lines.append(oneLine)
            // INDICATOR TEXT
            if(isInteger)
            {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
                label.center = CGPoint(x: value*50, y: 35)
                label.font = UIFont(name: "HelveticaNeue",
                                    size: 10.0)
                label.textAlignment = .center
                label.text = "\(value)"
                label.textColor = numberColor
                scrollView.addSubview(label)
                scrollViewLabels.append(label)
                contentWidth += 50
            }
        }
        scrollView.contentSize = CGSize(width: contentWidth+300, height: Int(self.frame.size.height))

        // DESIGN LINES IN LAYER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = lines.cgPath
        shapeLayer.strokeColor = numberColor.cgColor
        shapeLayer.lineWidth = 1

        // ADD LINES IN LAYER
        scrollView.layer.addSublayer(shapeLayer)
        scrollView.delegate = self
        self.addSubview(scrollView)
    }


}

extension HorizontalNumberScrollView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentValue = CGFloat(lroundf(Float(scrollView.contentOffset.x / CGFloat(endValue)))) //* 50

//        let viewIndex:Int = Int((scrollView.contentOffset.x/50))
//        let labelView = scrollViewLabels[viewIndex]
//        guard let valueString = labelView.text else { return }
//        let valueDouble = CGFloat(Double(valueString)!)
print(currentValue)
        if delegate != nil {
            delegate?.valueChanged(value: currentValue)
        }
    }
}
