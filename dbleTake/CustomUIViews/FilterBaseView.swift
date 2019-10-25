//
//  FilterBaseView.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 14/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

public protocol FilterDelegate: AnyObject {
    /// called when the data has changed and the UI may need to be reloaded in ViewController
    func updateImage(image: UIImage)
}

class FilterBaseView: UIView {

     weak var delegate: FilterDelegate?

    var originalImage: UIImage!
    fileprivate var filteredImage: UIImage!
    var originalCIImage: CIImage!

    func setUpFilter() {
        self.filteredImage = originalImage
        guard let originalCIImage = CIImage(image: originalImage) else { return }
        self.originalCIImage = originalCIImage
    }

    @objc func cancel() {
        self.filteredImage = originalImage
    }

    @objc func applyFilter() {
        if delegate != nil {
            delegate?.updateImage(image: self.filteredImage)
        }
    }
}
