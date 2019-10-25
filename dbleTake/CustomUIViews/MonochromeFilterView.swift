//
//  MonochromeFilterView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 18/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class MonochromeFilterView: FilterBaseView {

    let filterHelper = FilterHelper()

    var inputColor: UIColor = .green
    var inputIntensity: CGFloat = 1.0

    func configure() {
        let rulerView = Ruler(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        self.addSubview(rulerView)
        rulerView.setRangeFromAndLength(rangeFrom: 1.0, rangeLength: 100)
        rulerView.tintColor = .white
        rulerView.pointerImageView.layer.cornerRadius = 2
        rulerView.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)

        let colorPickerView = ColorPickerView(frame: CGRect(x: 0, y: 80, width: self.frame.width, height: 150))
        colorPickerView.onColorDidChange = { [weak self] color in
            DispatchQueue.main.async {
                // use picked color for your needs here...
                self?.inputColor = color
                let filteredImage = self!.filterHelper.applyMonochromeFilter(image: self!.originalCIImage,
                                                                            inputColor: CIColor(color: self!.inputColor),
                                                                            inputIntensity: self!.inputIntensity)
                if self!.delegate != nil {
                    self!.delegate?.updateImage(image: filteredImage)
                }
            }
        }
        self.addSubview(colorPickerView)
    }

    @objc func valueChanged(value: CGFloat) {
        inputIntensity = value / 100
        let filteredImage = filterHelper.applyMonochromeFilter(image: self.originalCIImage,
                                                               inputColor: CIColor(color: inputColor),
                                                               inputIntensity: inputIntensity)
        if delegate != nil {
            delegate?.updateImage(image: filteredImage)
        }
    }

    override func setUpFilter() {
        super.setUpFilter()
        configure()
    }
}
