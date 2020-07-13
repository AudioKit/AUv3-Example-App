//
//  ExampleApp_AudioUnit
//  AU Example App
//
//  Created by Jeff Cooper on 1/8/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation
import CoreAudioKit
import AudioKit

public class ExampleApp_AudioUnit: AKAUv3ExtensionAudioUnit {

    var engine: AVAudioEngine!    // each unit needs its own avaudioEngine
    var conductor: Conductor!     // remember to add Conductor.swift to auv3 target
    var presetsList = PresetsManager.shared

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {

        deboog("AU Init")
        AKSettings.sampleRate = AVAudioSession.sharedInstance().sampleRate
        AKSettings.disableAVAudioSessionCategoryManagement = true
        engine = AVAudioEngine()
        AudioKit.engine = engine    // AudioKit.engine needs to be set early on

        conductor = Conductor()
        AudioKit.output = conductor.exampleInstrument.output   // plug everything in once we have the engine

        do { //this is where the audio unit really starts firing up with the data it needs
            try engine.enableManualRenderingMode(.offline, format: AKSettings.audioFormat, maximumFrameCount: 4096)

            conductor.startEngine()           // once the au is ready to go, you can go ahead and start processing
            //load preset?
            try super.init(componentDescription: componentDescription, options: options)
            try setOutputBusArrays()
        } catch {
            AKLog("Could not init audio unit")
            throw error
        }

        setParameterTree(tree: conductor.parameterTree)          // init parameterTree for controls
        setInternalRenderingBlock() // set internal rendering block to actually handle the audio buffers

        // Log component description values
        log(componentDescription)
    }

    override public var factoryPresets: [AUAudioUnitPreset]? {
        var presets = [AUAudioUnitPreset]()
        let factoryPresets = presetsList.presets
        for preset in factoryPresets {
            let auPreset = AUAudioUnitPreset()
            auPreset.name = preset.name
            auPreset.number = preset.position
            presets.append(auPreset)
        }
        return presets
    }

    override public var currentPreset: AUAudioUnitPreset? {
        get { // fixme: this code never gets called? is that by design?
            let auPreset = AUAudioUnitPreset()
            if let currentPreset = conductor.currentPreset {
                auPreset.name = currentPreset.name
                auPreset.number = currentPreset.position
            }
            return auPreset
        }
        set(newValue) {
            guard let presetToLoad = presetsList.presets.first(where: {$0.position == newValue?.number })
                else { return }
            conductor.loadPreset(presetToLoad)
        }
    }

    override public var supportsUserPresets: Bool {
        return true
    }

    override public var fullState: [String : Any]? {
        get {
            deboog("accessing fullstate")
            return conductor.allParameters.reduce(into: [String : Any]()) { $0[$1.identifier] = $1.value }
        }
        set {
            deboog("setting fullstate")
        }
    }

    override public var fullStateForDocument: [String : Any]? {
        get {
            deboog("accessing fullStateForDocument")
            let presetField = [ "currentPreset" : conductor.currentPreset?.position as Any ]
            return presetField
        }
        set {
            deboog("setting fullstate for document")
        }
    }

    private func setParameterTree(tree: AUParameterTree) {
        _parameterTree = tree
    }

    private func handleEvents(eventsList: AURenderEvent?, timestamp: UnsafePointer<AudioTimeStamp>) {
        var nextEvent = eventsList
        while nextEvent != nil {
            if nextEvent!.head.eventType == .MIDI {
                handleMIDI(midiEvent: nextEvent!.MIDI, timestamp: timestamp)
            } else if (nextEvent!.head.eventType == .parameter ||  nextEvent!.head.eventType == .parameterRamp) {
                handleParameter(parameterEvent: nextEvent!.parameter, timestamp: timestamp)
            }
            nextEvent = nextEvent!.head.next?.pointee
        }
    }

