//
//  FilterHelper.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 09/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit
import CoreImage

class FilterHelper: NSObject {

    // Apply Filter to Image and return filtered Image
    let context = CIContext()

    func applyFilter(image: CIImage, filterName: String) -> UIImage {
        let filter = CIFilter(name: filterName)
        filter?.setValue(image, forKey: kCIInputImageKey)
        guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
        return UIImage(ciImage: returnCIImage)
    }

    func applySepiaFilter(image: CIImage, intensity: CGFloat) -> UIImage {
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputIntensityKey)
        guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
        return UIImage(ciImage: returnCIImage)
    }

    func applyPosterizeFilter(image: CIImage, inputLevel: CGFloat) -> UIImage {
        let filter = CIFilter(name: "CICIColorPosterize")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(inputLevel, forKey: kCIInputScaleKey)
        guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
        return UIImage(ciImage: returnCIImage)
    }

    func applyCircleFilter(image: CIImage, inputLevel: CGFloat) -> UIImage {
        let filter = CIFilter(name: "CICIColorPosterize")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(inputLevel, forKey: kCIInputScaleKey)
        guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
        return UIImage(ciImage: returnCIImage)
    }
}
