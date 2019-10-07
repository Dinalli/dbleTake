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
//        var toastHeight = toastLabel.intrinsicContentSize.height
//        var toastWidth = toastLabel.intrinsicContentSize.width + 20
//        if toastWidth > presentingVC.view.frame.width {
//            toastHeight *= 2
//            toastWidth = presentingVC.view.frame.width-20
//            toastLabel.numberOfLines = 0
//        }
//        toastLabel.frame = CGRect(x: 0, y: presentingVC.view.frame.height - 240, width: toastWidth, height: toastHeight + 20)
//        toastLabel.center.x = presentingVC.view.center.x
//        presentingVC.view.addSubview(toastLabel)
//        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(_ ) in
//            toastLabel.removeFromSuperview()
//        })
    }

    func show() {

    }

    func dismiss() {

    }
}
