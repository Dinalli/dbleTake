//
//  RulerMark.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 22/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class RulerMark: NSObject {

    enum MarkAlignment {
        case bottom
        case center
        case top
    }

    var frequency = 1.0                                     // default frequency for minor mark
    var size = CGSize(width:1.0, height:2.0)                     // default size for minor lines mark
    var color = UIColor.black                    // default color set in RullerControl (is Tint Color)
    var font = UIFont.systemFont(ofSize: 12, weight: .medium)  // default font for all text mark
    var textColor = UIColor.black                 // default color set in RullerControl (is Tint Color)
    var alignment: MarkAlignment = .bottom
    var textAlignment = MarkAlignment.bottom
    var offset = CGPoint.zero
    var textOffset = CGPoint.zero
}
