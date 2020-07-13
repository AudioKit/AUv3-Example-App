//
//  RhodesInstrument.swift
//  AU Example Code
//
//  Created by Jeff Cooper on 1/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class ExampleInstrument {
    var uid = UUID().uuidString
    var core = GeneratorBank()
    var layerMixer = AKMixer()
    var tremolo = AKTremolo()
    var fatten = Fatten()
    var autopan = AKAutoPanner()
    var autoPanMixer = BalanceMixer()
    var reverbInputBypass = AKMixer()
    var reverbOutputAmplifier = AKMixer()
    var reverb = AKCostelloReverb()
    var reverbMixer = AKMixer()
    var verbLimiter = AKPeakLimiter()

    var masterAttenuator = AKMixer()
    var masterAmplifier = AKBooster()
    var finalDCBlock = AKDCBlock()
    var output: AKNode {
        return finalDCBlock
    }
    private var vibratoSemitones = 0.25

    var availableSounds = ["LoTines", "Noise"]

    var pitchBend: Float {
        set { core.sampler1PitchBend = Double(newValue) }
        get { return Float(core.sampler1PitchBend) }
    }

    init() {
        setupRoute()
        buildPianoSoundset()
        setupInitialValues()
    }

    func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, offset: MIDITimeStamp) {
        core.play(note: noteNumber, velocity: velocity, channel: channel, offset: offset)
    }

    func stopNote(noteNumber: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp) {
        core.stop(note: noteNumber, channel: channel, offset: offset)
    }
    
    private func buildPianoSoundset() {
        core.sampler1.stopAllVoices()
        core.buildSoundfont(sampler: core.sampler1, directory: FileConstants.sampleFolder,
                            bundleID: FileConstants.assetsID,
                            filetype: "wav", attack: 0, decay: 0, sustain: 1, release: 0.333,
                            velocitySplits: [
                                AudioConstants.keyVelocityLimit1,
                                AudioConstants.keyVelocityLimit2])
        core.sampler1.restartVoices()
    }

    func setupRoute() {
        core.sampler1 >>> tremolo
        tremolo >>> autopan
        autoPanMixer.connectInputs(input1: tremolo, input2: autopan)
        autoPanMixer >>> fatten
        fatten >>> layerMixer
        layerMixer >>> reverbInputBypass
        reverbInputBypass >>> reverb
        reverb >>> verbLimiter
        verbLimiter >>> reverbOutputAmplifier
        layerMixer >>> reverbMixer
        reverbOutputAmplifier >>> reverbMixer
        reverbMixer >>> masterAttenuator
        masterAttenuator >>> masterAmplifier
        masterAmplifier >>> finalDCBlock
    }

    func setupInitialValues() {
        // these are default values for the RhodesInstrument alone - the au parameter defaults will override these later
        autoPanMixer.balance = Double(BaseParameter.autopanEnable.defaultDenormalized)
        tremolo.depth = Double(BaseParameter.tremoloDepth.defaultDenormalized)
        tremolo.frequency = Double(BaseParameter.tremoloRate.defaultDenormalized)
        autopan.frequency = Double(BaseParameter.autopanRate.defaultDenormalized)
        autopan.depth = Double(BaseParameter.autopanDepth.defaultDenormalized)
        autoPanMixer.balance = Double(BaseParameter.autopanEnable.defaultDenormalized)
        reverbInputBypass.volume = 0
        reverb.feedback = Double(BaseParameter.reverbSize.defaultDenormalized)
        verbLimiter.attackDuration = 0.001 // Secs
        verbLimiter.decayDuration = 0.01 // Secs
        verbLimiter.preGain = 3 // dB
        masterAmplifier.gain = 1.0
    }

    func setVibrato(normalized: Float) {
        core.sampler1.vibratoDepth = vibratoSemitones * Double(normalized)
    }

}
