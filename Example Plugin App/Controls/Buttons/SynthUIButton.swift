//
//  SynthUIButton.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class SynthUIButton: UIButton {

    var callback: (Double) -> Void = { _ in }

    var isOn: Bool {
        get {
          return value == 1
        }
        set {
            value = (newValue ? 1:0)
            setNeedsDisplay()
        }
    }

    override public var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2941176471, alpha: 1) : #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
            setNeedsDisplay()
        }
    }

    var value: Double = 0.0 {
        didSet {
            isSelected = value == 1.0
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        clipsToBounds = true
        layer.cornerRadius = 4
        layer.borderWidth = 1
        //        layer.borderColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) as! CGColor
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = isOn ? 0 : 1
            self.setNeedsDisplay()
            callback(value)
        }
    }

    func setToggle(_ newValue: Double) {
        value = newValue
        callback(newValue)
    }

}
