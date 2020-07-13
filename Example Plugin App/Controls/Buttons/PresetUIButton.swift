//
//  PresetUIButon.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 11/24/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

class PresetUIButton: SynthUIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            
            self.setNeedsDisplay()
            callback(value)
        }
    }
    
    override public var isSelected: Bool {
        didSet {
            self.backgroundColor = isOn ? #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2941176471, alpha: 1) : #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            setNeedsDisplay()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 6
        
    }
    
}
