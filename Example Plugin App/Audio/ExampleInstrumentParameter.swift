//
//  RhodesParameter.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class ExampleInstrumentParameter {
    var baseParameter: BaseParameter
    var exampleInstrumentID: String
    var midiControllers = [MIDIByte]()
    private var defaultOverride: Float?

    init(_ param: BaseParameter, defaultOverride: Float? = nil, exampleInstrumentID: String = "") {
        self.defaultOverride = defaultOverride
        baseParameter = param
        self.exampleInstrumentID = exampleInstrumentID
        setParam(defaultValue: self.defaultOverride ?? param.defaultValue)
    }

    static let identifierPrefix = "exampleInstrument"

    var identifier: String {
        return "\(ExampleInstrumentParameter.identifierPrefix)\(baseParameter.identifier)"
    }

    var name: String {
        return baseParameter.name
    }

    var address: AUParameterAddress {
        let offset: UInt64 = 0
        return AUParameterAddress(offset + baseParameter.address)
    }

    var param = AUParameter()

    var value: Float {
        set { param.value = newValue }
        get { return param.value }
    }

    func displayValueFor(normalized: Float) -> String {
        return "\(baseParameter.displayStringFor(normalized: normalized))"
    }

    private func setParam(defaultValue: Float) {
        self.param = AUParameter(identifier: self.identifier,
                                 name: self.name,
                                 address: self.address,
                                 min: 0.0,
                                 max: 1.0,
                                 unit: .generic,
                                 flags: .default)
        self.param.value = defaultValue
    }

    func reset() {
        value = defaultOverride ?? baseParameter.defaultValue
    }
}
