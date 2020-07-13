//
//  OscToggleButton.swift
//  DigitalD1
//
//  Created by Matthew Fecher on 10/12/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import UIKit

public class OscToggleButton: SynthUIButton {

    override public var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2549019608, alpha: 1) : #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
            setNeedsDisplay()
        }
    }
}
