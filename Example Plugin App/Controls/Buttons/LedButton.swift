//
//  LedButton.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 9/19/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
class LedButton: ToggleButton {

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw

        offColor = UIColor(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.000)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    public override func draw(_ rect: CGRect) {
        LedToggleStyleKit.drawLedButton(isToggled: isOn, offColor: offColor)
    }

}
