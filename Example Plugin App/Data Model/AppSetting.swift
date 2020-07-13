//
//  AppSetting.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import Foundation

class AppSetting: Codable {

    var settingID = "main"
    var firstRun = true
    var isPreRelease = false
    var signedMailingList = false
    var backgroundAudioOn = false
    var midiChannel = 0
    var omniMode = true
    var pushNotifications = false
    var userEmail = ""
    var bonusPresets = false
    var bufferLengthRawValue = 7 // short
    var pitchBendUpperSemitones = AudioConstants.pitchBendSemitonesDefault
    var pitchBendLowerSemitones = AudioConstants.pitchBendSemitonesDefault
    var isEasterEggUnlocked = false
    var velocitySetting = 1 // Enum KeyboardVelocitySetting
    var velocityTaper = AudioConstants.velocityTaperDefault
    var launches = 0

    // Presets version
    var presetsVersion = 1.0

    // Platinum Edition
    var platinum = false

    // Keyboard
    var labelMode = 1
    var octaveRange = 2
    var darkMode = true
    var velocity = 85

    // Save State
    var currentBankIndex = 0
    var currentPresetIndex = 0
    var firstRunAsAUv3 = false

    // MIDI Learn Settings
    var midiCCs = [MIDICCDefinition]()

    init() {
    }

    // Init from Dictionary/JSON
    init(dictionary: [String: Any]) {

        settingID = dictionary["settingID"] as? String ?? settingID
        launches = dictionary["launches"] as? Int ?? launches
        firstRun = dictionary["firstRun"] as? Bool ?? firstRun
        firstRunAsAUv3 = dictionary["firstRunAsAUv3"] as? Bool ?? firstRunAsAUv3
        bonusPresets = dictionary["bonusPresets"] as? Bool ?? bonusPresets
        bufferLengthRawValue = dictionary["bufferLengthRawValue"] as? Int ?? bufferLengthRawValue
        pitchBendUpperSemitones = dictionary["pitchBendUpperSemitones"] as? Float ?? pitchBendUpperSemitones
        pitchBendLowerSemitones = dictionary["pitchBendLowerSemitones"] as? Float ?? pitchBendLowerSemitones
        platinum = dictionary["platinum"] as? Bool ?? platinum

        currentBankIndex = dictionary["currentBankIndex"] as? Int ?? currentBankIndex
        currentPresetIndex = dictionary["currentPresetIndex"] as? Int ?? currentPresetIndex

        isPreRelease = dictionary["isPreRelease"] as? Bool ?? isPreRelease
        signedMailingList = dictionary["signedMailingList"] as? Bool ?? signedMailingList
        presetsVersion = dictionary["presetsVersion"] as? Double ?? presetsVersion
        backgroundAudioOn = dictionary["backgroundAudioOn"] as? Bool ?? backgroundAudioOn
        midiChannel = dictionary["midiChannel"] as? Int ?? midiChannel
        omniMode = dictionary["omniMode"] as? Bool ?? omniMode
        pushNotifications = dictionary["pushNotifications"] as? Bool ?? pushNotifications
        userEmail = dictionary["userEmail"] as? String ?? userEmail
        isEasterEggUnlocked = dictionary["isEasterEggUnlocked"] as? Bool ?? isEasterEggUnlocked
        velocitySetting = dictionary["velocitySetting"] as? Int ?? velocitySetting
        velocityTaper = dictionary["velocityTaper"] as? Double ?? velocityTaper

        // Keyboard
        labelMode = dictionary["labelMode"] as? Int ?? labelMode
        octaveRange = dictionary["octaveRange"] as? Int ?? octaveRange
        darkMode = dictionary["darkMode"] as? Bool ?? darkMode
        velocity = dictionary["velocity"] as? Int ?? velocity

        // MIDI Learn
        let midiCCDefs = dictionary["midiCCs"] as? [[String : Any]]
        midiCCs = midiCCDefs?.compactMap({ MIDICCDefinition(with: $0)}) ?? midiCCs
        
    }

}
