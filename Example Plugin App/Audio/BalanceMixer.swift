//
//  BalanceMixer.swift
//  AU Example App
//
//  Created by Jeff Cooper on 2/4/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
/// Based of AKDryWetMixer but adding functions for connecting inputs after init
///
class BalanceMixer: AKNode, AKInput {
    fileprivate let mixer = AKMixer()

    /// Balance (Default 0.5)
    @objc open dynamic var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            setGainsViaBalance()
        }
    }

    fileprivate var input1Attenuator = AKMixer()
    fileprivate var input2Attentuator = AKMixer()

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    override init() {
        super.init()
        avAudioNode = mixer.avAudioNode
        self.input1Attenuator.connect(to: mixer)
        self.input2Attentuator.connect(to: mixer)

        setGainsViaBalance()
    }

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    @objc public convenience init(_ input1: AKNode, _ input2: AKNode, balance: Double = 0.5) {
        self.init()

        connectInput1(using: input1)
        connectInput2(using: input2)
        self.balance = balance
    }

    public var inputNode: AVAudioNode {
        return input1Attenuator.avAudioUnitOrNode
    }

    func connectInputs(input1: AKNode, input2: AKNode) {
        connectInput1(using: input1)
        connectInput2(using: input2)
    }
    
    func connectInput1(using node: AKNode) {
        node.connect(to: input1Attenuator)
    }

    func connectInput2(using node: AKNode) {
        node.connect(to: input2Attentuator)
    }

    private func setGainsViaBalance() {
        input1Attenuator.volume = 1 - balance
        input2Attentuator.volume = balance
    }

}
