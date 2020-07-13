//
//  FilterWavePicker.swift
//  DigitalD1
//
//  Created by Matthew Fecher on 10/3/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
class FilterWavePicker: UIView {

    var callback: (Double) -> Void = { _ in }
    var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    // Draw Button
    override func draw(_ rect: CGRect) {
        FilterPickerStyleKit.drawFilterIcons(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), controlValue: CGFloat(value))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            let h = self.bounds.height

            switch touchPoint.y {
            case 0 ..< h * 0.33:
                if value == 1 {
                    value = 0
                } else {
                    value = 1
                }
            case h * 0.33 ..< h * 0.66:
                if value == 2 {
                    value = 0
                } else {
                    value = 2
                }
            case h * 0.67 ..< h * 0.99:
                if value == 3 {
                    value = 0
                } else {
                    value = 3
                }
            default:
                value = 0
            }

            self.setNeedsDisplay()
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
