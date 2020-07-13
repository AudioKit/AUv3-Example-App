//
//  ControlBorder.swift
//  UniversalKnob
//
//  Created by Matthew Fecher on 9/24/19.
//  Copyright © 2019 Matthew Fecher. All rights reserved.
//

import UIKit

public class ControlFrame: UIView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.borderWidth = 5
        layer.cornerRadius = 5
        layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        layer.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
    }
}
