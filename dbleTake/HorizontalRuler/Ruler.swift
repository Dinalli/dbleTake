//
//  Ruler.swift
//  dbleTake
//
//  Created by Andrew Donnelly on 22/10/2019.
//  Copyright © 2019 dinalli. All rights reserved.
//

import UIKit

@IBDesignable class Ruler: UIControl {

    struct RulerMarkType: OptionSet {
        let rawValue: Int
        static let RulerMarkTypeMajor               = RulerMarkType(rawValue: 1 << 0)
        static let RulerMarkTypeMiddle              = RulerMarkType(rawValue: 1 << 1)
        static let RulerMarkTypeMinor               = RulerMarkType(rawValue: 1 << 2)
        static let RulerMarkTypeAll: RulerMarkType  = [.RulerMarkTypeMajor, .RulerMarkTypeMiddle, .RulerMarkTypeMinor]
    }

    let kDefaultRulerWidth: CGFloat = 500
    let kDefaultRangeFrom: CGFloat = -10
    let kDefaultRangeLength: CGFloat = 20.0
    let kSideOffset: CGFloat = 30.0
    let kPointerImageViewSize: CGSize = CGSize(width: 2, height: 30)

    @IBInspectable var rangeFrom: CGFloat = 0.0
    @IBInspectable var rangeLength: CGFloat = 0.0
    @IBInspectable var rulerWidth: CGFloat  = 0.0
    @IBInspectable var spacingBetweenMarks: CGFloat = 0.0
    @IBInspectable var currentValue: CGFloat = 0.0

