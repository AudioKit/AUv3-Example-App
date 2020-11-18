//
//  BPM+StatisticalTools.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension Double {
    /// Tool for rounding to decimal places which is good for
    /// producing a more stable tempo display.
    ///
    /// - Parameter decimalPlaces: number of decimal places in the result
    /// - Returns: rounded Double
    func roundToDecimalPlaces(_ decimalPlaces: UInt8) -> Double {
        let multiplier = pow(10, Double(decimalPlaces))
        return (self * multiplier).rounded(.towardZero) * (1.0 / multiplier)
    }
}

// MARK: - Tools for obtaining average and std_dev arrays of floating points
extension Array where Element: Numeric {

    func sum() -> Float64 {
        return self.reduce( Float64(0), +)
    }

    func avg() -> Float64 {
        guard self.count > 0 else { return 0 }
        return Float64(self.sum()) / Float64(self.count)
    }

    func std() -> Float64 {
        guard self.count > 1 else { return 0 }
        let mean = self.avg()
        let start = Float64(0)
        let v = self.reduce(start) { (priorResult, item) -> Float64 in
            let accumulator = Float64(priorResult)
            let floatItem = item as! Float64
            let diff = floatItem - mean
            return accumulator + diff * diff
        }
        return sqrt(v / (Float64(self.count) - 1))
    }

    func meanAndStdDev() -> (mean: Float64, std: Float64) {
        // Peform Statistics
        let meanCalc = avg()
        let stdDev = std()
        return (meanCalc, stdDev)
    }
}

/// BPMHistoryStatistics keeps several sets of BPM history data for
/// various lengths of time.  This is done so that the history with
/// the smallest standard deviation may be returned as the current
/// BPM
struct BPMHistoryStatistics {
    typealias BPMStats = (mean: BPMType, std: BPMType)
    typealias TimeStats = (mean: Double, std: Double)
    typealias LinearRegression = (slope: Double, c: Double)

    // Configure countIndex to use the results that you'd like to look at
    let regressionCountIndex = 5
    let historyCounts = [3, 6, 12, 24, 48, 96, 192, 384]

    var bpmHistory: [BPMType]
    var actualTimeHistory: [UInt64]
    var timeHistory: [Float64]
    var bpmStats: [BPMStats]
    var timeStats: [TimeStats]

    var lineFn: LinearRegression?

    init() {
        bpmHistory = []
        timeHistory = []
        bpmStats = []
        timeStats = []
        actualTimeHistory = []
    }

    func timeAt(ratio: Float) -> UInt64 {
        guard timeHistory.count != 0 else { return 0 }
        guard timeHistory.count != 1 else { return UInt64(timeHistory.first!) }
        let firstIndex = max(timeHistory.count - historyCounts[regressionCountIndex], 0)
        let first = timeHistory[firstIndex]
        let last = timeHistory.last!
        let value = first + ((last - first) * ratio)
        return UInt64(value)
    }

    mutating func record(bpm: BPMType) {

        let maxCount = historyCounts.max() ?? 1
        if maxCount > 1 {
            if (bpmHistory.count > maxCount) {
                bpmHistory = bpmHistory.dropFirst(1).compactMap({ $0 })
            }
        }
        bpmHistory.append(bpm)

        calculateBPMMeanAndStdDev()
    }

    mutating func record(bpm: BPMType, time: UInt64) {

        let maxCount = historyCounts.max() ?? 1
        if maxCount > 1 {
            if (bpmHistory.count > maxCount) {
                bpmHistory = bpmHistory.dropFirst().compactMap({ $0 })
            }
            if (timeHistory.count > maxCount) {
                timeHistory = timeHistory.dropFirst().compactMap({ $0 })
            }
            if (actualTimeHistory.count > maxCount) {
                actualTimeHistory = actualTimeHistory.dropFirst().compactMap({ $0 })
            }
        }
        bpmHistory.append(bpm)
        timeHistory.append(Float64(time))
        actualTimeHistory.append(time)

        calculateBPMMeanAndStdDev()
        calculateTimeMeanAndStdDev()
        linearRegression()
    }

