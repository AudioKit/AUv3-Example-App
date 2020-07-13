//
//  FilterTypeButton.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 8/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class FilterToggleButton: UIButton {

    var callback: (Double) -> Void = { _ in }

    private var _value: Double = 0
    var value: Double {
        get {
            return _value
        }

        set {
            _value = (0 ... 4).clamp(newValue)

            DispatchQueue.main.async {
                switch self._value {
                case 0:
                    self.setTitle("Filter: Bypass", for: .normal)
                case 1:
                    self.setTitle("Filter: Layer 1 & 2", for: .normal)
                case 2:
                    self.setTitle("Filter: Layer 1", for: .normal)
                case 3:
                    self.setTitle("Filter: Layer 2", for: .normal)
                default:
                    // low pass
                    self._value = 0
                    self.setTitle("Bypass", for: .normal)
                }
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        clipsToBounds = true
        layer.cornerRadius = 2
        layer.borderWidth = 1
        //        layer.borderColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) as! CGColor
    }

    // MARK: - Handle Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value += 1
            if value == 4 { value = 0 }
            setNeedsDisplay()
            callback(value)
        }
    }

    func setToggle(_ newValue: Double) {
        value = newValue
        callback(newValue)
    }
}