    var rulerRange: RulerRange!
    var rulerLayer: RulerLayer!
    var scrollView: UIScrollView!
    var pointerImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpDefaultValues()
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUpDefaultValues()
        self.commonInit()
    }

    func setUpDefaultValues() {
        rangeFrom = kDefaultRangeFrom
        rangeLength = kDefaultRangeLength
        rulerWidth = kDefaultRulerWidth
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if spacingBetweenMarks > 0 {
            self.rulerWidth = spacingBetweenMarks * rangeLength
        }
        self.commonInit()
    }

    func commonInit() {
        self.setupScrollView()
        self.setupRulerLayer()
        self.setupPointerImage()
    }

    func setupScrollView() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = true
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.delegate = self
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)
    }

    func setupRulerLayer() {
        var range = RulerRange()
        range.location = self.rangeFrom
        range.length =  self.rangeLength
        self.rulerRange = range
        self.rulerLayer = RulerLayer()
        self.rulerLayer.rulerRange = self.rulerRange
        self.rulerLayer.backgroundColor = UIColor.clear.cgColor
        self.setColor(color: self.tintColor, markType: .RulerMarkTypeAll)
        self.setTextColor(color: self.tintColor, markType: [.RulerMarkTypeMiddle, .RulerMarkTypeMajor])
        self.scrollView.layer .addSublayer(self.rulerLayer)
    }

    func setColor(color: UIColor, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.color = color;
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.middleMark.color = color;
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.color = color;
        }
        self.rulerLayer.setNeedsDisplay()
    }


    func setTextColor(color: UIColor, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.textColor = color;
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.middleMark.textColor = color;
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.textColor = color;
        }
        self.rulerLayer.setNeedsDisplay()
    }

    func setupPointerImage() {
        self.pointerImageView = UIImageView()
        self.pointerImageView.backgroundColor = self.tintColor
        self.addSubview(self.pointerImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let sideInset = self.scrollView.frame.width / 2.0
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset - kSideOffset, bottom: 0, right: sideInset - kSideOffset)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.rulerLayer.frame = self.frameForRulerLayer()
        CATransaction.commit()
        self.scrollView.contentSize = CGSize(width: self.rulerWidth, height: self.frame.size.height)
        self.scrollView.contentOffset = self.contentOffsetForValue(value: self.currentValue)
        self.pointerImageView.frame = self.frameForPointerImageView()
    }

    func frameForPointerImageView() -> CGRect {
        let pointerImageViewOriginX: CGFloat = (self.frame.size.width - kPointerImageViewSize.width) / 2
        let pointerImageViewOriginY: CGFloat = (self.frame.size.height - kPointerImageViewSize.height) / 2
        let rulerCenterViewRect: CGRect = CGRect(x: pointerImageViewOriginX, y:pointerImageViewOriginY,
                                                 width: kPointerImageViewSize.width, height: kPointerImageViewSize.height/2)
        return rulerCenterViewRect;
    }

    func frameForRulerLayer() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.rulerWidth, height: self.frame.size.height)
    }

    func contentOffsetForValue(value: CGFloat) -> CGPoint {
        let contentOffsetY: CGFloat = (value - self.rulerRange.location) * self.offsetCoefficient() - self.scrollView.contentInset.left
        return CGPoint(x: contentOffsetY, y: self.scrollView.contentOffset.y)
    }

    func valueForContentOffset(contentOffset: CGPoint) -> CGFloat {
        return self.rulerRange.location + (contentOffset.x + self.scrollView.contentInset.left) / self.offsetCoefficient()
    }

    func offsetCoefficient() -> CGFloat {
        return (self.scrollView.contentSize.width - kSideOffset * 2) / self.rulerRange.length
    }

    override func tintColorDidChange() {
        self.setColor(color: self.tintColor, markType: .RulerMarkTypeAll)
        self.setTextColor(color: self.tintColor, markType: [.RulerMarkTypeMiddle, .RulerMarkTypeMajor])
        self.pointerImageView.backgroundColor = self.tintColor
    }

    func setRangeFromAndLength(rangeFrom: CGFloat, rangeLength: CGFloat) {
        self.rangeFrom = rangeFrom
        self.rangeLength = rangeLength
        self.setRange()
    }

    func setRange() {
        var range = RulerRange()
        range.location = self.rangeFrom
        range.length =  self.rangeLength
        self.rulerRange = range
        self.rulerLayer.rulerRange = range;
        self.rulerLayer.setNeedsDisplay()
    }

    func setSpacingBetweenMarks(spacingBetweenMarks: CGFloat) {
        self.spacingBetweenMarks = spacingBetweenMarks;
        if self.spacingBetweenMarks >= 1  {
            let calcRulerLen: CGFloat = self.spacingBetweenMarks * self.rangeLength
            if (self.rulerLayer.minorMark.frequency > 0) {
                self.rulerWidth = calcRulerLen / CGFloat(self.rulerLayer.minorMark.frequency)
            } else {
                self.rulerWidth = calcRulerLen
            }
        }
    }

    func setRulerWidth(rulerWidth: CGFloat) {
        if ((self.rulerWidth != rulerWidth) && (rulerWidth <= 7000) && (rulerWidth > 0)) {
            self.rulerWidth = rulerWidth
            self.setNeedsLayout()
        }
    }

    func setValue(value: CGFloat) {
        self.setValue(value: value, animated: false)
    }

    func setValue(value: CGFloat, animated: Bool) {
        self.currentValue = value
        self.scrollView.contentOffset = self.contentOffsetForValue(value: self.currentValue)
    }

//    #pragma mark - Change mark type method
    func setSize(size: CGSize,markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.size = size
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.size = size
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.size = size
        }
        self.rulerLayer.setNeedsDisplay()
    }

    func setFont(font: UIFont, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.font = font
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.font = font
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.font = font
        }
        self.rulerLayer.setNeedsDisplay()
    }
//
//    - (void)setFrequency:(CGFloat)frequency forMarkType:(CRRulerMarkType)markType {
//        if (markType & CRRulerMarkTypeMajor) {
//            if (self.rulerLayer.minorMark.frequency < frequency) {
//                self.rulerLayer.majorMark.frequency = frequency / [NSNumber numberWithFloat:self.rulerLayer.minorMark.frequency].floatValue;
//            } else {
//                self.rulerLayer.majorMark.frequency = 0;
//            }
//        }
//        if (markType & CRRulerMarkTypeMiddle) {
//            if (self.rulerLayer.minorMark.frequency < frequency) {
//                self.rulerLayer.middleMark.frequency = frequency / [NSNumber numberWithFloat:self.rulerLayer.minorMark.frequency].floatValue;
//            } else {
//                self.rulerLayer.middleMark.frequency = 0;
//            }
//        }
//        if ((markType & CRRulerMarkTypeMinor) && (frequency > 0)) {
//            if ((_spacingBetweenMarks > 0 ) || (_rulerWidth > 0)) {
//                self.rulerLayer.minorMark.frequency = [NSNumber numberWithFloat:frequency].doubleValue;
//                self.rulerWidth = _rulerWidth;
//                self.spacingBetweenMarks = _spacingBetweenMarks;
//            }
//        }
//        [self.rulerLayer setNeedsDisplay];
//    }

    func setTextAlignment(alignment: RulerMark.MarkAlignment, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.textAlignment = alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.textAlignment = alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.textAlignment = alignment
        }
        self.rulerLayer.setNeedsDisplay()
    }

    func setAlignment(alignment: RulerMark.MarkAlignment, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.alignment = alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.alignment = alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.alignment = alignment
        }
        self.rulerLayer.setNeedsDisplay()
    }

    func setTextOffset(textOffset: CGPoint, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.textOffset = textOffset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.textOffset = textOffset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.textOffset = textOffset
        }
        self.rulerLayer.setNeedsDisplay()
    }

    func setOffset(offset: CGPoint, markType: RulerMarkType) {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            self.rulerLayer.majorMark.offset = offset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            self.rulerLayer.majorMark.offset = offset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            self.rulerLayer.minorMark.offset = offset
        }
        self.rulerLayer.setNeedsDisplay()
    }

