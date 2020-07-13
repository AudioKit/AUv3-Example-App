//
//  Preset+TableView.swift
//  AU Example App
//
//  Created by Matthew Fecher on 2/5/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

//*****************************************************************
// MARK: - Presets Cell Delegate
//*****************************************************************

extension PresetsController: PresetCellDelegate {

    func editPressed() {
        self.performSegue(withIdentifier: "SegueToEdit", sender: self)
    }

    func duplicatePressed() {
        guard let currentPreset = presetFromConductor, let conductor = conductor else { return }
        var activeBank = setToActiveBank()
        if let copy = activeBank.duplicatePreset(preset: currentPreset) {
            activeBank.saveToDisk()
            conductor.loadPreset(copy)
            reloadPresetsTable()
        }
    }

    func favoritePressed() {
        guard let currentPreset = presetFromConductor else { return }
        presetsList.toggleFavorite(preset: currentPreset)
        reloadPresetsTable()
    }

    func sharePressed() {

        // Save preset to temp directory to be shared - why are we saving the temporary preset?
        // why not just share the saved one directly?
        guard let currentPreset = presetFromConductor else { return }
        guard let url = DiskManager().saveTemporaryPreset(preset: currentPreset) else {
            deboog("Share failed")
            return
        }
        showSharePopup(withFile: url, completion: { url in
            DiskManager().deleteURL(url: url)
        })
    }

}
