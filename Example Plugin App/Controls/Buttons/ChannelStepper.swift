//
//  ChannelStepper.swift
//  AudioKit Pro Apps Common
//
//  Created by Matthew Fecher on 11/8/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
class ChannelStepper: Stepper {

    override func draw(_ rect: CGRect) {
        let displayText = value == 0 ? "∞" : String(format: "%d", Int(value))
        StepperStyleKit.drawStepper(valuePressed: valuePressed, text: displayText)
    }

}
