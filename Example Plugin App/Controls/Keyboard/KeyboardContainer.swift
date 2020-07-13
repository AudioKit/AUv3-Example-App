//
//  KeyboardContainer.swift
//  DigitalD1
//
//  Created by Matthew Fecher on 5/26/19.
//  Copyright © 2019 AudioKit Pro. All rights reserved.
//

import UIKit

class KeyboardContainer: UIView {

    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
    }
}
