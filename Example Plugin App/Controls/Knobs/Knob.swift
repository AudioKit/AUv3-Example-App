//
//  KnobView.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/20/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit

protocol AKSynthOneControl {
    var value: Double { get set }
    var callback: (Double) -> Void { get set }
}

@IBDesignable
public class Knob: UIView, AKSynthOneControl {

    var onlyIntegers: Bool = false
    public var callback: (Double) -> Void = { _ in }
    var lfoIndicator = UIView()

    public var taper: Double = 1.0 // Linear by default

    var originKnobValue: CGFloat = 0.0
    var presetKnobValue: CGFloat = 0.0

    var assignedLFOs: UInt8 = 0 { // 1=LFO1, 2=LFO2, 3=LFO1+LFO2, 4=LFO3, 5=LFO1+LFO3, 6=LFO2+LFO3, 7=ALL
        didSet {
            if !isAssignedLFO {
                hideLFOIndicator()
                if knobValue != originKnobValue {
                    updateKnobValue(Double(originKnobValue))
                }
            }
        }
    }

    var isAssignedLFO: Bool {
        return assignedLFOs != 0
    }

    var range: ClosedRange = 0.0...1.0 {
        didSet {
            knobValue = CGFloat(Double(knobValue).normalized(from: range, taper: taper))
        }
    }

    private var _value: Double = 0

    var value: Double {
        get { return _value }
        set(newValue) {
            _value = range.clamp(newValue)
            _value = onlyIntegers ? round(_value) : _value
            self.knobValue = CGFloat(newValue.normalized(from: range, taper: taper))
            self.setNeedsDisplay()
        }
    }

    // Knob properties
    var knobValue: CGFloat = 0.0 {
        didSet(newValue) {
            _value = Double(newValue).denormalized(to: range, taper: taper)
            self.setNeedsDisplay()
        }
    }

    // Alternative to .knobValue = with no setNeedsDisplay
    func changeValue(_ newValue: Double) {
        _value = newValue.denormalized(to: range, taper: taper)
    }

    var knobFill: CGFloat = 0
    var knobSensitivity: CGFloat = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw

        addLFOIndicator()

        // Add double tap listener
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    @objc func doubleTapped() {
        updateKnobValue(Double(presetKnobValue))
    }

    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override func draw(_ rect: CGRect) {
        KnobStyleKit2.drawFMKnob(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), knobValue: knobValue)
    }

    // Helper
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing

        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity

        knobValue = (0.0 ... 1.0).clamp(knobValue)

        value = Double(knobValue).denormalized(to: range, taper: taper)

        originKnobValue = knobValue // set last user set position to originKnobValue

        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }

    func setKnobValue(_ newValue: Double) {
        presetKnobValue = CGFloat(newValue)
        updateKnobValue(newValue)
    }

    func updateKnobValue(_ newValue: Double, resetOrigin: Bool = true) {
        knobValue = CGFloat(newValue)
        _value = Double(newValue).denormalized(to: range, taper: taper)
        originKnobValue = knobValue
        callback(_value)
        self.setNeedsDisplay()
    }

    func setOriginValue(_ newValue: Double) {
        knobValue = CGFloat(newValue)
        originKnobValue = knobValue
    }

    func addLFOIndicator() {
        lfoIndicator = UIView(frame: CGRect(x: 2, y: 2, width: self.bounds.width-2, height: self.bounds.height-2))
        lfoIndicator.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 0)
        lfoIndicator.layer.borderColor = #colorLiteral(red: 0.1490196078, green: 0.3764705882, blue: 0.4862745098, alpha: 1)
        lfoIndicator.layer.borderWidth = 3
        lfoIndicator.layer.cornerRadius = (self.bounds.width-2) / 2
        lfoIndicator.isHidden = true
        self.addSubview(lfoIndicator)
    }

    func hideLFOIndicator() {
        lfoIndicator.isHidden = true
    }

    func turnLFOKnobsOff() {
        hideLFOIndicator()
    }

    func showLFOIndicator() {
        lfoIndicator.isHidden = false
    }
}
