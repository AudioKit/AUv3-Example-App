//
//  ParameterValuePair.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/29/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

// a simple class for storing identifiers + values from the au for saving in a preset

class ParameterValuePair: NSObject, Codable {
    var identifier: String
    var value: Float

    init(identifier: String, value: Float) {
        self.identifier = identifier
        self.value = value
    }
}
