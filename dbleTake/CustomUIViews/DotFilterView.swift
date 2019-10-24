//
//  DotFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class DotFilterView: FilterBaseView {
    let filterHelper = FilterHelper()

    var inputWidth: CGFloat = 1.0
    var inputAngle: CGFloat = 1.0
    var inputCenter: CIVector = CIVector(x: 150.0, y: 150.0)
    var inputSharpness: CGFloat = 1.0
    var horizontalScrollWidth: HorizontalNumberScrollView!
    var horizontalScrollAngle: HorizontalNumberScrollView!
    var horizontalScrollSharpness: HorizontalNumberScrollView!

    override func configure() {
        super.configure()
        horizontalScrollWidth = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 5, width: self.frame.width, height: 100))
        horizontalScrollWidth.title = "Input Width"
        horizontalScrollWidth.startValue = 0
        horizontalScrollWidth.endValue = 18
        horizontalScrollWidth.interval = 0.1
        horizontalScrollWidth.numberColor = .white
        horizontalScrollWidth.delegate = self
        horizontalScrollWidth.currentValue = 6.0
        horizontalScrollWidth.configure()
        self.addSubview(horizontalScrollWidth)

        horizontalScrollSharpness = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 75, width: self.frame.width, height: 100))
        horizontalScrollSharpness.title = "Input Sharpness"
        horizontalScrollSharpness.startValue = 0
        horizontalScrollSharpness.endValue = 1
        horizontalScrollSharpness.interval = 0.1
        horizontalScrollSharpness.numberColor = .white
        horizontalScrollSharpness.currentValue = 0.7
        horizontalScrollSharpness.delegate = self
        horizontalScrollSharpness.configure()
        self.addSubview(horizontalScrollSharpness)

        horizontalScrollAngle = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 135, width: self.frame.width, height: 100))
        horizontalScrollAngle.title = "Input Angle"
        horizontalScrollAngle.startValue = 0
        horizontalScrollAngle.endValue = 10
        horizontalScrollAngle.interval = 0.1
        horizontalScrollAngle.numberColor = .white
        horizontalScrollAngle.currentValue = 0.7
        horizontalScrollAngle.delegate = self
        horizontalScrollAngle.configure()
        self.addSubview(horizontalScrollAngle)
    }

    override func setUpFilter() {
        super.setUpFilter()
    }
}

extension DotFilterView: HorizontalScrollDelegate {
    func valueChanged(value: CGFloat) {
        inputWidth = horizontalScrollWidth.currentValue
        inputSharpness = horizontalScrollSharpness.currentValue
        inputAngle = horizontalScrollAngle.currentValue
        let filteredImage = filterHelper.applyDotFilter(image: originalCIImage,
                                                           inputWidth: inputWidth,
                                                           center: inputCenter,
                                                           angle: inputAngle,
                                                           sharpness: inputSharpness)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}
