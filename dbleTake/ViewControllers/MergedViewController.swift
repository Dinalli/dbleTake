//
//  MergedViewController.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 07/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit
import Photos

class MergedViewController: UIViewController {

    let model = MergedViewControllerModel()
    let imageHelper = ImageHelper()
    let filterHelper = FilterHelper()

    struct Filter {
        let filterName: String
        let displayName: String
        var description: String { return displayName }
    }

    var frontImage: UIImage!
    var backImage: UIImage!
    var originalFrontImage: UIImage!
    var originalBackImage: UIImage!

    var orientation: ImageCaptureOrientation!

    @IBOutlet weak var imageViewHolder: UIView!
    @IBOutlet weak var imageViewFront: UIImageView!
    @IBOutlet weak var imageViewBack: UIImageView!
    @IBOutlet weak var filteredImageScrollView: UIScrollView!
    @IBOutlet weak var filterView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setUpImages()
        setUpModel()

        autoreleasepool {
            let newImage = imageHelper.mergeFrontAndBackImagesPortrait(frontImage: frontImage, backImage: backImage)
            let thumbSize = CGSize(width: 90, height: 100)
            guard let imageData = newImage.jpegData(compressionQuality: 1) else { return }
            showFilteredImages(image: imageHelper.downsample(imageData: imageData, to: thumbSize, scale: 1.0))
        }
    }

    func setUpImages() {
        let halfSize = CGSize(width: frontImage.size.width/2, height: frontImage.size.height/2)
        guard let frontImageData = frontImage.jpegData(compressionQuality: 1) else { return }
        guard let backImageData = backImage.jpegData(compressionQuality: 1) else { return }

        frontImage = imageHelper.downsample(imageData: frontImageData, to: halfSize, scale: 0.8)
        backImage = imageHelper.downsample(imageData: backImageData, to: halfSize, scale: 0.8)

        imageViewBack.image = backImage
        imageViewFront.image = frontImage
        originalFrontImage = frontImage
        originalBackImage = backImage

        imageViewFront.layer.borderColor = UIColor.red.cgColor
        imageViewFront.layer.borderWidth = 1.0
        imageViewBack.layer.borderColor = UIColor.clear.cgColor
        imageViewBack.layer.borderWidth = 0.0

        imageViewFront.contentMode = .scaleAspectFill
        imageViewBack.contentMode = .scaleAspectFill
    }

    func setUpModel() {
        model.filterView = filterView
        model.filterImage = frontImage
        model.imageViewBack = imageViewBack
        model.imageViewFront = imageViewFront
        model.filteredImageScrollView = filteredImageScrollView
        model.parentViewController = self
        model.createConstriants()
        model.layoutSubviews(vc: self)
    }
    
    // MARK: - rotation support
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    // MARK: - trait collections
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        model.layoutSubviews(vc: self)
    }

    // MARK: Filters
    func showFilteredImages(image: UIImage) {
        var currentX: Int = 5
        guard let originalCIImage = CIImage(image: image) else { return }
        let filters = [
           Filter(filterName: "CISepiaTone", displayName: "Sepia"),
           Filter(filterName: "CIColorInvert", displayName: "Invert"),
           Filter(filterName: "CIColorMonochrome", displayName: "Monochrome"),
           Filter(filterName: "CIColorPosterize", displayName: "Posterize"),
           Filter(filterName: "CIPhotoEffectInstant", displayName: "Instant"),
           Filter(filterName: "CIPhotoEffectFade", displayName: "Fade"),
           Filter(filterName: "CIPhotoEffectChrome", displayName: "Chrome"),
           Filter(filterName: "CIPhotoEffectMono", displayName: "Mono"),
           Filter(filterName: "CIPhotoEffectNoir", displayName: "Noir"),
           Filter(filterName: "CIPhotoEffectProcess", displayName: "Process"),
           Filter(filterName: "CIPhotoEffectTonal", displayName: "Tonal"),
           Filter(filterName: "CIPhotoEffectTransfer", displayName: "Transfer"),
           Filter(filterName: "CICircularScreen", displayName: "Circle"),
           Filter(filterName: "CIDotScreen", displayName: "Dot"),
           Filter(filterName: "CIDiscBlur", displayName: "Blur"),
           Filter(filterName: "CIComicEffect", displayName: "Comic"),
           Filter(filterName: "CIPixellate", displayName: "Pixel"),
           Filter(filterName: "CILineOverlay", displayName: "Line")
        ]

        for filter: Filter in filters {
            let filteredImage = filterHelper.applyFilter(image: originalCIImage, filterName: filter.filterName)
            let imageView = FilterImageView(frame: CGRect(x: currentX, y: 15, width: 90, height: 100))
            imageView.image = filteredImage
            imageView.isUserInteractionEnabled = true
            imageView.backgroundColor = .white
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterTapped)))
            imageView.filterDisplayName = filter.displayName
            imageView.filterName = filter.filterName
            filteredImageScrollView.addSubview(imageView)

            let label = UILabel(frame: CGRect(x: currentX, y: 0, width: 90, height: 15))
            label.text = filter.displayName
            label.textAlignment = .center
            label.textColor = .white
            filteredImageScrollView.addSubview(label)
            currentX += 105
        }
        filteredImageScrollView.contentSize = CGSize(width: currentX, height: 100)
    }

    @objc func filterTapped(_ sender: UITapGestureRecognizer) {
        guard let filterImageView = sender.view as? FilterImageView else { return }
        let filterName: String = filterImageView.filterDisplayName
        model.setUpFilterView(currentFilter: filterName)
    }

    // MARK: Interface Actions
    @IBAction func frontImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.red.cgColor
        imageViewFront.layer.borderWidth = 1.0
        imageViewBack.layer.borderColor = UIColor.clear.cgColor
        imageViewBack.layer.borderWidth = 0.0
        model.currentSelectedImage = .front
        model.filterImage = self.frontImage
        filterView.subviews.forEach { $0.removeFromSuperview() }
        model.setFilterImageForFilterView()
    }
    @IBAction func backImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.clear.cgColor
        imageViewFront.layer.borderWidth = 0.0
        imageViewBack.layer.borderColor = UIColor.red.cgColor
        imageViewBack.layer.borderWidth = 1.0
        model.currentSelectedImage = .back
        model.filterImage = self.backImage
        filterView.subviews.forEach { $0.removeFromSuperview() }
        model.setFilterImageForFilterView()
    }

    @IBAction func saveFilteredImage(_ sender: UIBarButtonItem) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let mergedImage = self.imageHelper.mergeFrontAndBackImagesPortrait(frontImage: self.frontImage, backImage: self.backImage)
                    guard let photoData = mergedImage.jpegData(compressionQuality: 1) else { return }
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    self.showUserToastMessage(message: "Image Saved to Camera Roll", duration: 4.5)
                })
            }
        }
    }

    @IBAction func resetImages(_ sender: UIBarButtonItem) {
        if model.currentSelectedImage == .front {
            self.imageViewFront.image = originalFrontImage
            self.frontImage = originalFrontImage
        } else if model.currentSelectedImage == .back {
            self.imageViewBack.image = originalBackImage
            self.backImage = originalBackImage
        }
    }
}

extension MergedViewController: FilterDelegate {
    func updateImage(image: UIImage) {
        DispatchQueue.main.async {
            if self.model.currentSelectedImage == .front {
                self.frontImage = image
                self.imageViewFront.image = self.frontImage
            } else if self.model.currentSelectedImage == .back {
                self.backImage = image
                self.imageViewBack.image = self.backImage
            }
        }
    }
}
