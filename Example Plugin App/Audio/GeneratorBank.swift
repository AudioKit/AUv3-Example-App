//
//  GeneratorBank.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka on 6/25/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import ExampleApp_Assets

class GeneratorBank: AKMIDIInstrument {

    var globalbend: Double = 0.0 {
        didSet {
            sampler1.pitchBend = globalbend + sampler1Detune
            sampler2.pitchBend = globalbend + sampler2Detune
        }
    }

    var sampler1Detune: Double = 0.0 {
        didSet {
            sampler1.pitchBend = globalbend + sampler1PitchBend + sampler1Detune
        }
    }

    var sampler2Detune: Double = 0.0 {
        didSet {
            sampler2.pitchBend = globalbend + sampler2PitchAdjust + sampler2Detune
        }
    }

    var sampler1PitchBend: Double = 0.0 {
        didSet {
            sampler1.pitchBend = globalbend + sampler1PitchBend + sampler1Detune
        }
    }

    var sampler2PitchAdjust: Double = 0.0 {
        didSet {
            sampler2.pitchBend = globalbend + sampler2PitchAdjust + sampler2Detune
        }
    }

    var sampler1Range: ClosedRange<MIDINoteNumber> = 0...127
    var sampler2Range: ClosedRange<MIDINoteNumber> = 0...127

    var sampler1On = 1.0 {
        didSet {
            sampler1Mixer.volume = sampler1On // 1.0 or 0.0
        }
    }

    var sampler2On = 1.0 {
        didSet {
            sampler2Mixer.volume = sampler2On // 1.0 or 0.0
        }
    }

    var channel: MIDIChannel = 0

    var sampler1 = AKSampler()
    var sampler2 = AKSampler()

    var sampler1Mixer: AKMixer
    var sampler2Mixer: AKMixer

    var sampler1Panner: AKPanner
    var sampler2Panner: AKPanner

    var oscBalancer: AKDryWetMixer
    var sourceMixer: AKMixer

    var onNotes = Set<MIDINoteNumber>()

    var layer1VelocityMin = 0.0
    var layer1VelocityMax = 127.0
    var layer2VelocityMin = 0.0
    var layer2VelocityMax = 127.0

    init() {

        sampler1Panner = AKPanner(sampler1)
        sampler2Panner = AKPanner(sampler2)
        sampler1Mixer = AKMixer(sampler1Panner)
        sampler2Mixer = AKMixer(sampler2Panner)
        oscBalancer = AKDryWetMixer(sampler1Mixer, sampler2Mixer, balance: 0.0)
        sourceMixer = AKMixer(oscBalancer)

        super.init(midiInputName: "Test App 1")
        sampler1.masterVolume = 1.0
        sampler2.masterVolume = 1.0
        avAudioNode = sourceMixer.avAudioNode
    }

    /// AKMIDIInstrument Listening

    /// Function to start, play, or activate the node, all do the same thing
    override func start(noteNumber: MIDINoteNumber,
                        velocity: MIDIVelocity,
                        channel: MIDIChannel,
                        offset: MIDITimeStamp = 0) {
        print("deboog: noteOn start \(noteNumber)")
//        conductor.parentController.receivedMIDINoteOn(noteNumber: noteNumber, velocity: velocity, channel: channel, offset: offset)
    }
    override func stop(noteNumber: MIDINoteNumber,
                       channel: MIDIChannel,
                       offset: MIDITimeStamp = 0) {
        print("deboog: noteOff stop \(noteNumber)")
//        conductor.parentController.receivedMIDINoteOff(noteNumber: noteNumber, velocity: 0, channel: channel, offset: offset)
    }
    /// End AKMIDIInstrument Listening

