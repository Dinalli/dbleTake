//
//  CaptureViewControllerModel.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 13/09/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class CaptureViewControllerModel: NSObject {

    var isMultiCam:Bool = false
    var hasCreatedViews: Bool = false

    var captureButton: ShutterButton!
    var backCameraPreview: PreviewView!
    var frontCameraPreview: PreviewView!
    
    /// Creates the views lays them out for the VC
    func createViews(view: UIView) {
        hasCreatedViews = true
        createCaptureButton()
    }


    func layoutViews(view: UIView) {

        frontCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        backCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)

        view.addConstraints([
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .leftMargin, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .top, relatedBy: .lessThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: view.frame.height - 180),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .right, relatedBy: .lessThanOrEqual, toItem: view, attribute: .right, multiplier: 1, constant: view.frame.width - 105),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .width, relatedBy: .lessThanOrEqual, toItem: view, attribute: .width, multiplier: 0, constant: 100),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .height, relatedBy: .lessThanOrEqual, toItem: view, attribute: .height, multiplier: 0, constant: 180)
        ])
        addConstraintsForCaptureButton(view: view)
    }

    /// Add Constraints for the new capture button depending on phone or ipad
    func addConstraintsForCaptureButton(view: UIView) {
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.addConstraints([
                NSLayoutConstraint(item: captureButton as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: captureButton as Any, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: captureButton as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 70),
                NSLayoutConstraint(item: captureButton as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 70)
                ])
        } else {
            view.addConstraints([
                NSLayoutConstraint(item: captureButton as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -90),
                NSLayoutConstraint(item: captureButton as Any, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: captureButton as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 70),
                NSLayoutConstraint(item: captureButton as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 70)
                ])
        }
    }

    /// Creates the capture button and returns it
    func createCaptureButton() {
        captureButton = ShutterButton(type: .custom)
        captureButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        captureButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.48).cgColor
        captureButton.layer.shadowOpacity = 1
        captureButton.layer.shadowRadius = 10
        captureButton.isEnabled = false
        captureButton.setDisabled()
    }
}
