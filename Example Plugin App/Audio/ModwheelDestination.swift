//
//  ModwheelDestination.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/20/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

enum ModwheelDestination: Int, CaseIterable, Codable {
    case vibrato = 0
    case tremolo = 1

    var name: String {
        switch self {
        case .vibrato:
            return "Vibrato"
        case .tremolo:
            return "Tremolo"

        }
    }

    func normalizedValue(_ value: UInt8) -> Float {
        return Float(min(max(value, 0), 127)) / 127.0
    }
}
