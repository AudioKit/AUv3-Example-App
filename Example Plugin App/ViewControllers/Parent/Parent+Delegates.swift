//
//  Parent+Delegates.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/18/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

// **********************************************************
// MARK: - KEYBOARD DELEGATE
// **********************************************************

extension ParentController: AKKeyboardDelegate {

    public func noteOn(note: MIDINoteNumber, velocity: MIDIVelocity, offset: MIDITimeStamp = 0) {
        guard let conductor = conductor else { return }
        conductor.exampleInstrument.playNote(noteNumber: note, velocity: velocity, channel: conductor.midiChannelIn, offset: offset)
    }

    public func noteOff(note: MIDINoteNumber, offset: MIDITimeStamp = 0) {
        guard let conductor = conductor else { return }
        conductor.exampleInstrument.stopNote(noteNumber: note, channel: conductor.midiChannelIn, offset: offset)
    }
}

// **********************************************************
// MARK: - SETTINGS DELEGATES
// **********************************************************

extension ParentController: MIDISettingsPopOverDelegate {

    func resetMIDILearn() {
        midiKnobs.forEach { $0.midiCC = 255 }
        updateAndSaveAppSettings()
    }

    func didSelectMIDIChannel(newChannel: Int) {
        if newChannel > -1 {
            conductor?.midiChannelIn = MIDIByte(newChannel)
            conductor?.omniMode = false
        } else {
            conductor?.midiChannelIn = 0
            conductor?.omniMode = true
        }
        updateAndSaveAppSettings()
    }

    func didToggleBackgroundAudio(state: Bool) {
        conductor?.backgroundAudioEnabled = state
        updateAndSaveAppSettings()
    }

    func didSetBuffer() {
        updateAndSaveAppSettings()
    }

    func didResetPresets() {
        // presetsController.resetFactoryPresets()
    }
}


extension ParentController: KeySettingsPopOverDelegate {

    func didFinishSelecting(octaveRange: Int, labelMode: Int, darkMode: Bool) {
        keyboardView.octaveCount = octaveRange
        keyboardView.labelMode = labelMode
        keyboardView.darkMode = darkMode
        keyboardView.setNeedsDisplay()
        updateAndSaveAppSettings()
    }
}

extension ParentController: VelocityPopOverDelegate {

    func didFinishSelecting(velocitySetting: KeyboardVelocitySetting) {
        keyboardView.velocitySetting = velocitySetting
        updateAndSaveAppSettings()
    }

    func didFinishSelecting(taper: VelocityTaper) {
        conductor?.velocityTaper = taper.taperValue
        updateAndSaveAppSettings()
    }
}


extension ParentController: ModWheelDelegate {

    func didSelectRouting(newDestination: Int) {
        if let destination = ModwheelDestination(rawValue: newDestination) {
            conductor?.modwheelDest = destination
        }
    }

    func pitchbendUpperDidChange(newMax: Double) {
        conductor?.pitchBendUpperSemitones = Float(newMax)
        updateAndSaveAppSettings()
    }

    func pitchBendLowerDidChange(newMin: Double) {
        conductor?.pitchBendLowerSemitones = Float(newMin)
        updateAndSaveAppSettings()
    }

}
