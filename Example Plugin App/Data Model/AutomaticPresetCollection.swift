//
//  AutomaticPresetCollection.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/9/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//
// These are collections of presets that are generated dynamically and non-user editable. For example ALL Presets, and Alphabetical presets

import Foundation

class AutomaticPresetCollection: PresetCollection {
    var name: String
    var presets: [InstrumentPreset]
    var position: Int

    init(name: String, presets: [InstrumentPreset], position: Int = 0) {
        self.name = name
        self.presets = presets
        self.position = position
    }
}
