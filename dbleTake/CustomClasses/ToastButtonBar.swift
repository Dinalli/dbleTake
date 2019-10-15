//
//  ToastButtonBar.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 04/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

@IBDesignable class ToastButtonBar: UIView {

    /// override init to allow calling of configure when button is created.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    /// override init to allow calling of configure when button is created.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.alpha = 1.0
        self.layer.cornerRadius = 10
        self.clipsToBounds  =  true
    }

    func show() {

    }

    func dismiss() {

    }
}
