//
//  NavButton.swift
//  Super-FM
//
//  Created by Matthew Fecher on 5/3/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import UIKit

public class NavButton: UIButton {

    var callback: (Double) -> Void = { _ in }

    var isOn: Bool {
        return value == 1
    }

    override public var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.3103210926, green: 0.3110416532, blue: 0.3322413266, alpha: 1) : #colorLiteral(red: 0.1129838899, green: 0.1139593944, blue: 0.140907675, alpha: 1)
            setNeedsDisplay()
        }
    }

    var value: Double = 0.0 {
        didSet {
            isSelected = value == 1.0
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        clipsToBounds = true
        layer.cornerRadius = 4
        layer.borderWidth = 1

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            value = isOn ? 0 : 1
            self.setNeedsDisplay()
            callback(value)
        }
    }

}
