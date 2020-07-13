//
//  Conductor+Setters.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/15/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

extension Conductor {

    func setVolume(normalized: Float) {
        exampleInstrument.masterAttenuator.volume = BaseParameter.volume.getDenormalizedValue(for: normalized)
    }
    func setTremoloRate(normalized: Float) {
        exampleInstrument.tremolo.frequency = BaseParameter.tremoloRate.getDenormalizedValue(for: normalized)
    }
    func setTremoloDepth(normalized: Float) {
        exampleInstrument.tremolo.depth = BaseParameter.tremoloDepth.getDenormalizedValue(for: normalized)
    }
    func setAutopanEnable(normalized: Float) {
        exampleInstrument.autoPanMixer.balance = BaseParameter.autopanEnable.getDenormalizedValue(for: normalized)
    }
    func setAutopanRate(normalized: Float) {
        exampleInstrument.autopan.frequency = BaseParameter.autopanRate.getDenormalizedValue(for: normalized)
    }
    func setAttack(normalized: Float) {
        exampleInstrument.core.sampler1.attackDuration = BaseParameter.attack.getDenormalizedValue(for: normalized)
    }
    func setDecay(normalized: Float) {
        exampleInstrument.core.sampler1.decayDuration = BaseParameter.decay.getDenormalizedValue(for: normalized)
    }
    func setSustain(normalized: Float) {
        exampleInstrument.core.sampler1.sustainLevel = BaseParameter.sustain.getDenormalizedValue(for: normalized)
    }
    func setRelease(normalized: Float) {
        exampleInstrument.core.sampler1.releaseDuration = BaseParameter.release.getDenormalizedValue(for: normalized)
    }
    func setTuning(normalized: Float) {
        exampleInstrument.core.sampler1Detune = BaseParameter.tuningSemi.getDenormalizedValue(for: normalized)
    }
    func setAutopanDepth(normalized: Float) {
        exampleInstrument.autopan.depth = BaseParameter.autopanDepth.getDenormalizedValue(for: normalized)
    }
    func setReverbEnable(normalized: Float) {
        exampleInstrument.reverbInputBypass.volume = BaseParameter.reverbEnable.getDenormalizedValue(for: normalized)
    }
    func setReverbSize(normalized: Float) {
        exampleInstrument.reverb.feedback = BaseParameter.reverbSize.getDenormalizedValue(for: normalized)
    }
    func setReverbMix(normalized: Float) {
        exampleInstrument.reverbOutputAmplifier.volume = BaseParameter.reverbMix.getDenormalizedValue(for: normalized)
    }
    func setStereoWidenEnable(normalized: Float) {
        exampleInstrument.fatten.dryWetMix.balance = BaseParameter.stereoWidenEnable.getDenormalizedValue(for: normalized)
    }
}
