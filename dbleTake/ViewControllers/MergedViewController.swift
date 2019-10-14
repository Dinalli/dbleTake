//
//  MergedViewController.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 07/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class MergedViewController: UIViewController {

    let filterHelper = FilterHelper()

    var frontImage: UIImage!
    var backImage: UIImage!

    @IBOutlet weak var imageViewFront: UIImageView!
    @IBOutlet weak var imageViewBack: UIImageView!
    @IBOutlet weak var filteredImageScrollView: UIScrollView!
    @IBOutlet weak var horizontalScroll: HorizontalNumberScrollView!
    @IBOutlet weak var circleTracker: CircularTrackingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageViewBack.image = backImage
        imageViewFront.image = frontImage

        imageViewFront.contentMode = .scaleAspectFill
        imageViewBack.contentMode = .scaleAspectFill

        let size = CGSize(width: frontImage!.size.width + backImage!.size.width , height: frontImage!.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        frontImage!.draw(in: CGRect(x: 0, y: 0, width: frontImage!.size.width, height: size.height))
        backImage!.draw(in: CGRect(x: frontImage!.size.width, y: 0, width: backImage!.size.width, height: size.height))

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

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
        setUpCircleView()
        setUpHorizontalView()
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

    func setUpCircleView() {
        circleTracker.percent = 65
        circleTracker.numberToShow = 65
        circleTracker.drawOverlayCircle()
    }

    func setUpHorizontalView() {
        horizontalScroll.backColor = .clear
        horizontalScroll.numberColor = UIColor.cyan
    }
}
