//
//  Double+Extensions.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/5/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension Float {
    // Return string formatted to 2 decimal places
    var decimalString: String {
        return String(format: "%.02f", self)
    }
    
    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return "\(Int(100 * self))%"
    }
}

extension Double {
    // Return string formatted to 2 decimal places
    func getDecimalString(places: Int) -> String {
        return String(format: "%.0\(places)f", self)
    }
    
    // Return string formatted to 2 decimal places
    var decimalString: String {
        return String(format: "%.02f", self)
    }
    
    var decimal1String: String {
        return String(format: "%.01f", self)
    }
    
    var decimal4String: String {
        return String(format: "%.04f", self)
    }
    
    // Return string shifted 3 decimal places to left
    var decimal1000String: String {
        let newValue = 1000 * self
        return String(format: "%.02f", newValue)
    }
    
    // Return ms 3 decimal places to left
    var msFormattedString: String {
        let newValue = 1000 * self
        return String(format: "%.00f ms", newValue)
    }
    
    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return "\(Int(100 * self))%"
    }
    
    // Linear scale entire range to another range
    public static func scaleEntireRange(_ value: Double, fromRangeMin: Double, fromRangeMax: Double, toRangeMin: Double, toRangeMax: Double) -> Double {
        return ((toRangeMax - toRangeMin) * (value - fromRangeMin) / (fromRangeMax - fromRangeMin)) + toRangeMin
    }
    
}
