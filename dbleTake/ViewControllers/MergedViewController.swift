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

    struct Filter {
        let filterName: String
        let displayName: String
        var description: String { return displayName }
    }

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
           Filter(filterName: "CIPhotoEffectFade", displayName: "Sepia"),
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
        print(filterName)
        setUpFilterView(currentFilter: filterName)
    }

    func setUpFilterView(currentFilter: String) {
        self.filterView.subviews.forEach { $0.removeFromSuperview() }
        switch currentFilter {
            case "none":
                break
            case "Sepia":
                setUpSepiaFilter()
            case "Invert":
                applyBaisicFilter(filter: "CIColorInvert")
            case "Monochrome":
                setUpMonochromeFilter()
            case "Instant":
                applyBaisicFilter(filter: "CIPhotoEffectInstant")
            case "Posterize":
                setUpPosterizeFilter()
            case "Fade":
                applyBaisicFilter(filter: "CIPhotoEffectFade")
            case "Chrome":
                applyBaisicFilter(filter: "CIPhotoEffectChrome")
            case "Mono":
                applyBaisicFilter(filter: "CIPhotoEffectMono")
            case "Noir":
                applyBaisicFilter(filter: "CIPhotoEffectNoir")
            case "Process":
                applyBaisicFilter(filter: "CIPhotoEffectProcess")
            case "Tonal":
                applyBaisicFilter(filter: "CIPhotoEffectTonal")
            case "Transfer":
                applyBaisicFilter(filter: "CIPhotoEffectTransfer")
            case "Circle":
                setUpCircleFilter()
            case "Dot":
                setUpDotFilter()
            case "Blur":
                setUpBlurFilter()
            case "Comic":
                applyBaisicFilter(filter: "CIComicEffect")
            case "Pixel":
                setUpPixelFilter()
            case "Line":
                applyBaisicFilter(filter: "CILineOverlay")
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

    func setUpMonochromeFilter() {
        let monochromeView = MonochromeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        monochromeView.originalImage = imageFromContextImage(image: filterImage)
        monochromeView.delegate = self
        monochromeView.setUpFilter()
        self.filterView.addSubview(monochromeView)
    }

    func setUpPosterizeFilter() {
        let posterizeView = PosterizeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        posterizeView.originalImage = imageFromContextImage(image: filterImage)
        posterizeView.delegate = self
        posterizeView.inputLevel = 6.0
        posterizeView.setUpFilter()
        self.filterView.addSubview(posterizeView)
    }

    func setUpCircleFilter() {
        let circleView = CircleFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        circleView.originalImage = imageFromContextImage(image: filterImage)
        circleView.delegate = self
        circleView.setUpFilter()
        self.filterView.addSubview(circleView)
    }

    func setUpDotFilter() {
        let dotView = DotFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        dotView.originalImage = imageFromContextImage(image: filterImage)
        dotView.delegate = self
        dotView.setUpFilter()
        self.filterView.addSubview(dotView)
    }

    func setUpBlurFilter() {
        let blurView = BlurFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        blurView.originalImage = imageFromContextImage(image: filterImage)
        blurView.delegate = self
        blurView.setUpFilter()
        self.filterView.addSubview(blurView)
    }

    func setUpPixelFilter() {
        let pixelView = PixelFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        pixelView.originalImage = imageFromContextImage(image: filterImage)
        pixelView.delegate = self
        pixelView.setUpFilter()
        self.filterView.addSubview(pixelView)
    }

    func applyBaisicFilter(filter: String) {
        guard let originalCIImage = CIImage(image: filterImage) else { return }
        let filteredImage = filterHelper.applyFilter(image: originalCIImage, filterName: filter)
        if self.currentSelectedImage == .front {
            self.imageViewFront.image = filteredImage
        } else if self.currentSelectedImage == .back {
            self.imageViewBack.image = filteredImage
        }
    }

    func setFilterImageForFilterView() {
        for filterView in self.filterView.subviews {
            if filterView.isKind(of: FilterBaseView.self) {
                guard let filterView = filterView as? FilterBaseView else { return }
                filterView.originalImage = imageFromContextImage(image: filterImage)
                filterView.setUpFilter()
            }
        }
    }

    // MARK: Interface Actions

    @IBAction func frontImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.red.cgColor
        imageViewFront.layer.borderWidth = 1.0
        imageViewBack.layer.borderColor = UIColor.clear.cgColor
        imageViewBack.layer.borderWidth = 0.0
        currentSelectedImage = .front
        filterImage = self.frontImage
        setFilterImageForFilterView()
    }
    @IBAction func backImageTapped(_ sender: UITapGestureRecognizer) {
        imageViewFront.layer.borderColor = UIColor.clear.cgColor
        imageViewFront.layer.borderWidth = 0.0
        imageViewBack.layer.borderColor = UIColor.red.cgColor
        imageViewBack.layer.borderWidth = 1.0
        currentSelectedImage = .back
        filterImage = self.backImage
        setFilterImageForFilterView()
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

    // MARK: Image manipulation
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
