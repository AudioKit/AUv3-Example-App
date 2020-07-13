//
//  ArrowButton.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 8/2/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit

@IBDesignable
public class Stepper: UIView {

    public var callback: (Double) -> Void = { _ in }

    var minusPath = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 2, width: 35, height: 32), cornerRadius: 1)
    var plusPath = UIBezierPath(roundedRect: CGRect(x: 70.5, y: 2, width: 35, height: 32), cornerRadius: 1)

    var minValue = 0.0
    var maxValue = 4.0

    var value = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var valuePressed: CGFloat = 0

    /// Text / label to display
    open var text = "0"

        public override func draw(_ rect: CGRect) {
         StepperStyleKit.drawStepper(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: self.bounds.width,
                                                         height: self.bounds.height),
                                           valuePressed: valuePressed, text: "\(Int(value))")
    }
    

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if minusPath.contains(touchLocation) {
                if value > minValue {
                    value -= 1
                    valuePressed = 1
                }
            }
            if plusPath.contains(touchLocation) {
                if value < maxValue {
                    value += 1
                    valuePressed = 2
                }
            }
            self.callback(Double(value))
            self.setNeedsDisplay()
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            valuePressed = 0
         self.setNeedsDisplay()
        }
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
