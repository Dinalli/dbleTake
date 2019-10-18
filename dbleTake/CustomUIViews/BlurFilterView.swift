//
//  BlurFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class BlurFilterView: FilterBaseView {

    let filterHelper = FilterHelper()

    var inputRadius: CGFloat = 1.0
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

extension BlurFilterView: HorizontalScrollDelegate {
    func valueChanged(value: CGFloat) {
        let filteredImage = filterHelper.applyBlurFilter(image: self.originalCIImage, radius: inputRadius)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}
