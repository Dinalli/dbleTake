//
//  ImageHelper.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 28/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class ImageHelper: NSObject {
    func imageFromContextImage(image: UIImage) -> UIImage {
        autoreleasepool {
            let size = CGSize(width: image.size.width , height: image.size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: size.height))
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
    }

    // Downsampling large images for display at smaller size
    func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =  [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage =   CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }

    func mergeFrontAndBackImagesPortrait(frontImage: UIImage, backImage: UIImage) -> UIImage {
        autoreleasepool {
            let size = CGSize(width: frontImage.size.width + backImage.size.width , height: frontImage.size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            frontImage.draw(in: CGRect(x: 0, y: 0, width: size.width/2, height: size.height))
            backImage.draw(in: CGRect(x: size.width/2, y: 0, width: size.width/2, height: size.height))
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
    }

    func mergeFrontAndBackImagesLandscape(frontImage: UIImage, backImage: UIImage) -> UIImage {
        autoreleasepool {
            let size = CGSize(width: frontImage.size.width + backImage.size.width , height: frontImage.size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            frontImage.draw(in: CGRect(x: 0, y: 0, width: frontImage.size.width, height: size.height))
            backImage.draw(in: CGRect(x: frontImage.size.width, y: 0, width: backImage.size.width, height: size.height))
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
    }
}
