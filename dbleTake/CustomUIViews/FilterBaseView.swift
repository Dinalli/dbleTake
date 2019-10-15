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
    fileprivate let cancelButton = UIButton(type: .custom)
    fileprivate let applyButton = UIButton(type: .custom)
    var originalCIImage: CIImage!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    /// override init to allow calling of configure when button is created.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func setUpButtons() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)

        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.cornerRadius = 8.0

        applyButton.layer.borderWidth = 1.0
        applyButton.layer.borderColor = UIColor.white.cgColor
        applyButton.layer.cornerRadius = 8.0

        self.addSubview(cancelButton)
        self.addSubview(applyButton)
    }

    override func layoutSubviews() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: cancelButton as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: cancelButton as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: cancelButton as Any, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: cancelButton as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: applyButton as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: applyButton as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: applyButton as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: applyButton as Any, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 5)
        ])
    }

    func configure() {
        setUpButtons()
    }

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