    mutating private func calculateBPMMeanAndStdDev() {

        var newStats: [BPMStats] = []

        historyCounts.forEach { (count) in
            // Peform Statistics
            let dropCount = bpmHistory.count - count
            guard dropCount > 0 else { return }
            let history = bpmHistory.dropFirst(dropCount).compactMap({ $0 })
            let results = history.meanAndStdDev()
            newStats.append(results)
        }
        bpmStats = newStats
    }

    mutating private func calculateTimeMeanAndStdDev() {

        var newStats: [TimeStats] = []

        historyCounts.forEach { (count) in
            // Peform Statistics
            let dropCount = timeHistory.count - count
            guard dropCount > 0 else { return }
            let history = timeHistory.dropFirst(dropCount).compactMap({ $0 })
            let results = history.meanAndStdDev()
            newStats.append(results)
        }
        timeStats = newStats
    }

    mutating private func linearRegression() {

        guard timeStats.count >= regressionCountIndex else { return }
        guard bpmStats.count >= regressionCountIndex else { return }
        let pairs = zip(timeHistory, bpmHistory)
        let meanTime = timeStats[regressionCountIndex - 1].mean
        let meanBPM = bpmStats[regressionCountIndex - 1].mean
        let a = pairs.reduce(0) { $0 + ($1.0 - meanTime) * ($1.1 - meanBPM) }
        let b = pairs.reduce(0) { $0 + pow($1.0 - meanTime, 2) }

        let m = a / b
        let c = meanBPM - m * meanTime

        lineFn = (slope: m, c: c)
    }

    func bpmFromRegressionAtTime(_ time: UInt64) -> TimeInterval {

        guard let lineFn = lineFn else { return 0 }

        return lineFn.c + lineFn.slope * Double(time)
    }

    /// This methods attempts to return the most accurate BPM
    /// by searching through its most recent BPM history sets for
    /// the sequence with the least deviation from that sets mean.
    ///
    /// - Returns: A tuple with Average BPM, Standard Deviation, index of the BTM history set it used, and the count of recent BPMs used to obtain the average
    func avgFromSmallestDeviatingHistory() -> (avg: BPMType, std: BPMType, index: Int, count: Int, accuracy: Double) {

        guard let results = bpmStats.min(by: { (left, right) -> Bool in
            return left.std <= right.std
        }) else { return (0, 0, 0, 0, 0) }

        return (results.mean, results.std, 0, 0, 0)
    }
}

/// BPMHistoryAveraging keeps a history of BPM values that recorded into it.
/// Each time a value is recorded, it calcualtes a average and standard
//  deviation so that the stability of the BPM clock can be examined.
struct BPMHistoryAveraging {
    var bpmHistory: [BPMType]
    var countLimit: Int
    var results: (avg: BPMType, std: BPMType)

    init(countLimit limit: Int) {
        countLimit = limit
        bpmHistory = []
        results = (0, 0)
    }

    mutating func record(_ bpm: BPMType) {
        while bpmHistory.count > countLimit {
            bpmHistory.remove(at: 0)
        }
        bpmHistory.append(bpm)
        calculate()
    }

    var bpmStable: Bool {
        guard bpmHistory.count > 1 else { return true }

        let stable = bpmHistory[bpmHistory.count - 1] == bpmHistory[bpmHistory.count - 2]
        return stable
    }

    mutating private func calculate() {
        guard bpmHistory.count > 1 else { results = (bpmHistory[0], 0); return }
        let tuple = bpmHistory.meanAndStdDev()
        results = (tuple.mean, tuple.std)
    }
}

/// Value Smoothing is for smoothing out high frequency noise
/// It simply applies a weight between a new value and a
/// prior stored smoothed value using a factor give at initialization.
struct ValueSmoothing {
    var smoothed: Float64
    let factor: Float64
    let priorDataFactor: Float64

    init(factor fact: Float64) {
        factor = fact
        priorDataFactor = Float64(1.0) - factor
        smoothed = 0
    }

    mutating func smoothed(_ newValue: Float64) -> Float64 {
        if smoothed == 0 {
            smoothed = newValue
        } else {
            smoothed = (newValue * factor) + (smoothed * priorDataFactor)
        }
        return smoothed
    }
}
