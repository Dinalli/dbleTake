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

    enum SelectedImage {
        case front
        case back
    }

    var currentSelectedImage: SelectedImage = .front
    let filterHelper = FilterHelper()
    var frontImage: UIImage!
    var backImage: UIImage!
    var filterImage: UIImage!

    @IBOutlet weak var imageViewFront: UIImageView!
    @IBOutlet weak var imageViewBack: UIImageView!
    @IBOutlet weak var filteredImageScrollView: UIScrollView!
    @IBOutlet weak var filterView: UIView!

    fileprivate var currentFilter: String = "Sepia"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageViewBack.image = backImage
        imageViewFront.image = frontImage
        filterImage = frontImage
        
        imageViewFront.layer.borderColor = UIColor.red.cgColor
        imageViewFront.layer.borderWidth = 1.0
        imageViewBack.layer.borderColor = UIColor.clear.cgColor
        imageViewBack.layer.borderWidth = 0.0

        imageViewFront.contentMode = .scaleAspectFill
        imageViewBack.contentMode = .scaleAspectFill

        let newImage = mergeFrontAndBackImages()
        var thumbImage : UIImage
        let thumbSize = CGSize(width: 90, height: 100)
        UIGraphicsBeginImageContext(thumbSize)
        newImage.draw(in: CGRect(x: 0,y: 0, width: 90, height: 100))
        thumbImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        showFilteredImages(image: thumbImage)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpFilterView()
    }

    func showFilteredImages(image: UIImage) {
        var currentX: Int = 5
        guard let originalCIImage = CIImage(image: image) else { return }
        let filtersDict = ["CISepiaTone":"Sepia","CIColorMap":"ColorMap","CIColorMonochrome":"Monochrome","CIColorPosterize":"Posterize","CIPhotoEffectInstant":"Instant","CIPhotoEffectFade":"Fade","CIPhotoEffectChrome":"Chrome","CIPhotoEffectMono":"Mono","CIPhotoEffectNoir":"Noir","CIPhotoEffectTonal":"Tonal","CIPhotoEffectTransfer":"Transfer","CICircularScreen":"Circle","CIDotScreen":"Dot"]
        let filters = filtersDict.keys
        for filter in filters {
            let filteredImage = filterHelper.applyFilter(image: originalCIImage, filterName: filter)
            let imageView = UIImageView(frame: CGRect(x: currentX, y: 15, width: 90, height: 100))
            imageView.image = filteredImage
            filteredImageScrollView.addSubview(imageView)

            let filterName = filtersDict[filter]
            let label = UILabel(frame: CGRect(x: currentX, y: 0, width: 90, height: 15))
            label.text = filterName
            label.textAlignment = .center
            label.textColor = .white
            filteredImageScrollView.addSubview(label)
            currentX += 105
        }
        filteredImageScrollView.contentSize = CGSize(width: currentX, height: 100)
    }

    func setUpFilterView() {
        switch currentFilter {
        case "none":
            break
        case "Sepia":
            setUpSepiaFilter()
        default:
            setUpSepiaFilter()
        }
    }

    func setUpSepiaFilter() {
        let sepiaView = SepiaFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        sepiaView.originalImage = filterImage
        sepiaView.delegate = self
        sepiaView.intensity = 1.0
        sepiaView.setUpFilter()
        self.filterView.addSubview(sepiaView)
    }

    @IBAction func frontImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.red.cgColor
        imageViewFront.layer.borderWidth = 1.0
        imageViewBack.layer.borderColor = UIColor.clear.cgColor
        imageViewBack.layer.borderWidth = 0.0
        currentSelectedImage = .front
        filterImage = self.frontImage
    }
    @IBAction func backImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.clear.cgColor
        imageViewFront.layer.borderWidth = 0.0
        imageViewBack.layer.borderColor = UIColor.red.cgColor
        imageViewBack.layer.borderWidth = 1.0
        currentSelectedImage = .back
        filterImage = self.backImage
    }

    @IBAction func saveFilteredImage(_ sender: UIBarButtonItem) {
        //let imageToSave =
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let mergedImage = self.mergeFrontAndBackImages()
                    guard let photoData = mergedImage.jpegData(compressionQuality: 1) else { return }
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    self.showUserToastMessage(message: "Image Saved to Camera Roll", duration: 1.5)
                })
            }
        }
    }

    func mergeFrontAndBackImages() -> UIImage {
        let size = CGSize(width: frontImage!.size.width + backImage!.size.width , height: frontImage!.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        frontImage!.draw(in: CGRect(x: 0, y: 0, width: frontImage!.size.width, height: size.height))
        backImage!.draw(in: CGRect(x: frontImage!.size.width, y: 0, width: backImage!.size.width, height: size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension MergedViewController: FilterDelegate {
    func updateImage(image: UIImage) {
        DispatchQueue.main.async {
            if self.currentSelectedImage == .front {
                self.imageViewFront.image = image
            } else if self.currentSelectedImage == .back {
                self.imageViewBack.image = image
            }
        }
    }
}
