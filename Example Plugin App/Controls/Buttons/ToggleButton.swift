//
//  ToggleButton.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/22/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleButton: UIView, AKSynthOneControl {

    var isOn: Bool {
        return value == 1
    }

    var callback: (Double) -> Void = { _ in }

    var value: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var offColor = UIColor(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.000)

    override func draw(_ rect: CGRect) {
        FlatToggleStyleKit.drawRoundButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), isToggled: isOn, offColor: offColor)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = isOn ? 0 : 1
            setNeedsDisplay()
            callback(value)
        }
    }

    func setToggle(_ newValue: Double) {
        value = newValue
        callback(newValue)
    }

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
        clipsToBounds = true
    }

    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

}
