//
//  RulerLayer.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 22/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

class RulerLayer: CALayer {

    fileprivate var _rulerRange: RulerRange!
    var rulerRange: RulerRange {
        set(newRange) {
            _rulerRange = newRange
            if newRange.location > 0 {
                self.setNeedsDisplay()
            }
        }
        get {
            return _rulerRange
        }
    }
    var minorMark: RulerMark!
    var middleMark: RulerMark!
    var majorMark: RulerMark!

    let kDefaultFrequencyForMajorMark = 10.0
    let kDefaultFrequencyForMiddleMark = 5.0
    let kSideOffset = 30.0
    let kMiddleMarkSize = CGSize(width: 1, height: 15)
    let kMajorMarkSize = CGSize(width: 1, height: 30)

    override init() {
        super.init()
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        self.minorMark = RulerMark()
        self.minorMark.textColor = UIColor.clear
        self.middleMark = RulerMark()
        self.middleMark.frequency = kDefaultFrequencyForMiddleMark
        self.middleMark.size = kMiddleMarkSize
        self.majorMark = RulerMark()
        self.majorMark.frequency = kDefaultFrequencyForMajorMark
        self.majorMark.size = kMajorMarkSize
    }

    func setFrame(frame: CGRect) {
        if !frame.equalTo(self.frame) {
            self.frame = frame
        }
    }

    override func display() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.drawToImage()
        CATransaction.commit()
    }

    func drawToImage() {
        let numberOfLines = Int(ceil(Double(self.rulerRange.length) / self.minorMark.frequency))
        var numberOfLinesToZeroForMajor: Int = 0
        var numberOfLinesToZeroForMiddle: Int = 0
        if rulerRange.location >= 0 {
            numberOfLinesToZeroForMajor = Int(Double(self.rulerRange.location) / self.minorMark.frequency)
            numberOfLinesToZeroForMiddle = Int(Double(self.rulerRange.location) / self.minorMark.frequency)
        } else {
            let dbleLocation: Double = Double(self.rulerRange.location)
            numberOfLinesToZeroForMajor = Int(ceil( (dbleLocation * self.majorMark.frequency) + dbleLocation / self.minorMark.frequency))
            numberOfLinesToZeroForMiddle = Int(ceil( (dbleLocation * self.middleMark.frequency) + dbleLocation / self.minorMark.frequency))
        }
        let lineOffset = (Double(self.frame.size.width) - kSideOffset * 2) / Double(numberOfLines)
        var arrayWithTypeMarks: [RulerMark] = [RulerMark]()
        arrayWithTypeMarks.reserveCapacity(numberOfLines)

        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        let textMarkFormatter = NumberFormatter()
        textMarkFormatter.numberStyle = .decimal
        textMarkFormatter.maximumFractionDigits = 2

        for i in 0..<numberOfLines {
            arrayWithTypeMarks[i] = self.minorMark
            if Int(middleMark.frequency) != 0 {
                if ((i + numberOfLinesToZeroForMiddle) % Int(middleMark.frequency) == 0) {
                    arrayWithTypeMarks[i] = self.middleMark
                }
            }
            if Int(majorMark.frequency) != 0 {
                if ((i + numberOfLinesToZeroForMajor) % Int(majorMark.frequency) == 0) {
                    arrayWithTypeMarks[i] = self.majorMark
                }
            }
        }

        for i in 0..<numberOfLines {
            let dbleMinorMakrFreqCalc = minorMark.frequency * Double(i)
            let num = Double(self.rulerRange.location!) + dbleMinorMakrFreqCalc
            guard let numStr: String = textMarkFormatter.string(from: NSNumber(value: num)) else { return }
            let position: CGFloat = CGFloat(i) * CGFloat(lineOffset)
            drawMarkInContext(ctx: ctx, position: position, text: numStr, mark: arrayWithTypeMarks[i])
        }

        guard let imageToDraw: UIImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal) else { return }
        UIGraphicsEndImageContext()
        self.contents = imageToDraw.cgImage
    }


    func drawMarkInContext(ctx :CGContext, position: CGFloat, text: String, mark: RulerMark) {
        let attributes = [NSAttributedString.Key.font: mark.font, NSAttributedString.Key.foregroundColor: mark.textColor]
        let textSize: CGSize = text.size(withAttributes: attributes)

        let posistionOffset: CGFloat = position + CGFloat(kSideOffset)
        let rectX: CGFloat = posistionOffset - (mark.size.width / 2) + mark.offset.x
        var rectY: CGFloat!

        if mark.alignment == .center {
            rectY = (self.frame.size.height - mark.size.height) / 2
        }
        if mark.alignment == .bottom {
            rectY = self.frame.size.height - mark.size.height - textSize.height
        }
        if mark.alignment == .top {
            rectY = textSize.height
        }

        rectY += mark.offset.y
        let rect: CGRect  = CGRect(x: rectX,y: rectY,width: mark.size.width,height: mark.size.height)
        ctx.setFillColor(mark.color.cgColor)
        ctx.fill(rect)

        let textRectX: CGFloat = posistionOffset - textSize.width / 2 + mark.textOffset.x;
        var textRectY: CGFloat!
        if mark.textAlignment == .center {
            textRectY = self.frame.size.height - textSize.height / 2
        }
        if mark.textAlignment == .bottom {
            textRectY = self.frame.size.height - textSize.height
        }
        if mark.textAlignment == .top {
            textRectY = 0
        }
        textRectY += mark.textOffset.y
        let textRect: CGRect = CGRect(x: textRectX,y: textRectY,width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
    }
}
