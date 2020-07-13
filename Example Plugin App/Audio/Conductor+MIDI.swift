//
//  Conductor+MIDI.swift
//  Bass 808
//
//  Created by Jeff Cooper on 3/30/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

extension Conductor: AKMIDIListener {

    func receivedMIDISetupChange() {
        midi.inputNames.forEach { inputName in
            // check to see if input exists before adding it
            if midiInputs.firstIndex(where: { $0.name == inputName }) == nil {
                let newMIDI = MIDIInput(name: inputName, isOpen: true)
                midiInputs.append(newMIDI)
                midi.openInput(name: inputName)
            }
        }
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        guard channel == midiChannelIn || omniMode else { return }
        if velocity == 0 {
            receivedMIDINoteOff(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            playNote(noteNum: noteNumber, velocity: velocity, channel: channel, offset: offset)
            LocalNotificationCenter.sharedInstance.center.post(name: .KeyPressedViaMIDI,
                                                               object: exampleInstrument.uid,
                                                               userInfo: ["key" : noteNumber])
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        guard (channel == midiChannelIn || omniMode) && !holdMode else { return }
        stopNote(noteNum: noteNumber, channel: channel, offset: offset)
        LocalNotificationCenter.sharedInstance.center.post(name: .KeyReleasedViaMIDI,
                                                           object: exampleInstrument.uid,
                                                           userInfo: ["key" : noteNumber])
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        let normalized = Float(Double(pitchWheelValue).normalized(from: 0 ... 16384)) //16384 = 14bit max
        setPitchBend(normalized: normalized)
        LocalNotificationCenter.sharedInstance.center.post(name: .PitchbendViaMIDI, object: exampleInstrument.uid,
                                                           userInfo: ["pitchBend" : normalized])
    }


    // MIDI Program/Patch Change
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        guard channel == midiChannelIn || omniMode else { return }
        if let newPreset = presetsList.getPresetViaPC(position: Int(program)) {
            loadPreset(newPreset)
        }
    }

    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        guard channel == midiChannelIn || omniMode else { return }

        let matchingControls = allParameterControls.filter({ $0.midiControllers.contains(controller) })
        matchingControls.forEach { control in
            control.value = value.normalized
        }

        // MIDI Controller Handling
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            setModwheel(value)
            LocalNotificationCenter.sharedInstance.center.post(name: .ModWheelViaMIDI, object: exampleInstrument.uid,
                                                               userInfo: ["modwheel" : value])

        // Sustain Pedal
        case AKMIDIControl.damperOnOff.rawValue:
            setPedal(value > 63)
        default:
            break
        }

    }

}

