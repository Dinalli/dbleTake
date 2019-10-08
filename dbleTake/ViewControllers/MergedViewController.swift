//
//  MergedViewController.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 07/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class MergedViewController: UIViewController {

    var frontImage: UIImage!
    var backImage: UIImage!
    
    @IBOutlet weak var mergedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mergedImage = UIImage(data: blendImages(frontImage, backImage)!)
        mergedImageView.image = mergedImage
    }

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
