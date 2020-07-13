//
//  BaseParameter.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

enum BaseParameter: Int, CaseIterable {
    case volume = 0
    case tremoloRate = 1
    case tremoloDepth = 2
    case autopanEnable = 3
    case autopanRate = 4
    case attack = 5
    case decay = 6
    case sustain = 7
    case release = 8
    case tuningSemi = 9
    case autopanDepth = 10
    case reverbEnable = 11
    case reverbSize = 12
    case reverbMix = 13
    case stereoWidenEnable = 14


    init?(address: AUParameterAddress) {
        if let baseParam = BaseParameter.allCases.first(where: {$0.address == address}) {
            self = baseParam
        } else {
            return nil
        }
    }

    func parameterFor(address: AUParameterAddress) -> BaseParameter? {
        return BaseParameter.init(rawValue: Int(address))
    }

    var address: AUParameterAddress {
        return AUParameterAddress(rawValue)
    }
    var name: String {
        switch self {
        case .volume:
            return "Volume"
        case .tremoloRate:
            return "Tremolo Rate"
        case .tremoloDepth:
            return "Tremolo Depth"
        case .autopanEnable:
            return "Autopan"
        case .autopanRate:
            return "Autopan Rate"
        case .attack:
            return "Attack"
        case .decay:
            return "Decay"
        case .sustain:
            return "Sustain"
        case .release:
            return "Release"
        case .tuningSemi:
            return "Tuning"
        case .autopanDepth:
            return "Autopan Depth"
        case .reverbEnable:
            return "Reverb"
        case .reverbSize:
            return "Reverb Size"
        case .reverbMix:
            return "Reverb Mix"
        case .stereoWidenEnable:
            return "Stereo Widen"

        }
    }
    var identifier: String {
        switch self {
        case .volume:
            return "volumeControl"
        case .tremoloRate:
            return "tremoloRate"
        case .tremoloDepth:
            return "tremoloDepth"
        case .autopanEnable:
            return "autopanEnable"
        case .autopanRate:
            return "autopanRate"
        case .attack:
            return "attack"
        case .decay:
            return "decay"
        case .sustain:
            return "sustain"
        case .release:
            return "release"
        case .tuningSemi:
            return "tuningSemi"
        case .autopanDepth:
            return "autopanDepth"
        case .reverbEnable:
            return "reverbEnable"
        case .reverbSize:
            return "reverbSize"
        case .reverbMix:
            return "reverbMix"
        case .stereoWidenEnable:
            return "stereoWiden"

        }
    }
    var range: ClosedRange<Double> {
        switch self {
        case .volume:
            return 0...0.35
        case .tremoloRate:
            return 0...10.0
        case .autopanRate:
            return 0...5.0
        case .attack:
            return 0.001...2.0
        case .decay:
            return 0.001...4.0
        case .release:
            return 0.05...4.0
        case .tuningSemi:
            return -1.0...1
        case .reverbSize:
            return 0.5...0.95
        default:
            return 0...1.0
        }
    }
    var displayRange: ClosedRange<Double> {
        switch self {
        default:
            return range
        }
    }
    var defaultValue: AUValue { //normalized values
        switch self {
        case .volume:
            return 0.777
        case .tremoloRate:
            return 0.3
        case .autopanRate:
            return 0.25
        case .autopanDepth:
            return 1.0
        case .tuningSemi:
            return 0.5
        case .attack:
            return 0.001
        case .decay:
            return 0.001
        case .sustain:
            return 1.0
        case .release:
            return getnormalizedValue(for: 0.1)
        case .reverbSize:
            return 0.5
        case .reverbMix:
            return 0.5
        default:
            return 0.0
        }
    }
    var defaultDenormalized: Double {
        return getDenormalizedValue(for: defaultValue)
    }
    var taper: Double {
        switch self {
        default:
            return 1.0
        }
    }

    func displayStringFor(normalized: Float) -> String {
        let denormalizedDisplayValue = getDenormalizedDisplayValue(for: normalized)
        switch self {
        case .volume:
            return "\(normalized.percentageString)"
        case .tremoloRate:
            return "\(denormalizedDisplayValue.decimalString) Hz"
        case .tremoloDepth:
            return "\(normalized.percentageString)"
        case .autopanEnable:
            return denormalizedDisplayValue == 1 ? "On" : "Off"
        case .autopanRate:
            return "\(denormalizedDisplayValue.decimalString) Hz"
        case .attack:
            return "\(denormalizedDisplayValue.decimalString) sec"
        case .decay:
            return "\(denormalizedDisplayValue.decimalString) sec"
        case .sustain:
            return "\(denormalizedDisplayValue.decimalString) sec"
        case .release:
            return "\(denormalizedDisplayValue.decimalString) sec"
        case .tuningSemi:
            return "\(denormalizedDisplayValue.decimalString) semitone"
        case .autopanDepth:
            return "\(normalized.percentageString)"
        case .reverbEnable:
            return denormalizedDisplayValue == 1 ? "On" : "Off"
        case .reverbSize:
            return "\(normalized.percentageString)"
        case .reverbMix:
            return "\(normalized.percentageString)"
        case .stereoWidenEnable:
            return denormalizedDisplayValue == 1 ? "On" : "Off"

        }
    }

    func getDenormalizedValue(for normalized: Float) -> Double {
        var outVal: Double
        if bidirectional {
            let newNormal = normalized > 0.5 ? (normalized - 0.5) / 0.5 : (normalized / 0.5)
            let halfRange = self.range.upperBound - self.range.lowerBound / 2
            let newRange = 0...halfRange
            outVal = Double(newNormal).denormalized(to: newRange, taper: self.taper)
        } else {
            outVal = Double(normalized).denormalized(to: self.range, taper: self.taper)
        }
        return shouldRound ? outVal.rounded() : outVal
    }
    func getDenormalizedDisplayValue(for normalized: Float) -> Double {
        let outVal = Double(normalized).denormalized(to: self.displayRange)
        return shouldRound ? outVal.rounded() : outVal
    }
    func getnormalizedValue(for denormalized: Double) -> AUValue {
        return AUValue(denormalized.normalized(from: self.range, taper: self.taper))
    }
    func getStringValue(for normalized: AUValue) -> String {
        let denorm = getDenormalizedDisplayValue(for: normalized)
        return String(format: self.stringFormat, denorm)
    }
    var stringFormat: String {
        switch self {
        default:
            return "%.2f"
        }
    }
    var param: AUParameter {
        return AUParameter(identifier: self.identifier,
                           name: self.name,
                           address: self.address,
                           min: 0.0,
                           max: 1.0,
                           unit: .generic,
                           flags: .default)
    }

    var bidirectional: Bool {
        switch self {
        default:
            return false
        }
    }

    var shouldRound: Bool {
        switch self {
        case .reverbEnable, .autopanEnable, .stereoWidenEnable:
            return true
        default:
            return false
        }
    }

    var notificationName: Notification.Name {
        return Notification.Name(identifier)
    }
}
