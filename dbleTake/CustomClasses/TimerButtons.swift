//
//  TimerButtons.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 06/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

public protocol TimerButtonDelegate: AnyObject {
    /// called when the data has changed and the UI may need to be reloaded in ViewController
    func timerSet(time: TimeInterval)
}

class TimerButtons: ToastButtonBar {

    weak var delegate: TimerButtonDelegate?

    let threeSecButton = UIButton(type: .custom)
    let fiveSecButton = UIButton(type: .custom)
    let tenSecButton = UIButton(type: .custom)

    override func configure() {
        super.configure()
        setUpButtons()
    }

    func setUpButtons() {
        threeSecButton.setTitle("3 Secs", for: .normal)
        threeSecButton.addTarget(self, action: #selector(threeSecondTimer), for: .touchUpInside)
        fiveSecButton.setTitle("5 Secs", for: .normal)
        fiveSecButton.addTarget(self, action: #selector(fiveSecondTimer), for: .touchUpInside)
        tenSecButton.setTitle("10 Secs", for: .normal)
        tenSecButton.addTarget(self, action: #selector(tenSecondTimer), for: .touchUpInside)

        threeSecButton.layer.borderWidth = 1.0
        threeSecButton.layer.borderColor = UIColor.white.cgColor
        threeSecButton.layer.cornerRadius = 8.0

        fiveSecButton.layer.borderWidth = 1.0
        fiveSecButton.layer.borderColor = UIColor.white.cgColor
        fiveSecButton.layer.cornerRadius = 8.0

        tenSecButton.layer.borderWidth = 1.0
        tenSecButton.layer.borderColor = UIColor.white.cgColor
        tenSecButton.layer.cornerRadius = 8.0

        self.addSubview(threeSecButton)
        self.addSubview(fiveSecButton)
        self.addSubview(tenSecButton)
    }

    override func layoutSubviews() {
        threeSecButton.translatesAutoresizingMaskIntoConstraints = false
        fiveSecButton.translatesAutoresizingMaskIntoConstraints = false
        tenSecButton.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: threeSecButton as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: threeSecButton as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: fiveSecButton as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: fiveSecButton as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: tenSecButton as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: tenSecButton as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: threeSecButton as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: tenSecButton as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: fiveSecButton as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: threeSecButton as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: tenSecButton as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: fiveSecButton as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5)
        ])
    }

    @objc func threeSecondTimer() {
        if delegate != nil {
            delegate?.timerSet(time: 3.0)
        }
    }

    @objc func fiveSecondTimer() {
        if delegate != nil {
            delegate?.timerSet(time: 5.0)
        }
    }

    @objc func tenSecondTimer() {
        if delegate != nil {
            delegate?.timerSet(time: 10.0)
        }
    }
}
