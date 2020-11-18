//
//  whiteNoiseTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class WhiteNoiseTests: AKTestCase {

    var noise = AKOperationGenerator { _ in return AKOperation.whiteNoise() }

    override func setUp() {
        afterStart = { self.noise.start() }
        duration = 1.0
    }

    func testDefault() {
        output = noise
        AKTestMD5("3383b3631de1e37d309c4e35ff023c1b")
    }

    func testAmplitude() {
        noise = AKOperationGenerator { _ in
            return AKOperation.whiteNoise(amplitude: 0.456)
        }
        output = noise
        AKTestMD5("1c052b4e036810c10a6f6fae633daa91")
    }

    func testParameterSweep() {
        noise = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: self.duration)
            return AKOperation.whiteNoise(amplitude: line)
        }
        output = noise
        AKTestMD5("d5713a02d87070053570eeb6a75f3283")
    }

}
