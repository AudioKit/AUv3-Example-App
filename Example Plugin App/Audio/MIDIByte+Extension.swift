//
//  MIDIByte+Extension.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/20/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

extension MIDIByte {
    var normalized: Float {
        return Float(self) / 127.0
    }

    init(normalized: Double) {
        self = MIDIByte(floor(normalized * 127.0))
    }
}

