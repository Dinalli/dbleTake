//
//  SepiaFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 14/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class SepiaFilterView: FilterBaseView {

    let filterHelper = FilterHelper()

    var intensity: CGFloat = 1.0
    var horizontalSCroll: HorizontalNumberScrollView!

    override func configure() {
        super.configure()
        horizontalSCroll = HorizontalNumberScrollView(frame: CGRect(x: 0, y: 5, width: self.frame.width, height: 100))
        horizontalSCroll.title = "Intensity"
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

extension SepiaFilterView: HorizontalScrollDelegate {
    func valueChanged(value: CGFloat) {
        let intensityValue = value/100
        print("Intensity \(intensityValue)")
        let filteredImage = filterHelper.applySepiaFilter(image: self.originalCIImage, intensity: intensityValue)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}
