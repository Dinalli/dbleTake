//
//  PosterizeFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class PosterizeFilterView: FilterBaseView {

  let filterHelper = FilterHelper()

    var inputLevel: CGFloat = 1.0

    func configure() {
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 2.0, rangeLength: 12)
        rulerView.setValue(value: 6.0)
        rulerView.tintColor = .white
        rulerView.titleLabel.text = "Input Level"
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)
    }

    @objc func valueChanged(value: CGFloat) {
        let inputLevel = value
        let filteredImage = filterHelper.applyPosterizeFilter(image: self.originalCIImage, inputLevel: inputLevel)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    override func setUpFilter() {
        super.setUpFilter()
        configure()
    }
}

