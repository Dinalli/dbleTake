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
import Vision

class CaptureViewController: UIViewController  {

    let faceDetectionHelper = FaceDetectionHelper()

    var frontImage: UIImage!
    var backImage: UIImage!

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

    var timerButtons: TimerButtons!
    var isTimerButtonShown: Bool = false
    var countdownTimer: Timer!
    var countdownInt: Int = 0
    var firstImageHasBeenCaptured: Bool = false
    var captureDeviceResolution: CGSize = CGSize()

    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()

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
        self.prepareVisionRequest()
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

        captureDeviceResolution = faceDetectionHelper.getResolutionForDevice(for: backCamera)
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

        /// Wire up for face detection
        configureVideoDataOutput(for: backCamera, resolution: captureDeviceResolution, captureSession: session)
        return true
    }

    /// - Tag: CreateSerialDispatchQueue
    fileprivate func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }

        videoDataOutput.connection(with: .video)?.isEnabled = true

        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        self.captureDeviceResolution = resolution
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
        capturePhotos()
    }

    func capturePhotos() {
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

    @IBAction func timerTapped(_ sender: UIBarButtonItem){
        if isTimerButtonShown {
            timerButtons.removeFromSuperview()
            isTimerButtonShown = false
        } else {
            let frame = CGRect(x: 0, y: self.view.frame.height - 240, width: self.view.frame.width - 60, height: 80)
            timerButtons = TimerButtons(frame: frame)
            timerButtons.center.x = self.view.center.x
            timerButtons.delegate = self
            self.view.addSubview(timerButtons)
            isTimerButtonShown = true
        }
    }

    func startCountdown(timerInterval: TimeInterval) {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.model.setCountdownLabel(counter: "\(self.countdownInt)")
            self.model.countdownLabel.isHidden = false
            self.countdownInt -= 1
            if self.countdownInt == -1 {
                self.capturePhotos()
                self.countdownTimer.invalidate()
                self.model.countdownLabel.isHidden = true
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMergedSegue" {
            guard let mergeVC = segue.destination as? MergedViewController else { fatalError("Unexpected view controller for segue") }
            mergeVC.frontImage = frontImage
            mergeVC.backImage = backImage
        }
    }

    // MARK: Performing Vision Requests

    fileprivate func prepareVisionRequest() {

        //self.trackingRequests = []
        var requests = [VNTrackObjectRequest]()

        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in

            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }

            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async {
                // Add the observations to the tracking list
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        })

        // Start with detection.  Find face, then track it.
        self.detectionRequests = [faceDetectionRequest]

        self.sequenceRequestHandler = VNSequenceRequestHandler()

        faceDetectionHelper.rootLayer = self.backCameraPreview.layer
        faceDetectionHelper.previewLayer = backCameraVideoPreviewLayer
        faceDetectionHelper.setupVisionDrawingLayers()
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

        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
        }

        guard let frontImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
        }

        if firstImageHasBeenCaptured {
            self.backImage = frontImage
            self.performSegue(withIdentifier: "showMergedSegue", sender: self)
        } else {
            self.frontImage = frontImage
            firstImageHasBeenCaptured = true
        }
    }
}

extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]

        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }

        let exifOrientation = faceDetectionHelper.exifOrientationForCurrentDeviceOrientation()
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            // No tracking object detected, so perform initial detection
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)

            do {
                guard let detectRequests = self.detectionRequests else {
                    return
                }
                try imageRequestHandler.perform(detectRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceRectangleRequest: %@", error)
            }
            return
        }

        do {
            try self.sequenceRequestHandler.perform(requests,
                                                     on: pixelBuffer,
                                                     orientation: exifOrientation)
        } catch let error as NSError {
            NSLog("Failed to perform SequenceRequest: %@", error)
        }

        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in requests {

            guard let results = trackingRequest.results else {
                return
            }

            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }

            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests

        if newTrackingRequests.isEmpty {
            // Nothing to track, so abort.
            return
        }

        // Perform face landmark tracking on detected faces.
        var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()

        // Perform landmark detection on tracked faces.
        for trackingRequest in newTrackingRequests {

            let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in

                if error != nil {
                    print("FaceLandmarks error: \(String(describing: error)).")
                }

                guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                    let results = landmarksRequest.results as? [VNFaceObservation] else {
                        return
                }

                // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
                DispatchQueue.main.async {
                    self.faceDetectionHelper.drawFaceObservations(results)
                }
            })

            guard let trackingResults = trackingRequest.results else {
                return
            }

            guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                return
            }
            let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
            faceLandmarksRequest.inputFaceObservations = [faceObservation]

            // Continue to track detected facial landmarks.
            faceLandmarkRequests.append(faceLandmarksRequest)

            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)

            do {
                try imageRequestHandler.perform(faceLandmarkRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceLandmarkRequest: %@", error)
            }
        }
    }
}

extension CaptureViewController: TimerButtonDelegate {
    func timerSet(time: TimeInterval) {
        timerButtons.removeFromSuperview()
        isTimerButtonShown = false
        countdownInt = Int(time)
        startCountdown(timerInterval: time)
    }
}
