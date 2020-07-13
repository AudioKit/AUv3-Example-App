//
//  AKTouchPadView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class AKVerticalPad: UIView {

    // touch properties
    var firstTouch: UITouch?

    public typealias AKVerticalPadCallback = (Double) -> Void
    var callback: AKVerticalPadCallback = { _ in }

    public typealias AKVerticalPadCompletionHandler = (Double, Bool, Bool) -> Void
    var completionHandler: AKVerticalPadCompletionHandler = { _, _, _ in }

    private var x: CGFloat = 0
    public var y: CGFloat = 0
    private var lastX: CGFloat = 0
    public var lastY: CGFloat = 0
    private var centerPointX: CGFloat = 0
    private var yVisualAdjust: CGFloat = 6

    public var verticalTaper: Double = 1.0 // Linear by default

    public var verticalRange: ClosedRange = 0.0...1.0 {
        didSet {
            y = CGFloat(verticalValue.normalized(from: verticalRange, taper: verticalTaper))
        }
    }

    public var verticalValue: Double = 0 {
        didSet {
            verticalValue = verticalRange.clamp(verticalValue)
            y = CGFloat(verticalValue.normalized(from: verticalRange, taper: verticalTaper))
        }
    }

    var value = 0.0 {
        didSet {
            verticalValue = value
            let verticalPos = self.bounds.height - (self.bounds.height * CGFloat(verticalValue))
            touchPointView.center = CGPoint(x: centerPointX, y: verticalPos + yVisualAdjust)
            setNeedsDisplay()
        }
    }

    var touchPointView: TouchPoint!

    override init (frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        centerPointX = self.bounds.size.width/2

        // Setup Touch Visual Indicators
        touchPointView = TouchPoint(frame: CGRect(x: -200, y: -200, width: 58, height: 58))
        touchPointView.center = CGPoint(x: centerPointX, y: self.bounds.size.height/2)
        touchPointView.isOpaque = false
        self.addSubview(touchPointView)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
//            lastX = touchPoint.x
//            lastY = touchPoint.y
            setPercentagesWithTouchPoint(touchPoint, began: true)
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)

            if touchPoint.y > (self.bounds.minY + 0) && touchPoint.y < (self.bounds.maxY) {
                setPercentagesWithTouchPoint(touchPoint, began: false)
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // return indicator to center of view
        completionHandler(verticalValue, true, false)
    }

    func setVerticalValueFrom(normalized: Double, sendCallback: Bool = true) {
        let verticalPos = self.bounds.height - (self.bounds.height * CGFloat(normalized))
        touchPointView.center = CGPoint(x: centerPointX, y: verticalPos + yVisualAdjust)
        if sendCallback {
            callback(normalized)
        }
    }

    func setVerticalValueFrom(midiValue: MIDIByte, sendCallback: Bool = true) {
        // Linear Scale MIDI 0...127 to 0.0...1.0
        verticalValue = Double(midiValue).normalized(from: 0...127)
        setVerticalValueFrom(normalized: verticalValue, sendCallback: sendCallback)
    }

    func setVerticalValueFromPitchWheel(midiValue: MIDIWord, sendCallback: Bool = true) {
        // Linear Scale from PitchWheel
        verticalValue = Double(midiValue).normalized(from: 0 ... 16384)
        setVerticalValueFrom(normalized: verticalValue, sendCallback: sendCallback)
    }

    func resetToCenter() {
        resetToPosition(0.5, 0.5)
    }

    func resetToPosition(_ newPercentX: Double = 0.5, _ newPercentY: Double) {
        let centerPointY = self.bounds.size.height * CGFloat((1 - newPercentY))

        UIView.animate(
            withDuration: 0.05,
            delay: 0.0,
            options: UIView.AnimationOptions(),
            animations: { self.touchPointView.center = CGPoint(x: self.centerPointX, y: centerPointY + self.yVisualAdjust) },
            completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.x = CGFloat(newPercentX)
                strongSelf.y = CGFloat(newPercentY)

                strongSelf.verticalValue = Double(strongSelf.y).denormalized(to: strongSelf.verticalRange, taper: strongSelf.verticalTaper)
                strongSelf.completionHandler(strongSelf.verticalValue, true, true)
        })
    }

    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint, began: Bool = false) {

        y = CGFloat((0.0 ... 1.0).clamp(1 - touchPoint.y / self.bounds.size.height))
        touchPointView.center = CGPoint(x: centerPointX, y: touchPoint.y + yVisualAdjust)
        verticalValue = Double(y).denormalized(to: verticalRange, taper: verticalTaper)
        callback(verticalValue)

        if began {
             callback(verticalValue + 0.001)
        }
    }

}
