//
//  Conductor.swift
//  AU Example Code
//
//  Created by Jeff Cooper on 1/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class Conductor {

    let uid = UUID().uuidString
    var exampleInstrument = ExampleInstrument()
    var midi = AKManager.midi
    var testOsc = AKOscillator(waveform: AKTable(.square))
    var audioQueue = DispatchQueue.init(label: "audioQueue")
    var parameterTree = AUParameterTree()
    var volumeMainControl = ExampleInstrumentParameter(.volume)
    var tremoloRateControl = ExampleInstrumentParameter(.tremoloRate)
    var tremoloDepthControl = ExampleInstrumentParameter(.tremoloDepth)
    var autopanEnableControl = ExampleInstrumentParameter(.autopanEnable)
    var autopanRateControl = ExampleInstrumentParameter(.autopanRate)
    var attackControl = ExampleInstrumentParameter(.attack)
    var decayControl = ExampleInstrumentParameter(.decay)
    var sustainControl = ExampleInstrumentParameter(.sustain)
    var releaseControl = ExampleInstrumentParameter(.release)
    var tuningControl = ExampleInstrumentParameter(.tuningSemi)
    var autopanDepthControl = ExampleInstrumentParameter(.autopanDepth)
    var reverbEnableControl = ExampleInstrumentParameter(.reverbEnable)
    var reverbSizeControl = ExampleInstrumentParameter(.reverbSize)
    var reverbMixControl = ExampleInstrumentParameter(.reverbMix)
    var stereoWidenEnableControl = ExampleInstrumentParameter(.stereoWidenEnable)
    var pitchBendUpperSemitones = AudioConstants.pitchBendSemitonesDefault
    var pitchBendLowerSemitones = AudioConstants.pitchBendSemitonesDefault
    var velocityTaper = AudioConstants.velocityTaperDefault

    var omniMode = true
    var midiChannelIn: MIDIChannel = 0 {
        didSet {
            exampleInstrument.core.channel = midiChannelIn
        }
    }
    var midiInputs = [MIDIInput]()
    var presetsList = PresetsManager.shared
    var holdMode = false

    var backgroundAudioEnabled = false
    private var isSleeping = false

    var allParameterControls: [ExampleInstrumentParameter] {
        return [volumeMainControl, tremoloRateControl, tremoloDepthControl,
        autopanEnableControl, autopanRateControl, attackControl, decayControl, sustainControl, releaseControl, tuningControl, autopanDepthControl,
        reverbEnableControl, reverbSizeControl, reverbMixControl, stereoWidenEnableControl]
    }
    var allParameters: [AUParameter] {
        return allParameterControls.map({ $0.param })
    }
    var modwheelDest: ModwheelDestination = .vibrato {
        didSet {
            switch modwheelDest {
            case .tremolo:
                exampleInstrument.setVibrato(normalized: 0)
            case .vibrato:
                break
            }
        }
    }
    private var modValue: MIDIByte = 0

    init() {
        deboog("inited conductor \(uid)")
        setupParameters()
        parameterTree = AUParameterTree(children: allParameters)
        createParameterSetters()
        createParameterGetters()
        createParameterDisplays()
        resetAllToDefaults()
    }
    
    var currentPreset: InstrumentPreset?
    func loadPreset(_ preset: InstrumentPreset) {
        deboog("loading preset \(preset.name)")
        for param in allParameterControls {
            param.value = preset.getValueForParam(param: param)
        }
        modwheelDest = preset.modWheelDestination
        currentPreset = preset
        LocalNotificationCenter.sharedInstance.center.post(name: .PresetLoaded, object: self.exampleInstrument.uid,
                                                               userInfo: ["preset" : self.currentPreset ?? preset])
    }


    func setPresetWithoutLoading(presetUID: String) {
        currentPreset = PresetsManager.shared.presets.first(where: {$0.uid == presetUID})
        if let preset = currentPreset {
            LocalNotificationCenter.sharedInstance.center.post(name: .PresetLoaded, object: self.exampleInstrument.uid,
                                                                   userInfo: ["preset" : preset])
        }
    }
    private func displayAllParams() {
        for param in allParameters {
            deboog("have param \(parameterTree.parameter(withAddress: param.address)?.displayName ?? "none")")
        }
    }
    
    func resetAllToDefaults() {
        resetGlobalValues()
    }

    private func resetGlobalValues() {
        for param in allParameterControls {
            param.reset()
        }
    }

    private func sendNotificationFor(param: BaseParameter, value: Float) {
        LocalNotificationCenter.sharedInstance.center.post(name: Notification.Name(param.identifier),
                                                           object: exampleInstrument.uid,
                                                           userInfo: ["normalized" : value,
                                                                      "param" : param])
    }

    private func createParameterSetters() {
        parameterTree.implementorValueObserver = { [weak self] param, floatValue in
            guard let strongSelf = self else { return }

            if param.identifier == strongSelf.volumeMainControl.identifier {
                strongSelf.setVolume(normalized: floatValue)
            }
            if param.identifier == strongSelf.tremoloRateControl.identifier {
                strongSelf.setTremoloRate(normalized: floatValue)
            }
            if param.identifier == strongSelf.tremoloDepthControl.identifier {
                strongSelf.setTremoloDepth(normalized: floatValue)
            }
            if param.identifier == strongSelf.autopanEnableControl.identifier {
                strongSelf.setAutopanEnable(normalized: floatValue)
            }
            if param.identifier == strongSelf.autopanRateControl.identifier {
                strongSelf.setAutopanRate(normalized: floatValue)
            }
            if param.identifier == strongSelf.attackControl.identifier {
                strongSelf.setAttack(normalized: floatValue)
            }
            if param.identifier == strongSelf.decayControl.identifier {
                strongSelf.setDecay(normalized: floatValue)
            }
            if param.identifier == strongSelf.sustainControl.identifier {
                strongSelf.setSustain(normalized: floatValue)
            }
            if param.identifier == strongSelf.releaseControl.identifier {
                strongSelf.setRelease(normalized: floatValue)
            }
            if param.identifier == strongSelf.tuningControl.identifier {
                strongSelf.setTuning(normalized: floatValue)
            }
            if param.identifier == strongSelf.autopanDepthControl.identifier {
                strongSelf.setAutopanDepth(normalized: floatValue)
            }
            if param.identifier == strongSelf.reverbEnableControl.identifier {
                strongSelf.setReverbEnable(normalized: floatValue)
            }
            if param.identifier == strongSelf.reverbSizeControl.identifier {
                strongSelf.setReverbSize(normalized: floatValue)
            }
            if param.identifier == strongSelf.reverbMixControl.identifier {
                strongSelf.setReverbMix(normalized: floatValue)
            }
            if param.identifier == strongSelf.stereoWidenEnableControl.identifier {
                strongSelf.setStereoWidenEnable(normalized: floatValue)
            }
            //send notification after setting
            if let baseParam = BaseParameter(address: param.address) {
                strongSelf.sendNotificationFor(param: baseParam, value: floatValue)
            }
        }
    }

    private func createParameterGetters() {
        parameterTree.implementorValueProvider = { [weak self] param in
            guard let self = self else { return 0 }
            let exampleInstrument = self.exampleInstrument
            if param == self.volumeMainControl.param {
                return BaseParameter.volume.getnormalizedValue(for: exampleInstrument.masterAttenuator.volume)
            }
            if param == self.tremoloRateControl.param {
                return BaseParameter.tremoloRate.getnormalizedValue(for: exampleInstrument.tremolo.frequency)
            }
            if param == self.tremoloDepthControl.param {
                return BaseParameter.tremoloDepth.getnormalizedValue(for: exampleInstrument.tremolo.depth)
            }
            if param == self.autopanEnableControl.param {
                return BaseParameter.autopanEnable.getnormalizedValue(for: exampleInstrument.autoPanMixer.balance)
            }
            if param == self.autopanRateControl.param {
                return BaseParameter.autopanRate.getnormalizedValue(for: exampleInstrument.autopan.frequency)
            }
            if param == self.attackControl.param {
                return BaseParameter.attack.getnormalizedValue(for: exampleInstrument.core.sampler1.attackDuration)
            }
            if param == self.decayControl.param {
                return BaseParameter.decay.getnormalizedValue(for: exampleInstrument.core.sampler1.decayDuration)
            }
            if param == self.sustainControl.param {
                return BaseParameter.sustain.getnormalizedValue(for: exampleInstrument.core.sampler1.sustainLevel)
            }
            if param == self.releaseControl.param {
                return BaseParameter.release.getnormalizedValue(for: exampleInstrument.core.sampler1.releaseDuration)
            }
            if param == self.tuningControl.param {
                return BaseParameter.tuningSemi.getnormalizedValue(for: exampleInstrument.core.sampler1Detune)
            }
            if param == self.autopanDepthControl.param {
                return BaseParameter.autopanDepth.getnormalizedValue(for: exampleInstrument.autopan.depth)
            }
            if param == self.reverbEnableControl.param {
                return BaseParameter.reverbEnable.getnormalizedValue(for: exampleInstrument.reverbInputBypass.volume)
            }
            if param == self.reverbSizeControl.param {
                return BaseParameter.reverbSize.getnormalizedValue(for: exampleInstrument.reverb.feedback)
            }
            if param == self.reverbMixControl.param {
                return BaseParameter.reverbMix.getnormalizedValue(for: exampleInstrument.reverbOutputAmplifier.volume)
            }
            if param == self.stereoWidenEnableControl.param {
                return BaseParameter.stereoWidenEnable.getnormalizedValue(for: exampleInstrument.fatten.dryWetMix.balance)
            }
            // if param == other values here...
            return 0
        }
    }
    private func createParameterDisplays() {
        parameterTree.implementorStringFromValueCallback = { [weak self] param, value in
            guard let _ = self else { return "" }
            if let floatValue = value?.pointee {
                let id = param.identifier
                if let instanceParam = self?.allParameters.first(where: { $0.identifier == id }) {

                }
                if let parameter = BaseParameter.init(rawValue: Int(param.address)) {
                    return parameter.getStringValue(for: floatValue)
                }
                // if param == other values here...
            }
            return String(format: "%.3f", value?.pointee ?? 0)
        }
    }

    func getRhodesParameterFrom(baseParam: BaseParameter) -> ExampleInstrumentParameter? {
        return allParameterControls.first(where: { $0.baseParameter == baseParam })
    }

    func playNote(noteNum: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, offset: MIDITimeStamp) {
        exampleInstrument.playNote(noteNumber: noteNum, velocity: processVelocity(velocity),
                        channel: channel, offset: offset)
    }
    
    func stopNote(noteNum: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp) {
        exampleInstrument.stopNote(noteNumber: noteNum, channel: channel, offset: offset)
    }

    func play() {
        playNote(noteNum: 60, velocity: 127, channel: 0, offset: 0)
    }

    func stop() {
        stopNote(noteNum: 60, channel: 127, offset: 0)
    }

    private func processVelocity(_ velocity: MIDIVelocity) -> MIDIVelocity {
        let newVelocity = UInt8(Double(velocity.normalized).normalized(from: 0...1, taper: velocityTaper) * 127)
        return newVelocity
    }

    func setPedal(_ down: Bool) {
        exampleInstrument.core.sampler1.sustainPedal(pedalDown: down)
        exampleInstrument.core.sampler2.sustainPedal(pedalDown: down)
    }

    func setPitchBend(normalized value: Float) {
        var bendSemi = 0.0
        if value >= 0.5 {
            let scale1 = Double.scaleEntireRange(Double(value), fromRangeMin: 0.5, fromRangeMax: 1.0,
                                                 toRangeMin: 0, toRangeMax: Double(pitchBendUpperSemitones))
            bendSemi = scale1
        } else {
            let scale1 = Double.scaleEntireRange(Double(value), fromRangeMin: 0.5, fromRangeMax: 0.0,
                                                 toRangeMin: 0, toRangeMax: Double(pitchBendLowerSemitones))
            bendSemi = -1.0 * scale1
        }
        exampleInstrument.pitchBend = Float(bendSemi)
    }

    func setSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        AKSettings.playbackWhileMuted = true
    }
    
    func startEngine() {
        try? AKManager.start()
    }

    func stopEngine() {
        try? AKManager.stop()
    }

    func setModwheel(_ value: MIDIByte) {
        modValue = value
        switch modwheelDest {
        case .tremolo:
            tremoloDepthControl.value = value.normalized
            sendNotificationFor(param: .tremoloDepth, value: value.normalized)
        case .vibrato:
            exampleInstrument.setVibrato(normalized: value.normalized)
        }
    }

    private func setupParameters() {
        allParameterControls.forEach({ $0.exampleInstrumentID = exampleInstrument.uid })
    }

    @objc func sleepIfNeeded() {
        if !backgroundAudioEnabled {
            try? AKManager.stop()
            try? AVAudioSession.sharedInstance().setActive(false)
            isSleeping = true
        }
    }

    @objc func wakeIfNeeded() {
        if isSleeping {
            try? AKManager.start()
            try? AKSettings.setSession(category: .playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            isSleeping = false
        }
    }

}
