//
//  NotificationNames.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/28/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let KeyPressedViaMIDI = NSNotification.Name(rawValue: "KeyPressedViaMIDI")
    static let KeyReleasedViaMIDI = NSNotification.Name(rawValue: "KeyReleasedViaMIDI")
    static let ModWheelViaMIDI = NSNotification.Name(rawValue: "ModWheelViaMIDI")
    static let PitchbendViaMIDI = NSNotification.Name(rawValue: "PitchBendViaMIDI")
    static let PresetLoaded = NSNotification.Name(rawValue: "PresetLoaded")
    static let MIDIKnobTouched = NSNotification.Name(rawValue: "MIDIKnobTouched")
    static let MIDIController = NSNotification.Name(rawValue: "MIDIController")
}
