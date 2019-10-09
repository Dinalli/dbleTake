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

    func showFilteredImages(image: UIImage) {
        var currentX: Int = 5
        guard let originalCIImage = CIImage(image: image) else { return }
        let filters = ["CISepiaTone","CIColorMap","CIColorMonochrome","CIColorPosterize","CIPhotoEffectInstant","CIPhotoEffectFade","CIPhotoEffectChrome","CIPhotoEffectMono","CIPhotoEffectNoir","CIPhotoEffectTonal","CIPhotoEffectTransfer","CICircularScreen","CIDotScreen"]
        for filter in filters {
            let filteredImage = filterHelper.applyFilter(image: originalCIImage, filterName: filter)
            let imageView = UIImageView(frame: CGRect(x: currentX, y: 5, width: 90, height: 100))
            imageView.image = filteredImage
            filteredImageScrollView.addSubview(imageView)
            currentX += 105
        }
        filteredImageScrollView.contentSize = CGSize(width: currentX, height: 100)
    }
}
