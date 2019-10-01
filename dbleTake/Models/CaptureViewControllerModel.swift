//
//  CaptureViewControllerModel.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 13/09/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit
import AVKit

class CaptureViewControllerModel: NSObject {

    var isMultiCam:Bool = false
    var hasCreatedViews: Bool = false

    var captureButton: ShutterButton!
    var backCameraPreview: PreviewView!
    var frontCameraPreview: PreviewView!
    var flashButton: UIBarButtonItem!

    var captureButtonRightConstraint: NSLayoutConstraint!
    var captureButtonBottomConstraint: NSLayoutConstraint!
    var captureButtonCenterY: NSLayoutConstraint!
    var captureButtonCenterX: NSLayoutConstraint!

    var portraitfrontCameraWidthConstraint: NSLayoutConstraint!
    var portraitfrontCameraHeightConstraint: NSLayoutConstraint!
    var landscapefrontCameraWidthConstraint: NSLayoutConstraint!
    var landscapefrontCameraHeightConstraint: NSLayoutConstraint!

    var portraitBackCameraWidthConstraint: NSLayoutConstraint!
    var portraitBackCameraHeightConstraint: NSLayoutConstraint!
    var landscapeBackCameraWidthConstraint: NSLayoutConstraint!
    var landscapeBackCameraHeightConstraint: NSLayoutConstraint!

    var frontCameraConstraints: [NSLayoutConstraint]!
    var backCameraConstraints: [NSLayoutConstraint]!

    var captureCameraDevice: AVCaptureDevice!

    private var cameraDevicePosition: AVCaptureDevice.Position = .front

    /// Flash mode enum - Auto, On, Off
    enum UserFlashMode {
        /// Used when flash mode is set to Auto
        case flashModeAuto
        /// Used when flash mode is set to On
        case flashModeOn
        /// Used when flash mode is set to Off
        case flashModeOff
    }

    /// Current mode that is set by the user, default to Off
    var currentUserFlashMode = UserFlashMode.flashModeOff

    /// Allow the user to change the flash settings if we have one on the device.
    func changeFlash() {
        if captureCameraDevice.hasFlash {
            switch currentUserFlashMode {
            case .flashModeOff:
                self.flashButton.image = UIImage(named: "flash-auto")
                currentUserFlashMode = .flashModeAuto
            case .flashModeAuto:
                self.flashButton.image = UIImage(named: "flash-on")
                currentUserFlashMode = .flashModeOn
            case .flashModeOn:
                self.flashButton.image = UIImage(named: "856-lightning-bolt")
                currentUserFlashMode = .flashModeOff
            }
        } else {
            flashButton.isEnabled = false
        }
    }

    /// Checks if we have flash enabled on the device
    func checkHasFlash() {
        if captureCameraDevice != nil && !captureCameraDevice.hasFlash {
            flashButton.isEnabled = false
        }
    }

    /// returns the current flash mode of the device
    func flashMode() -> AVCaptureDevice.FlashMode {
        if captureCameraDevice.hasFlash {
            if currentUserFlashMode == UserFlashMode.flashModeAuto {
                return .auto
            } else if currentUserFlashMode == UserFlashMode.flashModeOn {
                return .on
            } else {
                return .off
            }
        }
        return .off
    }

    /// Creates the views lays them out for the VC
    func createViews(view: UIView) {
        hasCreatedViews = true
        createCaptureButton()
        view.addSubview(captureButton)

        frontCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        backCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        captureButtonRightConstraint = NSLayoutConstraint(item: captureButton as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -90)
        captureButtonBottomConstraint = NSLayoutConstraint(item: captureButton as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -90)
        captureButtonCenterX = NSLayoutConstraint(item: captureButton as Any, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        captureButtonCenterY = NSLayoutConstraint(item: captureButton as Any, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)

        portraitfrontCameraWidthConstraint = NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 100)
        portraitfrontCameraHeightConstraint = NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 180)

