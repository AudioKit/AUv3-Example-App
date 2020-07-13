//
//  MIDICCDefinition.swift
//  Bass 808
//
//  Created by Jeff Cooper on 4/1/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

struct MIDICCDefinition: Codable {
    var identifier: String
    var ccs: [UInt8]

    init(identifier: String, ccs: [UInt8]) {
        self.identifier = identifier
        self.ccs = ccs
    }
    
    init?(with dictionary: [String: Any]) {
        guard let identifier = dictionary["identifier"] as? String, let ccs = dictionary["ccs"] as? [UInt8] else {
            return nil
        }
        self = MIDICCDefinition(identifier: identifier, ccs: ccs)
    }
}

extension Conductor {
    //make this a protocol / class that conductor can conform to
    var midiDefinitions: [MIDICCDefinition] {
        return allParameterControls.compactMap({ MIDICCDefinition(identifier: $0.identifier,
                                                                  ccs: $0.midiControllers) })
    }

    func assignMIDICCs(definitions: [MIDICCDefinition]) {
        for definition in definitions {
            if let control = getControlByIdentifier(identifier: definition.identifier) {
                control.midiControllers = definition.ccs
            }
        }
    }

    //add this function whatever protocol / class conductor eventually becomes
    func getControlByIdentifier(identifier: String) -> ExampleInstrumentParameter? {
        return allParameterControls.first(where: { $0.identifier == identifier })
    }

}