//    #pragma mark - Get mark type method

    func sizeForMarkType(markType: RulerMarkType) -> CGSize {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.size
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.size
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.size
        }
        return CGSize.zero
    }

    func colorForMarkType(markType: RulerMarkType) -> UIColor? {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.color
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.color
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.color
        }
        return nil
    }

    func textColorForMarkType(markType: RulerMarkType) -> UIColor? {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.textColor
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.textColor
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.textColor
        }
        return nil
    }

    func fontForMarkType(markType: RulerMarkType) -> UIFont? {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.font
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.font
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.font
        }
        return nil
    }

    func frequencyForMarkType(markType: RulerMarkType) -> CGFloat {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return CGFloat(self.rulerLayer.majorMark.frequency * self.rulerLayer.minorMark.frequency)
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return  CGFloat(self.rulerLayer.middleMark.frequency * self.rulerLayer.minorMark.frequency)
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return  CGFloat(self.rulerLayer.minorMark.frequency)
        }
        return CGFloat.leastNormalMagnitude
    }

    func textAlignmentForMarkType(markType: RulerMarkType) -> RulerMark.MarkAlignment? {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.textAlignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.textAlignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.textAlignment
        }
        return .none
    }

    func alignmentForMarkType(markType: RulerMarkType) -> RulerMark.MarkAlignment? {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.alignment
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.alignment
        }
        return .none
    }

    func textOffsetForMarkType(markType: RulerMarkType) -> CGPoint {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.textOffset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.textOffset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.textOffset
        }
        return CGPoint.zero
    }

    func offsetForMarkType(markType: RulerMarkType) -> CGPoint {
        if markType.rawValue & RulerMarkType.RulerMarkTypeMajor.rawValue != 0 {
            return self.rulerLayer.majorMark.offset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMiddle.rawValue != 0 {
            return self.rulerLayer.middleMark.offset
        }
        if markType.rawValue & RulerMarkType.RulerMarkTypeMinor.rawValue != 0 {
            return self.rulerLayer.minorMark.offset
        }
        return CGPoint.zero
    }
}

extension Ruler: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let oldValue = self.currentValue
        self.currentValue = self.valueForContentOffset(contentOffset: scrollView.contentOffset)
        if (oldValue != self.currentValue) {
            self.sendActions(for: .valueChanged)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = CGPoint(x: targetContentOffset.pointee.x, y: targetContentOffset.pointee.y)
        var value = self.valueForContentOffset(contentOffset: targetOffset)
        let fMinorMarkFreq: CGFloat = CGFloat(self.rulerLayer.minorMark.frequency)
        value = CGFloat(lroundf(Float(value / fMinorMarkFreq))) * fMinorMarkFreq
        targetContentOffset.pointee.x = self.contentOffsetForValue(value: value).x
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let oldValue = self.valueForContentOffset(contentOffset: scrollView.contentOffset)
        let fMinorMarkFreq: CGFloat = CGFloat(self.rulerLayer.minorMark.frequency)
        self.currentValue = CGFloat(lroundf(Float(oldValue / fMinorMarkFreq))) * fMinorMarkFreq
        self.sendActions(for: .valueChanged)
    }
}
