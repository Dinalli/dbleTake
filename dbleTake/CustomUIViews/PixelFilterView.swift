//
//  PixelFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class PixelFilterView: FilterBaseView {
    let filterHelper = FilterHelper()
    var inputCenter: CIVector = CIVector(x: 150.0, y: 150.0)
    var inputScale: CGFloat = 1.0
    var horizontalSCroll: HorizontalNumberScrollView!

    override func configure() {
        super.configure()
        horizontalSCroll = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 5, width: self.frame.width, height: 100))
        horizontalSCroll.title = "Input Level"
        horizontalSCroll.startValue = 0
        horizontalSCroll.endValue = 100
        horizontalSCroll.interval = 0.1
        horizontalSCroll.numberColor = .white
        horizontalSCroll.delegate = self
        horizontalSCroll.configure()
        self.addSubview(horizontalSCroll)
    }

    override func setUpFilter() {
        super.setUpFilter()
    }
}

extension PixelFilterView: HorizontalScrollDelegate {
    func valueChanged(value: CGFloat) {
        let filteredImage = filterHelper.applyPixelFilter(image: self.originalCIImage,
                                                          inputScale: inputScale,
                                                          center: inputCenter)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}