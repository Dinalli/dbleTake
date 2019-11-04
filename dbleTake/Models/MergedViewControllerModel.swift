//
//  MergedViewControllerModel.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 28/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class MergedViewControllerModel: NSObject {

    let imageHelper = ImageHelper()
    let filterHelper = FilterHelper()

    var imageCaptureOrientation: ImageCaptureOrientation!
    var portraitCaptureConstraints: [NSLayoutConstraint]!
    var landscapeCaptureConstraints: [NSLayoutConstraint]!

    var parentViewController: MergedViewController!

    var filterImage: UIImage!

    var imageViewFront: UIImageView!
    var imageViewBack: UIImageView!
    var filteredImageScrollView: UIScrollView!
    var filterView: UIView!

    enum SelectedImage {
        case front
        case back
    }

    var currentSelectedImage: SelectedImage = .front

    func createConstriants() {
        guard let view = parentViewController.view else { return }
        imageViewFront.translatesAutoresizingMaskIntoConstraints = false
        imageViewBack.translatesAutoresizingMaskIntoConstraints = false
        filteredImageScrollView.translatesAutoresizingMaskIntoConstraints = false
        filterView.translatesAutoresizingMaskIntoConstraints = false

        portraitCaptureConstraints = [
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .bottom, relatedBy: .equal, toItem: filteredImageScrollView, attribute: .top, multiplier: 1, constant: -10),

            NSLayoutConstraint(item: imageViewBack as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewBack as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewBack as Any, attribute: .bottom, relatedBy: .equal, toItem: filteredImageScrollView, attribute: .top, multiplier: 1, constant: -10),

            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 130),

            NSLayoutConstraint(item: filterView as Any, attribute: .top, relatedBy: .equal, toItem: filteredImageScrollView, attribute: .bottom, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: filterView as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filterView as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filterView as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filterView as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 260)
        ]

        landscapeCaptureConstraints = [
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .leftMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageViewFront as Any, attribute: .bottom, relatedBy: .equal, toItem: imageViewBack, attribute: .top, multiplier: 1, constant: 1),

            NSLayoutConstraint(item: imageViewBack as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .leftMargin, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: imageViewBack as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .left, relatedBy: .equal, toItem: imageViewBack, attribute: .right, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .rightMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filteredImageScrollView as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: 130),

            NSLayoutConstraint(item: filterView as Any, attribute: .top, relatedBy: .equal, toItem: filteredImageScrollView, attribute: .bottom, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: filterView as Any, attribute: .left, relatedBy: .equal, toItem: imageViewBack, attribute: .right, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: filterView as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .rightMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: filterView as Any, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        ]

        if parentViewController.traitCollection.verticalSizeClass == .regular {
            portraitCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.width/2))
            portraitCaptureConstraints.append(NSLayoutConstraint(item: imageViewBack as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.width/2))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewBack as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.height/2-20))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.height/2-20))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: view.frame.width/2-20))
            NSLayoutConstraint.activate(portraitCaptureConstraints)
        }
        else {
            portraitCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.height/2))
            portraitCaptureConstraints.append(NSLayoutConstraint(item: imageViewBack as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.height/2))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewBack as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.width/2-20))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0, constant: view.frame.width/2-20))
            landscapeCaptureConstraints.append(NSLayoutConstraint(item: imageViewFront as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0, constant: view.frame.height/2-20))
            NSLayoutConstraint.activate(landscapeCaptureConstraints)
        }
    }

    func layoutSubviews(vc: UIViewController) {
        NSLayoutConstraint.deactivate(landscapeCaptureConstraints + portraitCaptureConstraints)
        if vc.traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(portraitCaptureConstraints)
        }
        else {
            NSLayoutConstraint.activate(landscapeCaptureConstraints)
        }
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
        let sepiaView = SepiaFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: 0))
        sepiaView.originalImage = filterImage
        sepiaView.delegate = parentViewController
        sepiaView.intensity = 1.0
        sepiaView.setUpFilter()
        self.filterView.addSubview(sepiaView)
        sepiaView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: sepiaView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: sepiaView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: sepiaView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: sepiaView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpMonochromeFilter() {
        let monochromeView = MonochromeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        monochromeView.originalImage = filterImage
        monochromeView.delegate = parentViewController
        monochromeView.setUpFilter()
        self.filterView.addSubview(monochromeView)
        monochromeView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: monochromeView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: monochromeView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: monochromeView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: monochromeView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpPosterizeFilter() {
        let posterizeView = PosterizeFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        posterizeView.originalImage = filterImage
        posterizeView.delegate = parentViewController
        posterizeView.inputLevel = 6.0
        posterizeView.setUpFilter()
        self.filterView.addSubview(posterizeView)
        posterizeView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: posterizeView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: posterizeView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: posterizeView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: posterizeView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpCircleFilter() {
        let circleView = CircleFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        circleView.originalImage = filterImage
        circleView.inputCenter = CIVector(x: filterImage.size.width/2, y: filterImage.size.height/2)
        circleView.delegate = parentViewController
        circleView.setUpFilter()
        self.filterView.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: circleView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: circleView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: circleView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: circleView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpDotFilter() {
        let dotView = DotFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        dotView.originalImage = filterImage
        dotView.inputCenter = CIVector(x: filterImage.size.width/2, y: filterImage.size.height/2)
        dotView.delegate = parentViewController
        dotView.setUpFilter()
        self.filterView.addSubview(dotView)
        dotView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: dotView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: dotView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: dotView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: dotView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpBlurFilter() {
        let blurView = BlurFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        blurView.originalImage = filterImage
        blurView.delegate = parentViewController
        blurView.setUpFilter()
        self.filterView.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: blurView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: blurView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: blurView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: blurView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func setUpPixelFilter() {
        let pixelView = PixelFilterView(frame: CGRect(x: 0, y: 0, width: self.filterView.frame.size.width, height: self.filterView.frame.size.height))
        pixelView.originalImage = filterImage
        pixelView.delegate = parentViewController
        pixelView.setUpFilter()
        self.filterView.addSubview(pixelView)
        pixelView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addConstraints([
        NSLayoutConstraint(item: pixelView as Any, attribute: .top, relatedBy: .equal, toItem: filterView, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: pixelView as Any, attribute: .left, relatedBy: .equal, toItem: filterView, attribute: .left, multiplier: 1, constant: 8),
        NSLayoutConstraint(item: pixelView as Any, attribute: .right, relatedBy: .equal, toItem: filterView, attribute: .right, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: pixelView as Any, attribute: .bottom, relatedBy: .equal, toItem: filterView, attribute: .bottom, multiplier: 1, constant: 0)])
    }

    func applyBaisicFilter(filter: String) {
        //let filterImage = imageHelper.imageFromContextImage(image: self.filterImage)
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
                filterView.originalImage = filterImage
                filterView.setUpFilter()
            }
        }
    }
}
