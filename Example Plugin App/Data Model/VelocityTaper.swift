//
//  VelocityTaper.swift
//  AU Example App
//
//  Created by Jeff Cooper on 7/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

enum VelocityTaper: Int, CaseIterable {
    case soft, normal, hard

    init(actualTaper: Double) {
        var diff = 0.0
        var closestLevel = VelocityTaper.soft
        for level in VelocityTaper.allCases {
            let currentDiff = fabs(level.taperValue - actualTaper)
            if currentDiff < diff {
                closestLevel = level
            }
            diff = currentDiff
        }
        self = closestLevel
    }

    var taperValue: Double {
        switch self {
        case .soft:
            return 0.4
        case .normal:
            return 1
        case .hard:
            return 4
        }
    }

    var description: String {
        switch self {
        case .soft:
            return "Soft"
        case .normal:
            return "Normal"
        case .hard:
            return "Hard"
        }
    }
}
