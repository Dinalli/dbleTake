//
//  CaptureViewController.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 12/09/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit
import AVKit
import Photos

class CaptureViewController: UIViewController  {

    let model = CaptureViewControllerModel()
    var isMultiCamSupported:Bool = false

    @IBOutlet weak var backCameraPreview: PreviewView!
    @IBOutlet weak var frontCameraPreview: PreviewView!
    private weak var backCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private weak var frontCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?

    private var session: AVCaptureSession!
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.

    var backCameraDeviceInput: AVCaptureDeviceInput?
    var frontCameraDeviceInput: AVCaptureDeviceInput?

    var frontCameraVideoPreviewLayerConnection: AVCaptureConnection!
    var backCameraVideoPreviewLayerConnection: AVCaptureConnection!

    let frontPhotoOutput = AVCapturePhotoOutput()
    let backPhotoOutput = AVCapturePhotoOutput()

    // Use for single cam mode only
    var singleCapturePosition: AVCaptureDevice.Position!

    @IBOutlet weak var flashButton: UIBarButtonItem!
    var captureButton: ShutterButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        model.frontCameraPreview = self.frontCameraPreview
        model.backCameraPreview = self.backCameraPreview
        if AVCaptureMultiCamSession.isMultiCamSupported {
            isMultiCamSupported = true
            setUpMultiCaptureSession()
        } else {
            print("MultiCam not supported on this device")
            DispatchQueue.main.async {
                let alertMessage = "MultiCam not supported on this device"
                let message = NSLocalizedString("Switching to single Cam mode.", comment: alertMessage)
                let alertController = UIAlertController(title: "MultiCam not supported on this device", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            setUpSingleCamSession()
        }

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(setCameraOrientation),
                                        name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                        object: nil)
    }

