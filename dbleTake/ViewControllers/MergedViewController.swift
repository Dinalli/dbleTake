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

        var thumbImage : UIImage
        let newImage = mergeFrontAndBackImages()
        let thumbSize = CGSize(width: 90, height: 100)
        UIGraphicsBeginImageContext(thumbSize)
        newImage.draw(in: CGRect(x: 0,y: 0, width: 90, height: 100))
        thumbImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        showFilteredImages(image: thumbImage)
    }

    func showFilteredImages(image: UIImage) {
        var currentX: Int = 5
        guard let originalCIImage = CIImage(image: image) else { return }
        let filtersDict = ["CISepiaTone":"Sepia","CIColorMap":"ColorMap","CIColorMonochrome":"Monochrome","CIColorPosterize":"Posterize","CIPhotoEffectInstant":"Instant","CIPhotoEffectFade":"Fade","CIPhotoEffectChrome":"Chrome","CIPhotoEffectMono":"Mono","CIPhotoEffectNoir":"Noir","CIPhotoEffectTonal":"Tonal","CIPhotoEffectTransfer":"Transfer","CICircularScreen":"Circle","CIDotScreen":"Dot"]
        let filters = filtersDict.keys
        for filter in filters {
            let filterName = filtersDict[filter]
            let filteredImage = filterHelper.applyFilter(image: originalCIImage, filterName: filter)
            let imageView = FilterImageView(frame: CGRect(x: currentX, y: 15, width: 90, height: 100))
            imageView.image = filteredImage
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterTapped)))
            imageView.filterDisplayName = filterName
            imageView.filterName = filter
            filteredImageScrollView.addSubview(imageView)

            let label = UILabel(frame: CGRect(x: currentX, y: 0, width: 90, height: 15))
            label.text = filterName
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
        print(filterName)
        setUpFilterView(currentFilter: filterName)
    }

    func setUpFilterView(currentFilter: String) {
        switch currentFilter {
            case "none":
                break
            case "Sepia":
                setUpSepiaFilter()
            case "ColorMap":
                setUpSepiaFilter()
            case "Monochrome":
                setUpSepiaFilter()
            case "Instant":
                setUpSepiaFilter()
            case "Posterize":
                setUpSepiaFilter()
            case "Fade":
                setUpSepiaFilter()
            case "Chrome":
                setUpSepiaFilter()
            case "Mono":
                setUpSepiaFilter()
            case "Noir":
                setUpSepiaFilter()
            case "Tonal":
                setUpSepiaFilter()
            case "Transfer":
                setUpSepiaFilter()
            case "Circle":
                setUpSepiaFilter()
            case "Dot":
                setUpSepiaFilter()
        default:
            break
        }
    }

    func setUpSepiaFilter() {
        let sepiaView = SepiaFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        sepiaView.originalImage = imageFromContextImage(image: filterImage)
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
                    self.showUserToastMessage(message: "Image Saved to Camera Roll", duration: 2.5)
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

    func imageFromContextImage(image: UIImage) -> UIImage {
        let size = CGSize(width: image.size.width , height: image.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: size.height))
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
