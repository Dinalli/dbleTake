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

    override func configure() {
        super.configure()
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 20)
        rulerView.tintColor = .white
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)
    }

    override func setUpFilter() {
        super.setUpFilter()
    }

    @objc func valueChanged(value: CGFloat) {
        inputRadius = value
        let filteredImage = filterHelper.applyBlurFilter(image: self.originalCIImage, radius: inputRadius)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }
}
