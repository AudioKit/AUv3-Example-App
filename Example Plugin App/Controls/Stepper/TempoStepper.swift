//
//  TempoStepper.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
public class TempoStepper: Stepper {

    let tempoPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 0.5, width: 75, height: 32), cornerRadius: 1)
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0

    public var taper: Double = 1.0 // Linear by default

    internal var _value: Double = 0
    var range: ClosedRange = 0.0...1.0

    override public var value: Double {
        get {
            return _value
        }
        set {
            _value = round(newValue)
            range = (Double(minValue) ... Double(maxValue))
            _value = range.clamp(newValue)
            knobValue = CGFloat(newValue.normalized(from: range, taper: taper))
            _value = newValue.rounded()
        }
    }

    // Knob properties
    var knobValue: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    // Init / Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw

        minusPath = UIBezierPath(roundedRect: CGRect(x: 3.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)
        plusPath = UIBezierPath(roundedRect: CGRect(x: 43.5, y: 38.5, width: 35, height: 32), cornerRadius: 1)

        maxValue = 360
        minValue = 60
        range = (Double(minValue) ... Double(maxValue))
        _value = 120
        text = String(_value)
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    override public class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override func draw(_ rect: CGRect) {
        TempoStyleKit.drawTempoStepper(valuePressed: valuePressed, text: "\(Int(value)) bpm")
    }

    /// Handle new touches

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            if minusPath.contains(touchLocation) {
                if value > Double(minValue) {
                    value -= 1
                    valuePressed = 1
                }
            }

            if plusPath.contains(touchLocation) {
                if value < Double(maxValue) {
                    value += 1
                    valuePressed = 2
                }
            }

            if tempoPath.contains(touchLocation) {
                let touchPoint = touch.location(in: self)
                lastX = touchPoint.x
                lastY = touchPoint.y
            }

            self.callback(value)
            self.setNeedsDisplay()
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if valuePressed == 0 {
            for touch in touches {
                let touchPoint = touch.location(in: self)
                setPercentagesWithTouchPoint(touchPoint)
            }
        }
    }

    // Helper
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {

        // Knobs assume up or right is increasing, and down or left is decreasing
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity
        knobValue = (0.0 ... 1.0).clamp(knobValue)

        value = Double(knobValue).denormalized(to: range, taper: taper)
        callback(value)

        lastX = touchPoint.x
        lastY = touchPoint.y
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
            self.setNeedsDisplay()
        }
    }
}
