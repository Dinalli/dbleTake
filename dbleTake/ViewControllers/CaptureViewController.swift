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

    @IBOutlet weak var backCameraPreview: PreviewView!
    @IBOutlet weak var frontCameraPreview: PreviewView!
    private weak var backCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private weak var frontCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?

    private let session = AVCaptureMultiCamSession()
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.

    var backCameraDeviceInput: AVCaptureDeviceInput?
    var frontCameraDeviceInput: AVCaptureDeviceInput?

    let frontPhotoOutput = AVCapturePhotoOutput()
    let backPhotoOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMultiCaptureSession()
    }

    private func setUpMultiCaptureSession() {
        // Set up the back and front video preview views.
        backCameraPreview.videoPreviewLayer.setSessionWithNoConnection(session)
        frontCameraPreview.videoPreviewLayer.setSessionWithNoConnection(session)

        // Store the back and front video preview layers so we can connect them to their inputs
        backCameraVideoPreviewLayer = backCameraPreview.videoPreviewLayer
        frontCameraVideoPreviewLayer = frontCameraPreview.videoPreviewLayer

        sessionQueue.async {
            self.configureSession()
        }
    }

    private func configureSession() {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("MultiCam not supported on this device")
            DispatchQueue.main.async {
                let alertMessage = "Alert message when multi cam is not supported"
                let message = NSLocalizedString("Multi Cam Not Supported", comment: alertMessage)
                let alertController = UIAlertController(title: "Unsupported Device", message: message, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
            }
            return
        }

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
        let backCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: backCameraVideoPort, videoPreviewLayer: backCameraVideoPreviewLayer)
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
                    print("Could not add back camera device input")
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
        let frontCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: frontCameraVideoPort, videoPreviewLayer: frontCameraVideoPreviewLayer)
        guard session.canAddConnection(frontCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the back camera video preview layer")
            return false
        }
        session.addConnection(frontCameraVideoPreviewLayerConnection)
        return true
    }

    @IBAction func shutterTapped(_ sender: Any) {
        let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        backPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        frontPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
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
