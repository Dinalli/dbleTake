//
//  Extension.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 07/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import Foundation
import UIKit

enum ImageCaptureOrientation {
    case portrait
    case landscape
}

extension UIImage {

    func blendImages(_ img: UIImage,_ imgTwo: UIImage) -> Data? {
        let bottomImage = img
        let topImage = imgTwo

        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 306, height: 306))
        let imgView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 306, height: 306))

        // - Set Content mode to what you desire
        imgView.contentMode = .scaleAspectFill
        imgView2.contentMode = .scaleAspectFit

        // - Set Images
        imgView.image = bottomImage
        imgView2.image = topImage

        // - Create UIView
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 306, height: 306))
        contentView.addSubview(imgView)
        contentView.addSubview(imgView2)

        // - Set Size
        let size = CGSize(width: 306, height: 306)

        // - Where the magic happens
        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        contentView.drawHierarchy(in: contentView.bounds, afterScreenUpdates: true)

        guard let i = UIGraphicsGetImageFromCurrentImageContext(),
            let data = i.jpegData(compressionQuality: 1.0)
            else {return nil}

        UIGraphicsEndImageContext()

        return data
    }
}

extension UIViewController {
    /// Shows a toast message to the user with a custom duration
    func showUserToastMessage(message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont(name: "Roboto", size: 18.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds  =  true
            var toastHeight = toastLabel.intrinsicContentSize.height
            var toastWidth = toastLabel.intrinsicContentSize.width + 20
            if toastWidth > self.view.frame.width {
                toastHeight *= 2
                toastWidth = self.view.frame.width-20
                toastLabel.numberOfLines = 0
            }
            toastLabel.frame = CGRect(x: 0, y: self.view.frame.height - 240, width: toastWidth, height: toastHeight + 20)
            toastLabel.center.x = self.view.center.x
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(_ ) in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
