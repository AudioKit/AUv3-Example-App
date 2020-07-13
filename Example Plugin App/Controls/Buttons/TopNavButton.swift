//
//  TopUIButton.swift
//  Super-FM
//
//  Created by Matthew Fecher on 2/8/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
class TopNavButton: NavButton {

    var alternateButtons: [NavButton]?

    func unselectAlternateButtons() {
        guard let alternateButtons = alternateButtons else { return }
        alternateButtons.forEach {
            $0.value = 0
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            unselectAlternateButtons()
            value = isOn ? 0 : 1
            setNeedsDisplay()
            callback(value)
        }
    }
}