    private func setInternalRenderingBlock() {
        self._internalRenderBlock = { [weak self] (actionFlags, timestamp, frameCount, outputBusNumber,
            outputData, renderEvent, pullInputBlock) in
            guard let self = self else { return 1 } //error code?
            if let eventList = renderEvent?.pointee {
                self.handleEvents(eventsList: eventList, timestamp: timestamp)
            }
            //            self.handleMusicalContext()
            //            self.handleTransportState()

            // this is the line that actually produces sound using the buffers, keep it at the end
            _ = self.engine.manualRenderingBlock(frameCount, outputData, nil)
            return noErr
        }
    }

    private func log(_ acd: AudioComponentDescription) {

        let info = ProcessInfo.processInfo
        print("\nProcess Name: \(info.processName) PID: \(info.processIdentifier)\n")

        let message = """
        ExampleApp_Demo (
                  type: \(acd.componentType.stringValue)
               subtype: \(acd.componentSubType.stringValue)
          manufacturer: \(acd.componentManufacturer.stringValue)
                 flags: \(String(format: "%#010x", acd.componentFlags))
        )
        """
        print(message)
    }

    override public func allocateRenderResources() throws {
        do {
            try engine.enableManualRenderingMode(.offline, format: outputBus.format, maximumFrameCount: 4096)
            AKSettings.disableAVAudioSessionCategoryManagement = true
            let sessionSize = AKSettings.session.sampleRate * AKSettings.session.ioBufferDuration
            if let length = AKSettings.BufferLength.init(rawValue: Int(sessionSize.rounded())) {
                AKSettings.bufferLength = length
            }
            AKSettings.sampleRate = outputBus.format.sampleRate
            conductor.startEngine()
            try super.allocateRenderResources()
        } catch {
            return
        }
        self.mcb = self.musicalContextBlock
        self.tsb = self.transportStateBlock
        self.moeb = self.midiOutputEventBlock

    }

    override public func deallocateRenderResources() {
        engine.stop()
        super.deallocateRenderResources()
        self.mcb = nil
        self.tsb = nil
        self.moeb = nil
    }

    private func handleParameter(parameterEvent event: AUParameterEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
                // accurate to buffer size, when AKNodes support control signals w/ buffer offsets, use this code to get offset
        //        let diff = Float64(parameterPointer.eventSampleTime) - timestamp.pointee.mSampleTime
        //        let offset = MIDITimeStamp(UInt32(max(0, diff)))
            parameterTree?.parameter(withAddress: event.parameterAddress)?.value = event.value
    }

    private func handleMIDI(midiEvent event: AUMIDIEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
        // if you've made it this far, howdy! handle the raw midi bytes however you need to
        let diff = Float64(event.eventSampleTime) - timestamp.pointee.mSampleTime
        let offset = MIDITimeStamp(UInt32(max(0, diff)))
        let midiEvent = AKMIDIEvent(data: [event.data.0, event.data.1, event.data.2])
        guard let statusType = midiEvent.status?.type else { return }
        if statusType == .noteOn {
            if midiEvent.data[2] == 0 {
                receivedMIDINoteOff(noteNumber: event.data.1, channel: midiEvent.channel ?? 0, offset: offset)
            } else {
                receivedMIDINoteOn(noteNumber: event.data.1, velocity: event.data.2,
                                   channel: midiEvent.channel ?? 0, offset: offset)
            }
        } else if statusType == .noteOff {
            receivedMIDINoteOff(noteNumber: event.data.1, channel: midiEvent.channel ?? 0, offset: offset)
        } else if statusType == .controllerChange {
            let info = ["channel" : midiEvent.channel ?? 0, "controller" : event.data.1, "value" : event.data.2]
            LocalNotificationCenter.sharedInstance.center.post(name: .MIDIController, object: conductor, userInfo: info)
            conductor.receivedMIDIController(event.data.1, value: event.data.2, channel: midiEvent.channel ?? 0)
        } else if statusType == .pitchWheel, let pitchAmount = midiEvent.pitchbendAmount, let channel = midiEvent.channel {
            conductor.receivedMIDIPitchWheel(pitchAmount, channel: channel)
        } else {
            deboog("non midi note event")
        }
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel,
                            offset: MIDITimeStamp) {
        conductor.playNote(noteNum: noteNumber, velocity: velocity, channel: channel, offset: offset)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp) {
        conductor.stopNote(noteNum: noteNumber, channel: channel, offset: offset)
    }
    
