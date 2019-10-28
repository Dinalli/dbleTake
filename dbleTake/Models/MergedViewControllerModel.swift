//
//  MergedViewControllerModel.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 28/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class MergedViewControllerModel: NSObject {

    var filterView: UIView!
    let imageHelper = ImageHelper()
    let filterHelper = FilterHelper()

    var viewControllerForDelegate: MergedViewController!

    var filterImage: UIImage!

    var imageViewFront: UIImageView!
    var imageViewBack: UIImageView!

    enum SelectedImage {
        case front
        case back
    }

    var currentSelectedImage: SelectedImage = .front
    
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
        sepiaView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        sepiaView.delegate = viewControllerForDelegate
        sepiaView.intensity = 1.0
        sepiaView.setUpFilter()
        self.filterView.addSubview(sepiaView)
    }

    func setUpMonochromeFilter() {
        let monochromeView = MonochromeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        monochromeView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        monochromeView.delegate = viewControllerForDelegate
        monochromeView.setUpFilter()
        self.filterView.addSubview(monochromeView)
    }

    func setUpPosterizeFilter() {
        let posterizeView = PosterizeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        posterizeView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        posterizeView.delegate = viewControllerForDelegate
        posterizeView.inputLevel = 6.0
        posterizeView.setUpFilter()
        self.filterView.addSubview(posterizeView)
    }

    func setUpCircleFilter() {
        let circleView = CircleFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        circleView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        circleView.inputCenter = CIVector(x: filterImage.size.width/2, y: filterImage.size.height/2)
        circleView.delegate = viewControllerForDelegate
        circleView.setUpFilter()
        self.filterView.addSubview(circleView)
    }

    func setUpDotFilter() {
        let dotView = DotFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        dotView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        dotView.inputCenter = CIVector(x: filterImage.size.width/2, y: filterImage.size.height/2)
        dotView.delegate = viewControllerForDelegate
        dotView.setUpFilter()
        self.filterView.addSubview(dotView)
    }

    func setUpBlurFilter() {
        let blurView = BlurFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        blurView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        blurView.delegate = viewControllerForDelegate
        blurView.setUpFilter()
        self.filterView.addSubview(blurView)
    }

    func setUpPixelFilter() {
        let pixelView = PixelFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        pixelView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
        pixelView.delegate = viewControllerForDelegate
        pixelView.setUpFilter()
        self.filterView.addSubview(pixelView)
    }

    func applyBaisicFilter(filter: String) {
        let filterImage = imageHelper.imageFromContextImage(image: self.filterImage)
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
                filterView.originalImage = imageHelper.imageFromContextImage(image: filterImage)
                filterView.setUpFilter()
            }
        }
    }
}