    /// Creates the views in the model on first load
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if model.hasCreatedViews == false {
            model.isMultiCam = isMultiCamSupported
            model.flashButton = flashButton
            model.createViews(view: self.view)
            self.captureButton = model.captureButton
            self.captureButton?.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        }
        model.layoutViews(view: self.view)
    }

    private func setUpMultiCaptureSession() {
        session = AVCaptureMultiCamSession()
        // Set up the back and front video preview views.
        backCameraPreview.videoPreviewLayer.setSessionWithNoConnection(session)
        frontCameraPreview.videoPreviewLayer.setSessionWithNoConnection(session)

        // Store the back and front video preview layers so we can connect them to their inputs
        backCameraVideoPreviewLayer = backCameraPreview.videoPreviewLayer
        frontCameraVideoPreviewLayer = frontCameraPreview.videoPreviewLayer

        sessionQueue.async {
            self.configureMultiSession()
        }
    }

    private func setUpSingleCamSession() {
        session = AVCaptureSession()
        backCameraPreview.videoPreviewLayer.setSessionWithNoConnection(session)
        backCameraVideoPreviewLayer = backCameraPreview.videoPreviewLayer
        sessionQueue.async {
            self.configureSingleSession()
        }
        singleCapturePosition = .back
    }

    private func configureSingleSession() {
        session.beginConfiguration()
        guard configureBackCamera() else {
            print("Backcam configuration failed")
            return
        }
        session.commitConfiguration()
        session.startRunning()
    }

    private func configureMultiSession() {
        session.beginConfiguration()
        guard configureBackCamera() else {
            print("Backcam configuration failed")
            return
        }

        guard configureFrontCamera() else {
            print("FrontCam configuration failed")
            return
        }
        session.commitConfiguration()
        session.startRunning()
    }

    private func configureBackCamera() -> Bool {
        // Find the back camera
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Could not find the back camera")
            return false
        }

        model.captureCameraDevice = backCamera
        model.checkHasFlash()
        // Add the back camera input to the session
        do {
            backCameraDeviceInput = try AVCaptureDeviceInput(device: backCamera)

            guard let backCameraDeviceInput = backCameraDeviceInput,
                session.canAddInput(backCameraDeviceInput) else {
                    print("Could not add back camera device input")
                    return false
            }
            session.addInputWithNoConnections(backCameraDeviceInput)
        } catch {
            print("Could not create back camera device input: \(error)")
            return false
        }

        // Find the back camera device input's video port
        guard let backCameraDeviceInput = backCameraDeviceInput,
            let backCameraVideoPort = backCameraDeviceInput.ports(for: .video,
                                                              sourceDeviceType: backCamera.deviceType,
                                                              sourceDevicePosition: backCamera.position).first else {
                                                                print("Could not find the back camera device input's video port")
                                                                return false
        }

        // Connect the back camera device input to the back camera video preview layer
        guard let backCameraVideoPreviewLayer = backCameraVideoPreviewLayer else {
            return false
        }
        session.addOutput(backPhotoOutput)
        backCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: backCameraVideoPort, videoPreviewLayer: backCameraVideoPreviewLayer)
        guard session.canAddConnection(backCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the back camera video preview layer")
            return false
        }
        session.addConnection(backCameraVideoPreviewLayerConnection)
        return true
    }

    private func configureFrontCamera() -> Bool {
        // Find the back camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Could not find the front camera")
            return false
        }

        // Add the back camera input to the session
        do {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCamera)

            guard let frontCameraDeviceInput = frontCameraDeviceInput,
                session.canAddInput(frontCameraDeviceInput) else {
                    print("Could not add front camera device input")
                    return false
            }
            session.addInputWithNoConnections(frontCameraDeviceInput)
        } catch {
            print("Could not create front camera device input: \(error)")
            return false
        }

        // Find the back camera device input's video port
        guard let frontCameraDeviceInput = frontCameraDeviceInput,
            let frontCameraVideoPort = frontCameraDeviceInput.ports(for: .video,
                                                              sourceDeviceType: frontCamera.deviceType,
                                                              sourceDevicePosition: frontCamera.position).first else {
                                                                print("Could not find the back camera device input's video port")
                                                                return false
        }
        session.addOutput(frontPhotoOutput)
        // Connect the back camera device input to the back camera video preview layer
        guard let frontCameraVideoPreviewLayer = frontCameraVideoPreviewLayer else {
            return false
        }
        frontCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: frontCameraVideoPort, videoPreviewLayer: frontCameraVideoPreviewLayer)
        guard session.canAddConnection(frontCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the front camera video preview layer")
            return false
        }
        session.addConnection(frontCameraVideoPreviewLayerConnection)
        return true
    }

    private func configureFrontSingleCamera() -> Bool {
        // Find the back camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Could not find the front camera")
            return false
        }

        // Add the back camera input to the session
        do {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCamera)

            guard let frontCameraDeviceInput = frontCameraDeviceInput,
                session.canAddInput(frontCameraDeviceInput) else {
                    print("Could not add front camera device input")
                    return false
            }
            session.addInputWithNoConnections(frontCameraDeviceInput)
        } catch {
            print("Could not create front camera device input: \(error)")
            return false
        }

        // Find the back camera device input's video port
        guard let frontCameraDeviceInput = frontCameraDeviceInput,
            let frontCameraVideoPort = frontCameraDeviceInput.ports(for: .video,
                                                              sourceDeviceType: frontCamera.deviceType,
                                                              sourceDevicePosition: frontCamera.position).first else {
                                                                print("Could not find the back camera device input's video port")
                                                                return false
        }
        session.addOutput(frontPhotoOutput)
        // Connect the back camera device input to the back camera video preview layer
        guard let backCameraVideoPreviewLayer = backCameraVideoPreviewLayer else {
            return false
        }
        frontCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: frontCameraVideoPort, videoPreviewLayer: backCameraVideoPreviewLayer)
        guard session.canAddConnection(frontCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the back camera video preview layer")
            return false
        }
        session.addConnection(frontCameraVideoPreviewLayerConnection)
        return true
    }


    /// Gets the best camera for the position
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                mediaType: .video, position: position)
        let devices = discoverySession.devices
        guard !devices.isEmpty else { return nil }
        return devices.first(where: { device in device.position == position })!
    }

    /// Set the camera orientation when the device is rotated.
    @objc func setCameraOrientation() {
        switch UIDevice.current.orientation {
        case .portrait:
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            print("portrait upside down")
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
        case .faceDown:
            print("facedown")
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
        case .faceUp:
             print("faceup")
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        default: // .unknown
            self.backCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.frontCameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }

    @objc func shutterTapped(_ sender: Any) {
        let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = model.flashMode()
        backPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        if isMultiCamSupported {
            frontPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            // switch to other cam and take photo
            switchSingleCamera { (success) in
                if success {
                    self.frontPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
                } else {
                    print("FrontCam capture failed")
                }
            }
        }
    }

    func switchSingleCamera(completion: @escaping (Bool) -> Void) {
        session.beginConfiguration()
        if singleCapturePosition == .back {
            session.removeInput(backCameraDeviceInput!)
            session.removeOutput(backPhotoOutput)
            guard configureFrontSingleCamera() else {
                print("FrontCam configuration failed")
                completion(false)
                return
            }
            singleCapturePosition = .front
        } else {
            session.removeInput(frontCameraDeviceInput!)
            session.removeOutput(frontPhotoOutput)
            guard configureBackCamera() else {
                print("backCam configuration failed")
                completion(false)
                return
            }
            singleCapturePosition = .back
        }
        session.commitConfiguration()
        session.startRunning()
        completion(true)
    }

    @IBAction func switchCameras(_ sender: Any) {
        if isMultiCamSupported {
            model.switchCameras(view: self.view)
        } else {
            switchSingleCamera { (success) in
            }
        }
    }

    @IBAction func switchFlashMode(_ sender: Any) {
        model.changeFlash()
    }
}

extension CaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data resource")
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                })
            }
        }
    }
}