    // Boolean indicating that this AU can process the input audio in-place
    // in the input buffer, without requiring a separate output buffer.
    public override var canProcessInPlace: Bool {
        return true
    }

    override public func parametersForOverview(withCount count: Int) -> [NSNumber] {
        deboog("Host wants the best \(count) parameters")

        // AUM asks for 1
        if count == 1 {
            return [NSNumber(value: conductor.tremoloDepthControl.address)] // Should point to Layer Mix
        }

        // Garage band asks for 4 or 8
        let best4: [NSNumber] = [NSNumber(value: conductor.tremoloDepthControl.address),
                                 NSNumber(value: conductor.tremoloRateControl.address),
                                 NSNumber(value: conductor.releaseControl.address),
                                 NSNumber(value: conductor.reverbMixControl.address)]
        let secondbest4: [NSNumber] = [NSNumber(value: conductor.reverbSizeControl.address),
                                       NSNumber(value: conductor.volumeMainControl.address),
                                       NSNumber(value: conductor.autopanEnableControl.address),
                                       NSNumber(value: conductor.tuningControl.address)]
        if count == 4 {
            return best4
        }
        if count == 8 {
            return best4 + secondbest4
        }

        // Some other number requested
        var returnArray = [NSNumber]()
        for parameter in parameterTree!.allParameters {
            if returnArray.count == count {
                return returnArray
            } else {
                returnArray.append(NSNumber(value: parameter.address))
            }
        }
        return returnArray
    }
}

extension FourCharCode {
    var stringValue: String {
        let value = CFSwapInt32BigToHost(self)
        let bytes = [0, 8, 16, 24].map { UInt8(value >> $0 & 0x000000FF) }
        guard let result = String(bytes: bytes, encoding: .macOSRoman) else {
            return "fail"
        }
        return result
    }
}

open class AKAUv3ExtensionAudioUnit: AUAudioUnit {

    var mcb: AUHostMusicalContextBlock?
    var tsb: AUHostTransportStateBlock?
    var moeb: AUMIDIOutputEventBlock?

    // Parameter tree stuff (for automation + control)
    open var _parameterTree: AUParameterTree!
    override open var parameterTree: AUParameterTree? {
        get { return self._parameterTree }
        set { _parameterTree = newValue }
    }

    // Internal Render block stuff
    open var _internalRenderBlock: AUInternalRenderBlock!
    override open var internalRenderBlock: AUInternalRenderBlock {
        return self._internalRenderBlock
    }

    // Default OutputBusArray stuff you will need
    var outputBus: AUAudioUnitBus!
    open var _outputBusArray: AUAudioUnitBusArray!
    override open var outputBusses: AUAudioUnitBusArray {
        return self._outputBusArray
    }
    open func setOutputBusArrays() throws {
        outputBus = try AUAudioUnitBus(format: AKSettings.audioFormat)
        self._outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])
    }

    override open func supportedViewConfigurations(_ availableViewConfigurations: [AUAudioUnitViewConfiguration]) -> IndexSet {
        var index = 0
        var returnValue = IndexSet()

        for configuration in availableViewConfigurations {
            print("width", configuration.width)
            print("height", configuration.height)
            print("has controller", configuration.hostHasController)
            print("")
            returnValue.insert(index)
            index += 1
        }
        return returnValue // Support everything
    }

    override open func allocateRenderResources() throws {
        do {
            try super.allocateRenderResources()
        } catch {
            return
        }

        self.mcb = self.musicalContextBlock
        self.tsb = self.transportStateBlock
        self.moeb = self.midiOutputEventBlock

    }

    override open func deallocateRenderResources() {
        super.deallocateRenderResources()
        self.mcb = nil
        self.tsb = nil
        self.moeb = nil
    }

}
