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

    override func configure() {
        super.configure()
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 100.0)
        rulerView.tintColor = .white
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)
    }

    @objc func valueChanged(value: CGFloat) {
        let intensityValue = value/100
        let filteredImage = filterHelper.applySepiaFilter(image: self.originalCIImage, intensity: intensityValue)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    override func setUpFilter() {
        super.setUpFilter()
    }
}
