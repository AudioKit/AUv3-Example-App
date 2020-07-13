//
//  ToggleSwitch.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class ToggleSwitch: UIView, ParameterController {

    var parameter: ExampleInstrumentParameter?

    var isOn = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var value: Double {
        get {
            return isOn ? 1 : 0
        }
        set {
            isOn = (newValue == 1.0)
            setNeedsDisplay()
        }
    }

    public var callback: (Double) -> Void = { _ in }

    override func draw(_ rect: CGRect) {
        ToggleSwitchStyleKit.drawToggleSwitch(isToggled: isOn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            isOn.toggle()
            self.setNeedsDisplay()
            callback(value)
        }
    }

}