    /// Function to start, play, or activate the node, all do the same thing
    func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        play1(note: note, velocity: velocity, channel: channel, offset: offset)
        play2(note: note, velocity: velocity, channel: channel, offset: offset)
    }

    func play1(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        if sampler1Range.contains(note) {
            let adjustedVelocity = scaleMIDIRangeToRange(velocity, min: layer1VelocityMin, max: layer1VelocityMax)
            if let unit = sampler1.avAudioUnit?.audioUnit {
                MusicDeviceMIDIEvent(unit, UInt32(AKMIDIStatus(type: .noteOn, channel: channel).byte),
                                     UInt32(note), UInt32(adjustedVelocity), UInt32(offset))
            }
        }
    }

    func play2(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, offset: MIDITimeStamp) {
        if sampler2Range.contains(note) {
            let adjustedVelocity = scaleMIDIRangeToRange(velocity, min: layer2VelocityMin, max: layer2VelocityMax)
            if let unit = sampler2.avAudioUnit?.audioUnit {
                MusicDeviceMIDIEvent(unit, UInt32(AKMIDIStatus(type: .noteOn, channel: channel).byte),
                                     UInt32(note), UInt32(adjustedVelocity), UInt32(offset))
            }
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    func stop1(note: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        if let unit = sampler1.avAudioUnit?.audioUnit {
            MusicDeviceMIDIEvent(unit, UInt32(AKMIDIStatus(type: .noteOff, channel: channel).byte),
                                 UInt32(note), 0, UInt32(offset))
        }
    }

    func stop2(note: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        if let unit = sampler2.avAudioUnit?.audioUnit {
            MusicDeviceMIDIEvent(unit, UInt32(AKMIDIStatus(type: .noteOff, channel: channel).byte),
                                 UInt32(note), 0, UInt32(offset))
        }
    }

    func stop(note: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        stop1(note: note, channel: channel, offset: offset)
        stop2(note: note, channel: channel, offset: offset)
    }

    func resetOnNotes(samplerNumber: Int) {
        for noteNumber in onNotes {
            if samplerNumber == 1 {
                guard sampler1Range.contains(noteNumber) else { return }
                let noteHz = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
                sampler1.stop(noteNumber: noteNumber)
                sampler1.play(noteNumber: noteNumber, velocity: 80, frequency: noteHz)
            } else {
                guard sampler2Range.contains(noteNumber) else { return }
                let noteHz = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
                sampler2.stop(noteNumber: noteNumber)
                sampler2.play(noteNumber: noteNumber, velocity: 80, frequency: noteHz)
            }
        }
    }

    func scaleMIDIRangeToRange(_ value: MIDIVelocity, min: Double, max: Double) -> MIDIVelocity {
        // Linear scale 0...127 entire range to another range
        return MIDIVelocity(Double.scaleEntireRange(Double(value), fromRangeMin: 0, fromRangeMax: 127, toRangeMin: Double(min), toRangeMax: Double(max)))
    }

    func clearSoundOfAllNotes() {
        for note in 0 ... 127 {
            sampler1.stop(noteNumber: MIDINoteNumber(note))
            sampler2.stop(noteNumber: MIDINoteNumber(note))
        }
    }

    func handleTuningChange() {
        for note in 0 ... 127 {
            let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: MIDINoteNumber(note))
            sampler1.setNoteFrequency(noteNumber: MIDINoteNumber(note), frequency: frequency)
            sampler2.setNoteFrequency(noteNumber: MIDINoteNumber(note), frequency: frequency)
        }
        sampler1.buildKeyMap()
        sampler2.buildKeyMap()
    }

    func buildSoundfont(sampler: AKSampler, directory: String, bundleID: String, filetype: String,
                        attack: Double = 0, decay: Double = 0, sustain: Double = 1, release: Double = 0.3,
                        velocitySplits: [UInt8] = [50, 114, 127]) { // 0-49, 50-113, 114-127)
        deboog("building AKSampler map")
        var startNote: MIDINoteNumber = 0
        var endNote: MIDINoteNumber = 0
        var lastProcessedNote: MIDINoteNumber?
        var currentSampleGroups = [SampleReference]()
        var sampleMaps = [SampleMap]()
        let directory = directory
        sampler.unloadAllSamples()
        if let bundle = Bundle(identifier: bundleID) {
            let paths = bundle.paths(forResourcesOfType: filetype, inDirectory: directory).sorted()
            for i in 0..<paths.count {
                let url = URL(fileURLWithPath: paths[i])
                let filename = url.deletingPathExtension().lastPathComponent
                //print ("FILENAME \(filename)")
                if let startNoteIndex = filename.endIndex(of: "NOTE "),
                    let endNoteIndex = filename.index(of: " VEL"),
                    let noteNumInt = Int(String(filename[startNoteIndex..<endNoteIndex])),
                    let startVelIndex = filename.endIndex(of: "VELOCITY "),
                    let velLevel = Int(String(filename[startVelIndex..<filename.endIndex]))
                {
                    let rootNoteNumber = MIDINoteNumber(noteNumInt)
                    let currentSample = SampleReference(path: paths[i],
                                                        rootNote: rootNoteNumber,
                                                        velocityLevel: velLevel)
                    currentSampleGroups.append(currentSample)
                    if let lastNote = lastProcessedNote {
                        if lastProcessedNote != rootNoteNumber { //we've moved to a new root note
                            let diff = rootNoteNumber - lastNote
                            endNote = rootNoteNumber - MIDINoteNumber(floor(Float(diff) / 2.0))
                            let nextGroupSample = currentSampleGroups.popLast()
                            let sampleMap = SampleMap(sampleRefs: currentSampleGroups,
                                                      highNote: endNote, lowNote: startNote)
                            sampleMaps.append(sampleMap)
                            currentSampleGroups.removeAll()
                            if let nextSample = nextGroupSample {
                                currentSampleGroups.append(nextSample)
                            }
                            startNote = endNote + 1
                        } else if i == paths.count - 1 { //last sample
                            startNote = endNote + 1
                            endNote = 127
                            let sampleMap = SampleMap(sampleRefs: currentSampleGroups,
                                                      highNote: endNote, lowNote: startNote)
                            sampleMaps.append(sampleMap)
                        }
                    }
                    lastProcessedNote = rootNoteNumber
                }
            }
            for sampleMap in sampleMaps {
                let root = sampleMap.sampleRefs[0].rootNote
                let start = sampleMap.lowNote
                let end = sampleMap.highNote
                var lastVelocity = -1
                var sampleIndex = 0
                for sample in sampleMap.sampleRefs {
                    // THE MEAT - build the sampleMaps here
                    let loVel = lastVelocity + 1
                    let hiVel = velocitySplits[sampleIndex]
                    if let file = try? AKAudioFile(forReading: URL(fileURLWithPath: sample.path)) {
                        let freq = Float(MIDINoteNumber(root).midiNoteToFrequency())
                        let desc = AKSampleDescriptor(noteNumber: Int32(root),
                                                      noteFrequency: freq,
                                                      minimumNoteNumber: Int32(start),
                                                      maximumNoteNumber: Int32(end),
                                                      minimumVelocity: Int32(loVel), maximumVelocity: Int32(hiVel),
                                                      isLooping: false,
                                                      loopStartPoint: 0,
                                                      loopEndPoint:  0,
                                                      startPoint: 0, endPoint: 0)
                        sampler.loadAKAudioFile(from: desc, file: file)
                        sampleIndex = (sampleIndex + 1) % sampleMap.sampleRefs.count
                        lastVelocity = Int(hiVel)
                    } else {
                        print("deboog: Unable to load sound \(sample.path) at \(start) to \(end) (root \(root))")
                    }
                }
            }
            sampler.buildKeyMap()
            sampler.attackDuration = attack
            sampler.decayDuration = decay
            sampler.sustainLevel = sustain
            sampler.releaseDuration = release
        }
    }

    func buildTestSoundfont() {
        if let path = Bundle.main.path(forResource: "KGRhodes DI - NOTE 060 VELOCITY 3.wav", ofType: nil, inDirectory: "Sounds/Sampler Instruments/samples"),
            let file = try? AKAudioFile(forReading: URL(fileURLWithPath: path)) {
            let desc = AKSampleDescriptor(noteNumber: 60,
            noteFrequency: Float(MIDINoteNumber(60).midiNoteToFrequency()),
            minimumNoteNumber: 0,
            maximumNoteNumber: 127,
            minimumVelocity: 0, maximumVelocity: 127,
            isLooping: false,
            loopStartPoint: 0,
            loopEndPoint: 0,
            startPoint: 0, endPoint: 0)
            sampler1.loadAKAudioFile(from: desc, file: file)
            sampler1.buildKeyMap()
        }
    }
}

struct SampleReference {
    var path: String
    var rootNote: MIDINoteNumber
    var velocityLevel: Int
}

struct SampleMap {
    var sampleRefs: [SampleReference]
    var highNote: MIDINoteNumber
    var lowNote: MIDINoteNumber
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
