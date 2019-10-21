//
//  CircleFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class CircleFilterView: FilterBaseView {
    let filterHelper = FilterHelper()

    var inputWidth: CGFloat = 1.0
    var inputCenter: CIVector = CIVector(x: 150.0, y: 150.0)
    var inputSharpness: CGFloat = 1.0

    var horizontalSCrollWidth: HorizontalNumberScrollView!
    var horizontalSCrollSharpness: HorizontalNumberScrollView!
    
    override func configure() {
        super.configure()
        horizontalSCrollWidth = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 5, width: self.frame.width, height: 100))
        horizontalSCrollWidth.title = "Input Width"
        horizontalSCrollWidth.startValue = 0
        horizontalSCrollWidth.endValue = 18
        horizontalSCrollWidth.interval = 0.1
        horizontalSCrollWidth.numberColor = .white
        horizontalSCrollWidth.delegate = self
        horizontalSCrollWidth.currentValue = 6.0
        horizontalSCrollWidth.configure()
        self.addSubview(horizontalSCrollWidth)

        horizontalSCrollSharpness = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 75, width: self.frame.width, height: 100))
        horizontalSCrollSharpness.title = "Input Sharpness"
        horizontalSCrollSharpness.startValue = 0
        horizontalSCrollSharpness.endValue = 1
        horizontalSCrollSharpness.interval = 0.1
        horizontalSCrollSharpness.numberColor = .white
        horizontalSCrollSharpness.currentValue = 0.7
        horizontalSCrollSharpness.delegate = self
        horizontalSCrollSharpness.configure()
        self.addSubview(horizontalSCrollSharpness)
    }
    
    override func setUpFilter() {
        super.setUpFilter()
    }
}

extension CircleFilterView: HorizontalScrollDelegate {
    func valueChanged(value: CGFloat) {
        inputWidth = horizontalSCrollWidth.currentValue
        inputSharpness = horizontalSCrollSharpness.currentValue
        let filteredImage = filterHelper.applyCircleFilter(image: originalCIImage,
                                                           inputWidth: inputWidth,
                                                           center: inputCenter,
                                                           sharpness: inputSharpness)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}
