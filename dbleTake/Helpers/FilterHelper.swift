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
        autoreleasepool {
            guard let filter: CIFilter = CIFilter(name: filterName) else { return UIImage(ciImage: image) }
            filter.setValue(image, forKey: kCIInputImageKey)
            let ciContext = CIContext()
            let cgImage = ciContext.createCGImage(filter.outputImage!, from: filter.outputImage!.extent)
            return UIImage(cgImage: cgImage!)
        }
    }

    func applySepiaFilter(image: CIImage, intensity: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CISepiaTone")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(intensity, forKey: kCIInputIntensityKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyPosterizeFilter(image: CIImage, inputLevel: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CIColorPosterize")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(inputLevel, forKey: "inputLevels")
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyCircleFilter(image: CIImage, inputWidth: CGFloat, center: CIVector, sharpness: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CICircularScreen")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(inputWidth, forKey: kCIInputWidthKey)
            filter?.setValue(center, forKey: kCIInputCenterKey)
            filter?.setValue(sharpness, forKey: kCIInputSharpnessKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyDotFilter(image: CIImage, inputWidth: CGFloat, center: CIVector, angle: CGFloat, sharpness: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CIDotScreen")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(inputWidth, forKey: kCIInputWidthKey)
            filter?.setValue(center, forKey: kCIInputCenterKey)
            filter?.setValue(angle, forKey: kCIInputAngleKey)
            filter?.setValue(sharpness, forKey: kCIInputSharpnessKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyBlurFilter(image: CIImage, radius: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CIDiscBlur")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(radius, forKey: kCIInputRadiusKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyPixelFilter(image: CIImage, inputScale: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CIPixellate")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(inputScale, forKey: kCIInputScaleKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }

    func applyMonochromeFilter(image: CIImage, inputColor: CIColor, inputIntensity: CGFloat) -> UIImage {
        autoreleasepool {
            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(image, forKey: kCIInputImageKey)
            filter?.setValue(inputColor, forKey: kCIInputColorKey)
            filter?.setValue(inputIntensity, forKey: kCIInputIntensityKey)
            guard let returnCIImage = filter?.outputImage else { return UIImage(ciImage: image) }
            return UIImage(ciImage: returnCIImage)
        }
    }
}
