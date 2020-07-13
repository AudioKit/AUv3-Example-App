//
//  AppSettingDataManager.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit
import Disk

extension ParentController {

    // Convert App Settings to Controls and vice-versa
    func setDefaultsFromAppSettings() {

        keyboardView.velocitySetting = KeyboardVelocitySetting(rawValue: appSettings.velocitySetting) ?? .fixed
        conductor?.velocityTaper = appSettings.velocityTaper

        // MIDI
        conductor?.midiChannelIn = MIDIByte(appSettings.midiChannel)
        conductor?.omniMode = appSettings.omniMode

        conductor?.backgroundAudioEnabled = appSettings.backgroundAudioOn

        // Set Buffer
        AKSettings.bufferLength = AKSettings.BufferLength(rawValue: appSettings.bufferLengthRawValue) ?? .short
        do {
            try AKTry {
                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
            }
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to " +
                "\(AKSettings.bufferLength.duration) ( = \(AKSettings.bufferLength.samplesCount) samples)")
            AKLog("AKSettings Error: \(error))")
        }
        
        // MIDI Learn
        conductor?.assignMIDICCs(definitions: appSettings.midiCCs)

        // keyboard
        keyboardView.labelMode = appSettings.labelMode
        keyboardView.octaveCount = appSettings.octaveRange
        keyboardView.darkMode = appSettings.darkMode
        keyboardView.currentVelocity = MIDIVelocity(appSettings.velocity)
        conductor?.pitchBendUpperSemitones = Float(appSettings.pitchBendUpperSemitones)
        conductor?.pitchBendLowerSemitones = Float(appSettings.pitchBendLowerSemitones)
        keyboardView.setNeedsDisplay()
    }

    func updateAndSaveAppSettings() {

        // MIDI
        appSettings.midiChannel = Int(conductor?.midiChannelIn ?? 0)
        appSettings.omniMode = conductor?.omniMode ?? true

        appSettings.bufferLengthRawValue = AKSettings.bufferLength.rawValue
        appSettings.backgroundAudioOn = conductor?.backgroundAudioEnabled ?? false

        // MIDI Learn

        appSettings.midiCCs = conductor?.midiDefinitions ?? [MIDICCDefinition]()

        // keyboard
        appSettings.labelMode = keyboardView.labelMode
        appSettings.octaveRange = keyboardView.octaveCount
        appSettings.darkMode = keyboardView.darkMode
        appSettings.velocitySetting = keyboardView.velocitySetting.rawValue
        appSettings.velocity = Int(keyboardView.currentVelocity)
        if let conductor = conductor {
            appSettings.pitchBendUpperSemitones = conductor.pitchBendUpperSemitones
            appSettings.pitchBendLowerSemitones = conductor.pitchBendLowerSemitones
            appSettings.velocityTaper = conductor.velocityTaper
        }

        // State
        //    appSettings.currentPresetIndex = conductor.currentPreset.position

        saveAppSettings()
    }

    // Load App Settings from Device
    func loadSettingsFromDevice() {
        do {
            let retrievedSettingData = try Disk.retrieve("settings.json",
                                                         from: .sharedContainer(appGroupName: FileConstants.sharedContainer), as: Data.self)
            let settingsJSON = try? JSONSerialization.jsonObject(with: retrievedSettingData, options: [])

            if let settingDictionary = settingsJSON as? [String: Any] {
                appSettings = AppSetting(dictionary: settingDictionary)
            }

            setDefaultsFromAppSettings()
        } catch {
            AKLog("*** error loading")
        }
    }

    func saveAppSettings() {
        do {
            try Disk.save(appSettings,
                          to: .sharedContainer(appGroupName: FileConstants.sharedContainer),
                          as: "settings.json")
        } catch {
            AKLog("error saving")
        }
    }

}
