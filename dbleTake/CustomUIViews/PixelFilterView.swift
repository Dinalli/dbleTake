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
    var inputScale: CGFloat = 1.0

    func configure() {
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 20)
        rulerView.tintColor = .white
        rulerView.titleLabel.text = "Scale"
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)
    }

    @objc func valueChanged(value: CGFloat) {
        inputScale = value
        let filteredImage = filterHelper.applyPixelFilter(image: self.originalCIImage,
                                                          inputScale: inputScale)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    override func setUpFilter() {
        super.setUpFilter()
        configure()
    }
}
