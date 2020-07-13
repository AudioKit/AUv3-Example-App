//
//  Presets+EditPopoverDelegate.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/11/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

// **********************************************************
// MARK: - Preset Save PopOver Delegate
// **********************************************************

extension PresetsController: PresetPopOverDelegate {

    func didFinishEditing(name: String, isEditing: Bool) {
        guard let conductor = conductor, var presetFromConductor = presetFromConductor else {
            deboog("didFinishEditing fail - conductor isNil: \(self.conductor == nil) currentPreset isNil: \(self.presetFromConductor == nil)")
            return
        }

        var modifiedPreset: InstrumentPreset
        if isEditing { //renaming an existing preset - this is called via edit button
            guard let newName = presetsList.renamePreset(presetFromConductor, newName: name)
            else {
                deboog("newName was same as old \(name)")
                return
            }
            presetFromConductor.name = newName
            modifiedPreset = presetFromConductor
        } else { //saving / overwriting an existing preset - this is called via save button
            if presetFromConductor.name == name,
                let existingPreset = presetsList.presets.first(where: { $0.uid == presetFromConductor.uid}) { // overwriting existing preset
                let newPreset = InstrumentPreset(conductor: conductor, name: name)
                presetsList.overwritePreset(oldPreset: existingPreset, newPreset: newPreset)
                modifiedPreset = newPreset
            } else { // saving a new preset using a new name
                // create new preset
                let newPreset = InstrumentPreset(conductor: conductor, name: name, infoText: presetDescriptionField.text)
                var activeBank = setToActiveBank()
                activeBank.add(preset: newPreset)
                activeBank.saveToDisk()
                modifiedPreset = newPreset
                updateVisibleCollection(collection: activeBank)
            }
        }
        conductor.currentPreset = modifiedPreset
        reloadPresetsTable()
        LocalNotificationCenter.sharedInstance.center.post(name: .PresetLoaded, object: conductor.exampleInstrument.uid,
                                                           userInfo: ["preset" : modifiedPreset])
    }
}
