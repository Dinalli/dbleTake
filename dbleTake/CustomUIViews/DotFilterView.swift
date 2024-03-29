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

    func configure() {
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 100, rangeLength: 250)
        rulerView.tintColor = .white
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.titleLabel.text = "Width"
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)

        let sharpNessRulerView = Ruler(frame: CGRect(x: 0, y: 65, width: self.frame.width, height: 50))
        self.addSubview(sharpNessRulerView)
        sharpNessRulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 100)
        sharpNessRulerView.tintColor = .white
        sharpNessRulerView.pointerImageView.layer.cornerRadius = 2
        sharpNessRulerView.titleLabel.text = "Sharpness"
        sharpNessRulerView.addTarget(self, action: #selector(sharpnessValueChanged(value:)), for: .valueChanged)

        let angleRulerView = Ruler(frame: CGRect(x: 0, y: 115, width: self.frame.width, height: 50))
        self.addSubview(angleRulerView)
        angleRulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 45)
        angleRulerView.tintColor = .white
        angleRulerView.pointerImageView.layer.cornerRadius = 2
        angleRulerView.titleLabel.text = "Angle"
        angleRulerView.addTarget(self, action: #selector(angleValueChanged(value:)), for: .valueChanged)
    }

    @objc func valueChanged(value: CGFloat) {
        inputWidth = value
        let filteredImage = filterHelper.applyDotFilter(image: originalCIImage,
                                                           inputWidth: inputWidth,
                                                           center: inputCenter,
                                                           angle: inputAngle,
                                                           sharpness: inputSharpness)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    @objc func sharpnessValueChanged(value: CGFloat) {
        inputSharpness = value / 100
        let filteredImage = filterHelper.applyDotFilter(image: originalCIImage,
                                                           inputWidth: inputWidth,
                                                           center: inputCenter,
                                                           angle: inputAngle,
                                                           sharpness: inputSharpness)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    @objc func angleValueChanged(value: CGFloat) {
        inputAngle = value / 100
        let filteredImage = filterHelper.applyDotFilter(image: originalCIImage,
                                                           inputWidth: inputWidth,
                                                           center: inputCenter,
                                                           angle: inputAngle,
                                                           sharpness: inputSharpness)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    override func setUpFilter() {
        super.setUpFilter()
        configure()
    }
}