        landscapefrontCameraWidthConstraint = NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 180)
        landscapefrontCameraHeightConstraint = NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 100)

        portraitBackCameraWidthConstraint = NSLayoutConstraint(item: backCameraPreview as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 100)
        portraitBackCameraHeightConstraint = NSLayoutConstraint(item: backCameraPreview as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 180)

        landscapeBackCameraWidthConstraint = NSLayoutConstraint(item: backCameraPreview as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 180)
        landscapeBackCameraHeightConstraint = NSLayoutConstraint(item: backCameraPreview as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 100)

        view.addConstraints([
            NSLayoutConstraint(item: captureButton as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 70),
            NSLayoutConstraint(item: captureButton as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: 70),
        ])

        frontCameraConstraints = [
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .leftMargin, multiplier: 1, constant: 5),
            portraitfrontCameraWidthConstraint, portraitfrontCameraHeightConstraint, landscapefrontCameraWidthConstraint, landscapefrontCameraHeightConstraint
        ]

        backCameraConstraints = [
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: frontCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backCameraPreview as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .leftMargin, multiplier: 1, constant: 5),
            portraitBackCameraWidthConstraint, portraitBackCameraHeightConstraint, landscapeBackCameraWidthConstraint, landscapeBackCameraHeightConstraint
        ]

        NSLayoutConstraint.activate(frontCameraConstraints)
    }

    func layoutViews(view: UIView) {
        frontCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        backCameraPreview.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        switch UIDevice.current.orientation {
        case .portrait,
             .portraitUpsideDown:
            changeConstraintsForPortrait(view: view)
        case .landscapeLeft, .landscapeRight:
            changeConstraintsForLandscape(view: view)
        default: // .unknown
            changeConstraintsForPortrait(view: view)
        }
        changeConstraintsForCaptureButton(view: view)
    }

    func changeConstraintsForPortrait(view: UIView) {
        NSLayoutConstraint.deactivate([landscapefrontCameraWidthConstraint, landscapefrontCameraHeightConstraint])
        NSLayoutConstraint.activate([portraitfrontCameraHeightConstraint, portraitfrontCameraWidthConstraint])
    }

    func changeConstraintsForLandscape(view: UIView) {
        NSLayoutConstraint.deactivate([portraitfrontCameraHeightConstraint, portraitfrontCameraWidthConstraint])
        NSLayoutConstraint.activate([landscapefrontCameraWidthConstraint, landscapefrontCameraHeightConstraint])
    }

    /// Add Constraints for the new capture button depending on phone or ipad
    func changeConstraintsForCaptureButton(view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.deactivate([captureButtonCenterX])
            NSLayoutConstraint.activate([captureButtonCenterY])
            NSLayoutConstraint.deactivate([captureButtonBottomConstraint])
            NSLayoutConstraint.activate([captureButtonRightConstraint])
        } else {
            switch UIDevice.current.orientation {
            case .portrait,
                 .portraitUpsideDown:
                NSLayoutConstraint.deactivate([captureButtonCenterY, captureButtonRightConstraint])
                NSLayoutConstraint.activate([captureButtonBottomConstraint, captureButtonCenterX])
            case .landscapeLeft, .landscapeRight:
                NSLayoutConstraint.deactivate([captureButtonBottomConstraint, captureButtonCenterX])
                NSLayoutConstraint.activate([captureButtonCenterY, captureButtonRightConstraint])
            default: // .unknown
                NSLayoutConstraint.deactivate([captureButtonCenterY, captureButtonRightConstraint])
                NSLayoutConstraint.activate([captureButtonBottomConstraint, captureButtonCenterX])
            }
        }
    }

    /// Creates the capture button and returns it
    func createCaptureButton() {
        captureButton = ShutterButton(type: .custom)
        captureButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        captureButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.48).cgColor
        captureButton.layer.shadowOpacity = 1
        captureButton.layer.shadowRadius = 10
    }

    func switchCameras(view: UIView){
        // Disable animations so the views move immediately
        CATransaction.begin()
        UIView.setAnimationsEnabled(false)
        CATransaction.setDisableActions(true)

        if cameraDevicePosition == .front {
            NSLayoutConstraint.deactivate(frontCameraConstraints)
            NSLayoutConstraint.activate(backCameraConstraints)
            view.sendSubviewToBack(frontCameraPreview)
            cameraDevicePosition = .back
        } else {
            NSLayoutConstraint.deactivate(backCameraConstraints)
            NSLayoutConstraint.activate(frontCameraConstraints)
            view.sendSubviewToBack(backCameraPreview)
            cameraDevicePosition = .front
        }

        CATransaction.commit()
        UIView.setAnimationsEnabled(true)
        CATransaction.setDisableActions(false)
    }
}
