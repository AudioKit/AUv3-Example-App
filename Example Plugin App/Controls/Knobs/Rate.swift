//
//  Rate.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public enum Rate: Int, CustomStringConvertible {

    case eightBars = 0
    case fourBars
    case threeBars
    case twoBars
    case bar
    case half
    case halfTriplet
    case quarter
    case quarterTriplet
    case eighth
    case eighthTriplet
    case sixteenth
    case sixteenthTriplet
    case thirtySecondth
    case sixtyFourth

    static let count: Int = {
        var max: Int = 0
        while let _ = Rate(rawValue: max) { max += 1 }
        return max
    }()

    public var description: String {
        switch self {
        case .eightBars:
            return "8 bars"
        case .fourBars:
            return "4 bars"
        case .threeBars:
            return "3 bars"
        case .twoBars:
            return "2 bars"
        case .bar:
            return "1 bar"
        case .half:
            return "1/2 note"
        case .halfTriplet:
            return "1/2 triplet"
        case .quarter:
            return "1/4 note"
        case .quarterTriplet:
            return "1/4 triplet"
        case .eighth:
            return "1/8 note"
        case .eighthTriplet:
            return "1/8 triplet"
        case .sixteenth:
            return "1/16 note"
        case .sixteenthTriplet:
            return "1/16 triplet"
        case .thirtySecondth:
            return "1/32 note"
        case .sixtyFourth:
            return "1/64 note"
        }
    }

    func frequency(forTempo tempo: Double) -> Double {
        // code to caculate Freq Tempo
        return 1.0 / time(forTempo: tempo)
    }

    func time(forTempo tempo: Double) -> Double {
        switch self {
        case .eightBars:
            return seconds(tempo: tempo, bars: 8)
        case .fourBars:
            return seconds(tempo: tempo, bars: 4)
        case .threeBars:
            return seconds(tempo: tempo, bars: 3)
        case .twoBars:
            return seconds(tempo: tempo, bars: 2)
        case .bar:
            return seconds(tempo: tempo, bars: 1)
        case .half:
            return seconds(tempo: tempo, bars: 1/2)
        case .halfTriplet:
            return seconds(tempo: tempo, bars: 1/2, triplet: true)
        case .quarter:
            return seconds(tempo: tempo, bars: 1/4)
        case .quarterTriplet:
            return seconds(tempo: tempo, bars: 1/4, triplet: true)
        case .eighth:
            return seconds(tempo: tempo, bars: 1/8)
        case .eighthTriplet:
            return seconds(tempo: tempo, bars: 1/8, triplet: true)
        case .sixteenth:
            return seconds(tempo: tempo, bars: 1/16)
        case .sixteenthTriplet:
            return seconds(tempo: tempo, bars: 1/16, triplet: true)
        case .thirtySecondth:
            return seconds(tempo: tempo, bars: 1/32)
        case .sixtyFourth:
            return seconds(tempo: tempo, bars: 1/64)
        }
    }

    func seconds(tempo: Double, bars: Double = 1.0, triplet: Bool = false) -> Double {
        let minutesPerSecond = 1.0 / 60.0
        let beatsPerBar = 4.0

        return (beatsPerBar * bars) / (tempo * minutesPerSecond) / (triplet ? 1.5 : 1)
    }

    private static func findMinimum(_ value: Double, comparator: (Int) -> Double) -> Rate {
        var closestRate = Rate(rawValue: 0)
        var smallestDifference = 1000000000.0
        for i in 0 ..< Rate.count {
            let difference: Double = abs(comparator(i) - value)
            if  difference < smallestDifference {
                smallestDifference = difference
                closestRate = Rate(rawValue: i)
            }
        }
        return closestRate!
    }

    static func fromFrequency(_ frequency: Double, forTempo tempo: Double) -> Rate {

        return(Rate.findMinimum(frequency, comparator: { (i) -> Double in
            Rate(rawValue: i)!.frequency(forTempo: tempo)
        }))
//        var closestRate = Rate(rawValue: 0)
//        var smallestDifference = 1000000000.0
//        for i in 0 ..< Rate.count {
//            let difference: Double = abs(Rate(rawValue: i)!.frequency - frequency)
//            if  difference < smallestDifference {
//                smallestDifference = difference
//                closestRate = Rate(rawValue: i)
//            }
//        }
//        return closestRate!
    }

    static func fromTime(_ time: Double, forTempo tempo: Double) -> Rate {
        return(Rate.findMinimum(time, comparator: { (i) -> Double in
            Rate(rawValue: i)!.time(forTempo: tempo)
        }))
//        var closestRate = Rate(rawValue: 0)
//        var smallestDifference = 1000000000.0
//        for i in 0 ..< Rate.count {
//            let difference: Double = abs(Rate(rawValue: i)!.time - time)
//            if  difference < smallestDifference {
//                smallestDifference = difference
//                closestRate = Rate(rawValue: i)
//            }
//        }
//        return closestRate!
    }
}
